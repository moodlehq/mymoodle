//
//  SettingsSite.m
//  Moodle
//
//  Created by Jerome Mouneyrac on 21/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "SettingsSiteViewController.h"
#import "WSClient.h"
#import "Constants.h"
#import "XMLRPCRequest.h"
#import "NSDataAdditions.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"

@implementation SettingsSiteViewController

# pragma mark - private method
- (UITextField *)_createCellTextField {
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectZero];
    [field setAdjustsFontSizeToFitWidth:YES];
    [field setTextColor:[UIColor blackColor]];
    [field setDelegate:self];
    [field setBackgroundColor:[UIColor clearColor]];
    [field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [field setTextAlignment:UITextAlignmentLeft];
    [field setEnabled:YES];
    [field setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    return [field autorelease];
}

# pragma mark - Button actions
-(IBAction)cancel: (id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)deleteSite {
    UIActionSheet *deleteActionSheet = [[UIActionSheet alloc]
                                            initWithTitle:NSLocalizedString(@"deletesite", "Delete the site")
                                            delegate:self
                                            cancelButtonTitle: NSLocalizedString(@"donotdeletesite", "Do not delete the site")
                                            destructiveButtonTitle: NSLocalizedString(@"dodeletesite", "Do delete the site")
                                            otherButtonTitles:nil];
    [deleteActionSheet showInView: self.view];
    [deleteActionSheet release];
}

# pragma mark - action sheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //there is only one action sheet on this view, so we can check the buttonIndex against the cancel button
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        
        //delete the user/site default is they were matching the delete site
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *defaultSiteUrl = [defaults objectForKey: kSelectedSiteUrlKey];
        if (defaultSiteUrl == [appDelegate.site valueForKey:@"url"]) {
            NSLog(@"Trying to remove userdefault");
            [defaults removeObjectForKey:kSelectedSiteUrlKey];
            [defaults removeObjectForKey:kSelectedSiteNameKey];
            [defaults removeObjectForKey:kSelectedSiteTokenKey];
            [defaults removeObjectForKey:kSelectedUserIdKey];
            
            NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"deleted", kSelectedSiteUrlKey,
                                         nil, kSelectedSiteNameKey,
                                         nil, kSelectedSiteTokenKey,
                                         nil, kSelectedUserIdKey,
                                         nil];
            
            [defaults registerDefaults: appDefaults];
            [defaults synchronize];
            
            NSString *defaultSiteUrl = [defaults objectForKey: kSelectedSiteUrlKey];
            NSLog(@"Selected site url after deletion:");
            NSLog(@"%@", defaultSiteUrl);
        }
        
        //delete the entry
        [appDelegate.managedObjectContext deleteObject: appDelegate.site];
        NSError *error;
        if (![appDelegate.managedObjectContext save:&error]) {
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray *detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0) {
                for(NSError* detailedError in detailedErrors) {
                    NSLog(@"Detailed Error: %@", [detailedError userInfo]);
                }
            } else {
                NSLog(@"  %@", [error userInfo]);
            }
        }
        
        // send notification to appdelete to reset site
        [[NSNotificationCenter defaultCenter] postNotificationName: kResetSite
                                                            object: nil];
        //return the list of sites
        NSArray *allControllers = self.navigationController.viewControllers;
        UITableViewController *parent = [allControllers lastObject];
        [parent.tableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL) validateUrl: (NSString *) candidate {
    NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:candidate];
}

