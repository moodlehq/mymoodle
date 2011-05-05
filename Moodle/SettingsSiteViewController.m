//
//  SettingsSite.m
//  Moodle
//
//  Created by jerome Mouneyrac on 21/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "SettingsSiteViewController.h"
#import "WSClient.h"
#import "XMLRPCRequest.h"
#import "NSDataAdditions.h"

@implementation SettingsSiteViewController
@synthesize fieldLabels;
@synthesize tempValues;
@synthesize textFieldBeingEdited;
@synthesize site;
@synthesize fetchedResultsController;

-(IBAction)cancel:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)deleteSite {
    UIActionSheet *deleteActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"deletesite", "Delete the site") delegate:self cancelButtonTitle:NSLocalizedString(@"donotdeletesite", "Do not delete the site") destructiveButtonTitle: NSLocalizedString(@"dodeletesite", "Do delete the site") otherButtonTitles:nil];
    [deleteActionSheet showInView:self.view];
    [deleteActionSheet release];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //there is only one action sheet on this view, so we can check the buttonIndex against the cancel button
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        //delete the entry
        [[site managedObjectContext] deleteObject:site];
        NSError *error;
        if (![[site managedObjectContext] save:&error]) {
            NSLog(@"Error saving entity: %@", [error localizedDescription]);
        }
        //return the list of sites
        [self.navigationController popViewControllerAnimated:YES];
        NSArray *allControllers = self.navigationController.viewControllers;
        UITableViewController *parent = [allControllers lastObject];
        [parent.tableView reloadData];
    }
}

- (IBAction)save:(id)sender
{
    //create the site if it doesn't exist
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    BOOL createsite = ( site == nil)?YES:NO;
   

    if (textFieldBeingEdited != nil)
    {
        NSNumber *tagAsNum= [[NSNumber alloc] 
                             initWithInt:textFieldBeingEdited.tag];
        [tempValues setObject:textFieldBeingEdited.text forKey: tagAsNum];
        [tagAsNum release];
        
    }
    
    //retrieve site url (case of creation)
    NSString *siteurl;
    for (NSNumber *key in [tempValues allKeys])
    {
        switch ([key intValue]) {
            case kUrlIndex:
                    siteurl = [[NSString alloc] initWithString:[tempValues objectForKey:key]];
               
                NSLog(@"the url is: %@", siteurl);
                break;
                //TODO: retrieve username/password
//            case kUsernameIndex:
//                [site setValue:[tempValues objectForKey:key] forKeyPath:@"mainuser.username"];
//                break;
//            case kPasswordIndex:
//                [site setValue:[tempValues objectForKey:key] forKeyPath:@"mainuser.password"];
//                break;
            default:
                break;
        }
    }
    
    //retrieve site url (case of update)
    if (site != nil) {
        siteurl = [[NSString alloc] initWithString:[site valueForKey:@"url"]];
    }
    
    // TODO hard coded token here, will get rid of it later
    NSString *sitetoken = [[NSString alloc] initWithString:@"65b113e44048963fecaefb2fcad2e15d"]; //jerome site, admin 1 ( http://jerome.moodle.local/~jerome/Moodle_iPhone )
//    NSString *sitetoken = [[NSString alloc] initWithString:@"fe0e9ee8b17af9fd255f76078c70b073"];// jerome site, admin 2 
//    NSString *sitetoken = [[NSString alloc] initWithString:@"869232723a601578ac602ff38fca9080"]; //donghsheng site ( http://dongsheng.moodle.local/m2 )

    //retrieve the site name
    WSClient *client = [[WSClient alloc] initWithToken: sitetoken withHost: siteurl];
    NSArray *wsparams = [[NSArray alloc] initWithObjects:nil];
    NSDictionary *siteinfo = [client invoke: @"moodle_webservice_mobile_get_siteinfo" withParams: wsparams];
    
    //check if the site url + userid is already in data core otherwise create a new site
    NSError *error;
    NSFetchRequest *siteRequest = [[[NSFetchRequest alloc] init] autorelease];
    [siteRequest setEntity:entity];
    NSPredicate *sitePredicate = [NSPredicate predicateWithFormat:@"(url = %@ AND mainuser.userid = %@)", siteurl, [siteinfo objectForKey:@"userid"]];
    [siteRequest setPredicate:sitePredicate];
    NSArray *sites = [context executeFetchRequest:siteRequest error:&error];
    if ([sites count]>0) {
       site = [sites lastObject];
    } else if (createsite) {
        site = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        NSLog(@"Site is nil");
    }

    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"f1.png"];    
    // profile pictre
    NSString *picture = [siteinfo objectForKey:@"profilepicture"];
    // base64 decode
    NSData *data = [NSData base64DataFromString:picture];
    
    //[data writeToFile:filePath atomically:true];
    
    NSString *sitename = [siteinfo objectForKey:@"sitename"];   
    [client release];
    [wsparams release];

    if ([siteinfo isKindOfClass:[NSDictionary class]]) {
        
        //retrieve participant main user
        NSManagedObject *user = [site valueForKey:@"mainuser"];
        if (user == nil) {
            NSEntityDescription *pariticipantEntityDescription = [NSEntityDescription entityForName:@"MainUser" inManagedObjectContext:[site managedObjectContext]];
            user = [NSEntityDescription insertNewObjectForEntityForName:[pariticipantEntityDescription name] inManagedObjectContext:[site managedObjectContext]];
        }
        
        [user setValue: [siteinfo objectForKey:@"userid"] forKey:@"userid"];
        [user setValue: [siteinfo objectForKey:@"username"] forKey:@"username"];
        [user setValue: [siteinfo objectForKey:@"firstname"] forKey:@"firstname"];
        [user setValue: [siteinfo objectForKey:@"lastname"] forKey:@"lastname"];
        
        //create/update the site
        [site setValue:sitename forKey:@"name"];
        [site setValue:data forKey: @"logo"];
        [site setValue:sitetoken forKey: @"token"];
        [site setValue:user forKey:@"mainuser"];
        [site setValue:siteurl forKey:@"url"];
        [siteurl release];
        [sitetoken release];
        
        //save the modification
        
        if (![[site managedObjectContext] save:&error]) {
         //   NSLog(@"Error saving entity: %@", [error localizedDescription]);
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0) {
                for(NSError* detailedError in detailedErrors) {
                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                }
            }
            else {
                NSLog(@"  %@", [error userInfo]);
            }
        }
        
        NSArray *allControllers = self.navigationController.viewControllers;
        
        [self.navigationController popViewControllerAnimated:YES];
        
        UITableViewController *parent = [allControllers lastObject];
        [parent.tableView reloadData];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Web service call failed" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

