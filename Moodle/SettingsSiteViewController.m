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

@implementation SettingsSiteViewController
@synthesize fieldLabels;
@synthesize tempValues;
@synthesize textFieldBeingEdited;
@synthesize site;
@synthesize fetchedResultsController;

-(IBAction)cancel:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)save:(id)sender
{
    //create the site if it doesn't exist
    if ( site == nil) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        site = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    }
    
    //retrieve the site name
    WSClient *client = [[WSClient alloc] initWithToken: @"http://dongsheng.moodle.local/m2/webservice/xmlrpc/server.php?wstoken=869232723a601578ac602ff38fca9080"];
    NSArray *wsparams = [[NSArray alloc] initWithObjects:@"Hello, Moodle", nil];
    NSString *msg = [client invoke: @"moodle_echo" withParams: wsparams];  
    [client release];
    [wsparams release];
    if ([msg isKindOfClass:[NSString class]]) {
        [site setValue:msg forKey:@"sitename"];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Web service call failed" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    if (textFieldBeingEdited != nil)
    {
        NSNumber *tagAsNum= [[NSNumber alloc] 
                             initWithInt:textFieldBeingEdited.tag];
        [tempValues setObject:textFieldBeingEdited.text forKey: tagAsNum];
        [tagAsNum release];
        
    }
    for (NSNumber *key in [tempValues allKeys])
    {
        switch ([key intValue]) {
            case kUrlIndex:
                [site setValue:[tempValues objectForKey:key] forKey:@"siteurl"];
                break;
            case kUsernameIndex:
                [site setValue:[tempValues objectForKey:key] forKey:@"username"];
                break;
            case kPasswordIndex:
                [site setValue:[tempValues objectForKey:key] forKey:@"password"];
                break;
            
            default:
                break;
        }
    }
    
    //save the modification
    NSError *error;
    if (![[site managedObjectContext] save:&error]) {
        NSLog(@"Error saving entity: %@", [error localizedDescription]);
    }
    
    
    NSArray *allControllers = self.navigationController.viewControllers;
    [self.navigationController popViewControllerAnimated:YES];
    UITableViewController *parent = [allControllers lastObject];
    [parent.tableView reloadData];    
    
    
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
                                     initWithTitle:@"Cancel"
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Save" 
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    self.tempValues = dict;
    [dict release];
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
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else {
                textField.text = [site valueForKey:@"siteurl"];
                }
            break;
        case kUsernameIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = [site valueForKey:@"username"];
            break;
        case kPasswordIndex:
            if ([[tempValues allKeys] containsObject:rowAsNum])
                textField.text = [tempValues objectForKey:rowAsNum];
            else
                textField.text = [site valueForKey:@"password"];
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