- (void)saveButtonPressed: (id)sender
{
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSString *siteurl;
    siteurl = [siteurlField text];


    if (![self validateUrl:siteurl]) {
        siteurl = [NSString stringWithFormat: @"http://%@", siteurl];
    }

    if ([siteurl hasSuffix:@"/"]) {
        siteurl = [siteurl substringToIndex:[siteurl length] - 1];
    }

    NSString *username = [usernameField text];
    NSString *password = [passwordField text];

    NSString *tokenURL = [NSString stringWithFormat:@"%@/login/token.php", siteurl];
    NSURL *url = [NSURL URLWithString: tokenURL];
    NSLog(@"%@", tokenURL);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue: username forKey: @"username"];
    [request setPostValue: password forKey: @"password"];
    [request setPostValue: @"moodle_mobile_app" forKey: @"service"];
    [request setCompletionBlock: ^{
        NSLog(@"Token info: %@", [request responseString]);
        NSDictionary *token = [[CJSONDeserializer deserializer] deserializeAsDictionary: [request responseData] error: nil];
        NSLog(@"Token: %@", token);
        NSString *sitetoken = [token valueForKey: @"token"];
        @try {
            //retrieve the site name
            WSClient *client = [[WSClient alloc] initWithToken: sitetoken withHost: siteurl];
            NSArray *wsparams = [[NSArray alloc] initWithObjects:nil];
            NSDictionary *siteinfo = [client invoke: @"moodle_webservice_get_siteinfo" withParams: wsparams];
            [wsparams release];
            [client release];

            if ([siteinfo isKindOfClass: [NSDictionary class]]) {
                //check if the site url + userid is already in data core otherwise create a new site
                NSError *error;
                NSFetchRequest *siteRequest = [[[NSFetchRequest alloc] init] autorelease];
                NSEntityDescription *siteEntity = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:context];
                [siteRequest setEntity: siteEntity];
                NSPredicate *sitePredicate = [NSPredicate predicateWithFormat:@"(url = %@ AND mainuser.userid = %@)", siteurl, [siteinfo objectForKey:@"userid"]];
                [siteRequest setPredicate:sitePredicate];
                NSArray *sites = [context executeFetchRequest:siteRequest error:&error];
                NSLog(@"Sites info %@", sites);

                if ([sites count] > 0) {
                    appDelegate.site = [sites lastObject];
                } else {
                    appDelegate.site = [NSEntityDescription insertNewObjectForEntityForName: [siteEntity name] inManagedObjectContext:context];
                }
                // profile pictre
                NSString  *userpictureurl = [siteinfo objectForKey: @"userpictureurl"];
                NSString *sitename = [siteinfo objectForKey: @"sitename"];
                //create/update the site
                [appDelegate.site setValue: sitename       forKey: @"name"];
                [appDelegate.site setValue: userpictureurl forKey: @"userpictureurl"];
                [appDelegate.site setValue: sitetoken      forKey: @"token"];
                [appDelegate.site setValue: siteurl        forKey: @"url"];

                NSManagedObject *user;
                NSManagedObject *webservice;
                NSArray *webservices = [siteinfo objectForKey:@"functions"];
                //retrieve participant main user
                if (newEntry) {
                    NSEntityDescription *mainUserDesc = [NSEntityDescription entityForName:@"MainUser" inManagedObjectContext:context];
                    user = [NSEntityDescription insertNewObjectForEntityForName: [mainUserDesc name]
                                                         inManagedObjectContext: context];
                } else {
                    user = [appDelegate.site valueForKey:@"mainuser"];

                    // delete old records
                    NSFetchRequest *request = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName: @"WebService" inManagedObjectContext: context];
                    [request setEntity: entity];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(site = %@)", appDelegate.site];
                    [request setPredicate: predicate];
                    NSArray *objects = [context executeFetchRequest: request error: nil];
                    for (NSManagedObject *info in objects) {
                        [context deleteObject: info];
                    }

                    [request release];
                }
                NSEntityDescription *wsDesc = [NSEntityDescription entityForName:@"WebService" inManagedObjectContext:context];
                for (NSDictionary *ws in webservices) {
                    webservice = [NSEntityDescription insertNewObjectForEntityForName: [wsDesc name] inManagedObjectContext:context];
                    [webservice setValue:[ws valueForKey:@"name"] forKey:@"name"];
                    [webservice setValue:appDelegate.site forKey:@"site"];
                    int version = [[ws valueForKey:@"version"] intValue];
                    [webservice setValue: [NSNumber numberWithInt: version] forKey:@"version"];
                }
                [user setValue: [siteinfo objectForKey:@"userid"]    forKey:@"userid"];
                [user setValue: [siteinfo objectForKey:@"username"]  forKey:@"username"];
                [user setValue: [siteinfo objectForKey:@"firstname"] forKey:@"firstname"];
                [user setValue: [siteinfo objectForKey:@"fullname"]  forKey:@"fullname"];
                [user setValue: [siteinfo objectForKey:@"lastname"]  forKey:@"lastname"];
                [user setValue: appDelegate.site                     forKey:@"site"];

                [appDelegate.site setValue: user forKey: @"mainuser"];



                // update active site info
                sites = [context executeFetchRequest:siteRequest error:&error];
                if ([sites count] > 0) {
                    appDelegate.site = [sites lastObject];
                }
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                //save the current site into user preference
                [defaults setObject:[appDelegate.site valueForKey:@"url"] forKey:kSelectedSiteUrlKey];
                [defaults setObject:[appDelegate.site valueForKey:@"name"] forKey:kSelectedSiteNameKey];
                [defaults setObject:[appDelegate.site valueForKey:@"token"] forKey:kSelectedSiteTokenKey];
                [defaults setObject:[appDelegate.site valueForKeyPath:@"mainuser.userid"] forKey:kSelectedUserIdKey];
                [defaults synchronize];
                //save the modification
                if (![context save: &error]) {
                    NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
                    NSArray *detailedErrors = [[error userInfo] objectForKey: NSDetailedErrorsKey];
                    if(detailedErrors != nil && [detailedErrors count] > 0) {
                        for(NSError* detailedError in detailedErrors) {
                            NSLog(@"Detailed Error: %@", [detailedError userInfo]);
                        }
                    } else {
                        NSLog(@"  %@", [error userInfo]);
                    }
                }
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
        @catch (NSException *exception) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate:self cancelButtonTitle:@"Continue" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }

    }];
    [request startAsynchronous];
}