-(IBAction)textFieldDone:(id)sender {
    UITableViewCell *cell =
    (UITableViewCell *)[[sender superview] superview];
    UITableView *table = (UITableView *)[cell superview];
    NSIndexPath *textFieldIndexPath = [table indexPathForCell:cell];
    NSUInteger row = [textFieldIndexPath row];
    row++;
    if (row >= kNumberOfEditableRows) {
        row = 0;
    }
    NSUInteger newIndex[] = {0, row};
    NSIndexPath *newPath = [[NSIndexPath alloc] initWithIndexes:newIndex length:2];
    UITableViewCell *nextCell = [self.tableView cellForRowAtIndexPath:newPath];
    UITextField *nextField = nil;
    for (UIView *oneView in nextCell.contentView.subviews) {
        if ([oneView isMemberOfClass:[UITextField class]]) {
            nextField = (UITextField *)oneView;
        }
    }
    [newPath release];
    [nextField becomeFirstResponder];
}

- (void)dealloc {
    [textFieldBeingEdited release];
    [tempValues release];
    [fieldLabels release];
    [site release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    
    
    NSArray *array = [[NSArray alloc] initWithObjects:@"URL:", @"Username:", 
                      @"Password:", nil];
    self.fieldLabels = array;
    [array release];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"cancel", "cancel button label")
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"save", "save button label") 
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    self.tempValues = dict;
    [dict release];
    
   
    if ( site != nil) {
        // case of Updating a site
        self.title = NSLocalizedString(@"updatesite", @"Update the site");
       
        //create a footer view on the bottom of the tabeview with a Delete button
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 270)];
        //Cacaco framework doesn't have a style for the 'Delete contact' red button! We need to simulate it with a background image
        UIImage *buttonImage = [[UIImage imageNamed:@"redbutton.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
        //create the button
        UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDelete setBackgroundImage:buttonImage forState:UIControlStateNormal];
        btnDelete.frame = CGRectMake(0, 170, 300, 40); //button position at the bottom of the screen (a bit clunky)
        [btnDelete setTitle:NSLocalizedString(@"delete", "delete") forState:UIControlStateNormal];
        [btnDelete.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
       // [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnDelete addTarget:self action:@selector(deleteSite) forControlEvents:UIControlEventTouchUpInside];
        //add the button to the footer
        [footerView addSubview:btnDelete];
        //add the footer to the tableView
        self.tableView.tableFooterView = footerView; 
        [footerView release];
    } else {
        //case of Adding a new site
        self.title = NSLocalizedString(@"addasite", @"add a site");
    }
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{   
    //set the site value
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    return kNumberOfEditableRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SiteSettingCellIdentifier = @"SiteSettingCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SiteSettingCellIdentifier];
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:SiteSettingCellIdentifier] autorelease];
        UILabel *label = [[UILabel alloc] initWithFrame:
                          CGRectMake(10, 10, 75, 25)];
        label.textAlignment = UITextAlignmentRight;
        label.tag = kLabelTag;
        label.font = [UIFont boldSystemFontOfSize:14];
        [cell.contentView addSubview:label];
        [label release];
        
        
        UITextField *textField = [[UITextField alloc] initWithFrame:
                                  CGRectMake(90, 12, 200, 25)];
        textField.clearsOnBeginEditing = NO;
        [textField setDelegate:self];
        [textField addTarget:self 
                      action:@selector(textFieldDone:) 
            forControlEvents:UIControlEventEditingDidEndOnExit];
        [cell.contentView addSubview:textField];
    }
    NSUInteger row = [indexPath row];
    
    UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];
    UITextField *textField = nil;
    for (UIView *oneView in cell.contentView.subviews)
    {
        if ([oneView isMemberOfClass:[UITextField class]])
            textField = (UITextField *)oneView;
    }
    label.text = [fieldLabels objectAtIndex:row];
    NSNumber *rowAsNum = [[NSNumber alloc] initWithInt:row];
    switch (row) {
        case kUrlIndex:
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else {
                textField.text = [site valueForKey:@"url"];
                }
            break;
        case kUsernameIndex:
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = [site valueForKeyPath:@"mainuser.username"];
            break;
        case kPasswordIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = [site valueForKeyPath:@"mainuser.password"];
            break;
       
        default:
            break;
    }
    if (textFieldBeingEdited == textField)
        textFieldBeingEdited = nil;
    
    textField.tag = row;
    [rowAsNum release];
    return cell;
}
#pragma mark -
#pragma mark Table Delegate Methods
- (NSIndexPath *)tableView:(UITableView *)tableView 
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}
#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.textFieldBeingEdited = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSNumber *tagAsNum = [[NSNumber alloc] initWithInt:textField.tag];
    [tempValues setObject:textField.text forKey:tagAsNum];
    [tagAsNum release];
}


@end