-(IBAction)textFieldDone:(id)sender {
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
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

#pragma mark - View lifecycle

- (id)initWithNew: (NSString *)new {

    if ((self = [self initWithStyle:UITableViewStyleGrouped])) {

        if ([new isEqualToString:@"no"]) {
            newEntry = NO;
        } else {
            newEntry = YES;
        }
    }

    return self;
}

- (void)loadView {
    [super loadView];
}

- (void)dealloc {
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [[self navigationController] setNavigationBarHidden:NO animated:NO];

    [super viewWillAppear:animated];

    self.navigationController.view.backgroundColor = UIColorFromRGB(LoginBackground);
    self.tableView.backgroundColor = [UIColor clearColor];

    siteurlCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[siteurlCell textLabel] setText: @"Site URL"];
    siteurlField = [self _createCellTextField];
    siteurlField.frame = CGRectMake(115, 12, siteurlCell.bounds.size.width - 125, 30);
    [siteurlField setReturnKeyType:UIReturnKeyNext];
    [siteurlCell addSubview:siteurlField];
    if (!newEntry) {
        siteurlField.text = [appDelegate.site valueForKey:@"url"];
    } else {
        siteurlField.text = @"http://dongsheng.moodle.local/moodle";
    }

    usernameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[usernameCell textLabel] setText:@"Username"];
    usernameField = [self _createCellTextField];
    usernameField.frame = CGRectMake(115, 12, usernameCell.bounds.size.width - 125, 30);
    [usernameField setReturnKeyType:UIReturnKeyNext];
    [usernameCell addSubview:usernameField];
    if (!newEntry) {
        usernameField.text = [appDelegate.site valueForKeyPath:@"mainuser.username"];
    } else {
        usernameField.text = @"teacher";
    }

    passwordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[passwordCell textLabel] setText:@"Password"];
    passwordField = [self _createCellTextField];
    passwordField.frame = CGRectMake(115, 12, passwordCell.bounds.size.width - 125, 30);
    [passwordField setSecureTextEntry:YES];
    [passwordField setReturnKeyType:UIReturnKeyDone];
    [passwordCell addSubview:passwordField];
    if (!newEntry) {
        passwordField.text = @"******";
    } else {
        passwordField.text = @"cds";
    }

    topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [self.view bounds].size.width, 40.0f)];
    [topLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    [topLabel setTextAlignment:UITextAlignmentCenter];
    [topLabel setBackgroundColor:[UIColor clearColor]];
    [topLabel setShadowColor:[UIColor blackColor]];
    [topLabel setShadowOffset:CGSizeMake(0, 1.0f)];
    [topLabel setTextColor: [UIColor whiteColor]];
    [topLabel setFont:[UIFont fontWithName:@"SoulPapa" size:42]];
    [topLabel setText:@"moodle"];

    if (!newEntry) {
        int buttonWidth = 300;
        int buttonHeight = 45;
        UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, buttonWidth, buttonHeight)];
        UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDelete setBackgroundImage:[UIImage imageNamed:@"button_red.png"] forState:UIControlStateNormal];
        [btnDelete setTitle: NSLocalizedString(@"delete", "delete") forState:UIControlStateNormal];
        [btnDelete setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
        [btnDelete.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [btnDelete addTarget:self action:@selector(deleteSite) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:btnDelete];
        self.tableView.tableFooterView = buttonView;
        [buttonView release];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"cancel", nil)
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle: NSLocalizedString(@"save", nil)
                                   style:UIBarButtonItemStyleDone
                                   target:self
                                   action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];

    if (!newEntry) {
        // case of Updating a site
        self.title = NSLocalizedString(@"updatesite", nil);

    } else {
        //case of Adding a new site
        self.title = NSLocalizedString(@"addsite", nil);
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfEditableRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0) {
        return siteurlCell;
    } else if ([indexPath row] == 1) {
        return usernameCell;
    } else if ([indexPath row] == 2) {
        return passwordCell;
    } else {
        return nil;
    }

}
#pragma mark -
#pragma mark Table Delegate Methods
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 65.0f;
    } else {
        return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)table viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return topLabel;
    } else {
        return nil;
    }
}

#pragma mark -
#pragma mark textfield delegate method


- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    editingField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == siteurlField) {
        [usernameField becomeFirstResponder];
    } else if (textField == usernameField) {
        [passwordField becomeFirstResponder];
    } else if (textField == passwordField) {
        [self saveButtonPressed: nil];
    }

    return YES;
}

- (void)dismissKeyboard: (UITapGestureRecognizer *)sender
{
    NSLog(@"ta");
    [editingField resignFirstResponder];
}
 - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
     if ([touch.view isKindOfClass:[UIButton class]]){
         return NO;
     }
     return YES;
 }
@end
