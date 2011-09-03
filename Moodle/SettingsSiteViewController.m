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

@synthesize editingSite;

- (void)backToRoot
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

# pragma mark - private method
- (UITextField *)_createCellTextField
{
    UITextField *field = [[UITextField alloc] initWithFrame:CGRectZero];

    [field setAdjustsFontSizeToFitWidth:YES];
    [field setClearButtonMode:UITextFieldViewModeWhileEditing];
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
- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteSite
{
    UIActionSheet *deleteActionSheet = [[UIActionSheet alloc]
                                                 initWithTitle:NSLocalizedString(@"deletesite", nil)
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                        destructiveButtonTitle:NSLocalizedString(@"delete", nil)
                                             otherButtonTitles:nil];

    [deleteActionSheet showInView:self.view];
    [deleteActionSheet release];
}



- (IBAction)saveButtonPressed:(id)sender
{
    [editingField resignFirstResponder];
    if ([passwordField text] == nil || [[passwordField text] isEqualToString:@""] || [usernameField text] == nil || [[usernameField text] isEqualToString:@""] || [siteurlField text] == nil || [[siteurlField text] isEqualToString:@""])
    {
        UIAlertView *passwordAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"requiredfields", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
        [passwordAlert show];
        [passwordAlert release];
        return;
    }
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    [self.view.window addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"loading", @"Loading");
    [HUD showWhileExecuting:@selector(login) onTarget:self withObject:nil animated:YES];
}

# pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // there is only one action sheet on this view, so we can check the buttonIndex against the cancel button
    if (buttonIndex != [actionSheet cancelButtonIndex])
    {
        [MoodleSite deleteSite:appDelegate.managedObjectContext withSite:self.editingSite];
        // return the list of sites
        NSArray *allControllers = self.navigationController.viewControllers;
        UITableViewController *parent = [allControllers lastObject];
        [parent.tableView reloadData];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)validateUrl:(NSString *)candidate
{
    NSString *urlRegEx = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];

    return [urlTest evaluateWithObject:candidate];
}

- (NSString *)getTokenWithHost:(NSURL *)tokenURL withUsername:(NSString *)username withPassword:(NSString *)password isTrying:(BOOL)isTrying
{

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:tokenURL];

    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:@"moodle_mobile_app" forKey:@"service"];
    [request startSynchronous];

    NSDictionary *token = [[CJSONDeserializer deserializer] deserializeAsDictionary:[request responseData] error:nil];

    if ([[request responseString] isEqualToString:@""] || [request responseString] == nil || [request responseStatusCode] != 200)
    {
        if (!isTrying)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"cannotconnect", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        return nil;
    }

    if ([token valueForKey:@"error"])
    {
        if (!isTrying)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"invalidaccount", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        return nil;
    }

    NSString *tokenString = [token valueForKey:@"token"];

    if (!tokenString)
    {
        if (!isTrying)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"invalidaccount", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        return nil;
    }

    return tokenString;
}

- (NSString *)tryHTTPSIfPossible:(NSString *)hostString withUsername:(NSString *)username withPassword:(NSString *)password
{

    NSString *tokenURLString = [NSString stringWithFormat:@"%@/login/token.php", hostString];

    NSLog(@"tokenURLString %@", tokenURLString);
    NSURL *tokeURL = [NSURL URLWithString:tokenURLString];
    NSString *token;
    if ([tokeURL.scheme isEqualToString:@"http"])
    {
        // test https first
        if ([hostString hasPrefix:@"http"])
        {
            tokenURLString = [tokenURLString substringFromIndex:4];
            tokenURLString = [NSString stringWithFormat:@"https%@", tokenURLString];
        }
        NSLog(@"Guessing HTTPS connection %@", tokenURLString);
        NSURL *httpsTokenURL = [NSURL URLWithString:tokenURLString];
        if ((token = [self getTokenWithHost:httpsTokenURL withUsername:username withPassword:password isTrying:YES]))
        {
            // fix host url
            hostURL = [hostURL substringFromIndex:4];
            hostURL = [NSString stringWithFormat:@"https%@", hostURL];
            return token;
        }
        else
        {
            NSLog(@"https detection failed!");
            token = [self getTokenWithHost:tokeURL withUsername:username withPassword:password isTrying:NO];
            NSLog(@"got token from http %@", token);
            return token;
        }
    }
    else
    {
        token = [self getTokenWithHost:tokeURL withUsername:username withPassword:password isTrying:NO];
        return token;
    }
}


- (void)login
{
    NSManagedObjectContext *context = appDelegate.managedObjectContext;

    hostURL = [siteurlField text];

    // remove trailing slash
    if ([hostURL hasSuffix:@"/"])
    {
        hostURL = [hostURL substringToIndex:[hostURL length] - 1];
    }

    NSURL *siteURL = [NSURL URLWithString:hostURL];
    if (siteURL.scheme == nil)
    {
        hostURL = [NSString stringWithFormat:@"http://%@", hostURL];
        siteURL = [NSURL URLWithString:hostURL];
    }

    if (!([siteURL.scheme isEqualToString:@"http"] || [siteURL.scheme isEqualToString:@"https"]))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:NSLocalizedString(@"invalidscheme", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }

    NSString *username = [usernameField text];
    NSString *password = [passwordField text];

    NSString *sitetoken;
    if (!(sitetoken = [self tryHTTPSIfPossible:hostURL withUsername:username withPassword:password]))
    {
        NSLog(@"no token returned");
        return;
    }

    @try {
        // retrieve the site name
        WSClient *client = [[WSClient alloc] initWithToken:sitetoken withHost:hostURL];
        NSArray *wsparams = [[NSArray alloc] initWithObjects:nil];
        NSDictionary *siteinfo = [client invoke:@"moodle_webservice_get_siteinfo" withParams:wsparams];
        [wsparams release];
        [client release];

        if ([siteinfo isKindOfClass:[NSDictionary class]])
        {
            // check if the site url + userid is already in data core otherwise create a new site
            NSError *error;
            NSFetchRequest *siteRequest = [[[NSFetchRequest alloc] init] autorelease];
            NSEntityDescription *siteEntity = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:context];
            [siteRequest setEntity:siteEntity];
            NSPredicate *sitePredicate = [NSPredicate predicateWithFormat:@"(url = %@ AND mainuser.userid = %@)", hostURL, [siteinfo objectForKey:@"userid"]];
            [siteRequest setPredicate:sitePredicate];
            NSArray *sites = [context executeFetchRequest:siteRequest error:&error];

            BOOL updateExistingAccount = NO;
            if ([sites count] > 0)
            {
                NSLog(@"updating existing site");
                updateExistingAccount = YES;
                self.editingSite = [sites lastObject];
            }
            else
            {
                // insert new site
                self.editingSite = [NSEntityDescription insertNewObjectForEntityForName:[siteEntity name] inManagedObjectContext:context];
            }
            // create/update the site
            [self.editingSite setValue:[siteinfo objectForKey:@"sitename"] forKey:@"name"];
            [self.editingSite setValue:[siteinfo objectForKey:@"userpictureurl"] forKey:@"userpictureurl"];
            [self.editingSite setValue:sitetoken forKey:@"token"];
            [self.editingSite setValue:hostURL forKey:@"url"];

            NSManagedObject *user;
            // retrieve participant main user
            if (newEntry && !updateExistingAccount)
            {
                NSEntityDescription *mainUserDesc = [NSEntityDescription entityForName:@"MainUser" inManagedObjectContext:context];
                user = [NSEntityDescription insertNewObjectForEntityForName:[mainUserDesc name]
                                                     inManagedObjectContext:context];
            }
            else
            {
                user = [self.editingSite valueForKey:@"mainuser"];

                // delete old web service records
                NSFetchRequest *wsRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *wsEntity = [NSEntityDescription entityForName:@"WebService" inManagedObjectContext:context];
                [wsRequest setEntity:wsEntity];
                NSPredicate *wsPredicate = [NSPredicate predicateWithFormat:@"(site = %@)", self.editingSite];
                [wsRequest setPredicate:wsPredicate];
                NSArray *wsObjects = [context executeFetchRequest:wsRequest error:nil];
                for (NSManagedObject *wsObject in wsObjects)
                {
                    [context deleteObject:wsObject];
                }

                [wsRequest release];
            }

            // set user values
            [user setValue:[siteinfo objectForKey:@"userid"]    forKey:@"userid"];
            [user setValue:[siteinfo objectForKey:@"username"]  forKey:@"username"];
            [user setValue:[siteinfo objectForKey:@"firstname"] forKey:@"firstname"];
            [user setValue:[siteinfo objectForKey:@"fullname"]  forKey:@"fullname"];
            [user setValue:[siteinfo objectForKey:@"lastname"]  forKey:@"lastname"];
            [user setValue:self.editingSite forKey:@"site"];
            [self.editingSite setValue:user forKey:@"mainuser"];

            // Insert new web services
            NSManagedObject *webservice;
            NSArray *webservices = [siteinfo objectForKey:@"functions"];
            NSEntityDescription *wsDesc = [NSEntityDescription entityForName:@"WebService" inManagedObjectContext:context];
            for (NSDictionary *function in webservices)
            {
                int version = [[function valueForKey:@"version"] intValue];
                webservice = [NSEntityDescription insertNewObjectForEntityForName:[wsDesc name] inManagedObjectContext:context];

                [webservice setValue:[function valueForKey:@"name"] forKey:@"name"];
                [webservice setValue:self.editingSite forKey:@"site"];
                [webservice setValue:[NSNumber numberWithInt:version] forKey:@"version"];
            }

            // update active site info
            sites = [context executeFetchRequest:siteRequest error:&error];
            if ([sites count] > 0)
            {
                self.editingSite = [sites lastObject];
            }
            // if this is a new site, use it as active site
            if (newEntry)
            {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                // save the current site into user preference
                [defaults setObject:[self.editingSite valueForKey:@"url"] forKey:kSelectedSiteUrlKey];
                [defaults setObject:[self.editingSite valueForKey:@"name"] forKey:kSelectedSiteNameKey];
                [defaults setObject:[self.editingSite valueForKey:@"token"] forKey:kSelectedSiteTokenKey];
                [defaults setObject:[self.editingSite valueForKeyPath:@"mainuser.userid"] forKey:kSelectedUserIdKey];
                [defaults synchronize];
                appDelegate.site = self.editingSite;
            }

            // save the modification
            if (![context save:&error])
            {
                NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
                NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
                if (detailedErrors != nil && [detailedErrors count] > 0)
                {
                    for (NSError *detailedError in detailedErrors)
                    {
                        NSLog(@"Detailed Error: %@", [detailedError userInfo]);
                    }
                }
                else
                {
                    NSLog(@"  %@", [error userInfo]);
                }
            }
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate:self cancelButtonTitle:NSLocalizedString(@"continue", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    [self performSelectorOnMainThread:@selector(backToRoot)
                           withObject:nil
                        waitUntilDone:YES];
}


#pragma mark - View lifecycle

- (id)initWithNew:(NSString *)new
{
    if ((self = [self initWithStyle:UITableViewStyleGrouped]))
    {
        if ([new isEqualToString:@"no"])
        {
            newEntry = NO;
        }
        else
        {
            newEntry = YES;
        }
    }

    return self;
}

- (void)dealloc
{
    [super dealloc];
    [editingSite release];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [super viewWillAppear:animated];

    if (!newEntry)
    {
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"update", nil)];
        // case of Updating a site
        self.title = NSLocalizedString(@"updatesite", nil);

        siteurlField.text = [self.editingSite valueForKey:@"url"];
        [siteurlField setEnabled:NO];
        [siteurlField setTextColor:[UIColor grayColor]];
        usernameField.text = [self.editingSite valueForKeyPath:@"mainuser.username"];
        [usernameField setEnabled:NO];
        [usernameField setTextColor:[UIColor grayColor]];
        [passwordField setText:@""];
        int buttonWidth = 300;
        int buttonHeight = 45;
        UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, buttonWidth, buttonHeight)];
        UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnDelete setBackgroundImage:[UIImage imageNamed:@"button_red.png"] forState:UIControlStateNormal];
        [btnDelete setTitle:NSLocalizedString(@"delete", "delete") forState:UIControlStateNormal];
        [btnDelete setFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
        [btnDelete.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [btnDelete addTarget:self action:@selector(deleteSite) forControlEvents:UIControlEventTouchUpInside];
        [buttonView addSubview:btnDelete];
        self.tableView.tableFooterView = buttonView;
        [buttonView release];
    }
    else
    {
        [self.navigationItem.rightBarButtonItem setTitle:NSLocalizedString(@"add", nil)];
        // case of Adding a new site
        self.title = NSLocalizedString(@"addsite", nil);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"cancel", nil)
                                             style:UIBarButtonItemStylePlain
                                            target:self
                                            action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];

    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"add", nil)
                                           style:UIBarButtonItemStyleDone
                                          target:self
                                          action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];

    self.navigationController.view.backgroundColor = UIColorFromRGB(LoginBackground);
    self.tableView.backgroundColor = [UIColor clearColor];

    siteurlCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[siteurlCell textLabel] setText:NSLocalizedString(@"siteurllabel", nil)];
    siteurlField = [self _createCellTextField];
    siteurlField.frame = CGRectMake(115, 12, siteurlCell.bounds.size.width - 125, 30);
    [siteurlField setReturnKeyType:UIReturnKeyNext];
    [siteurlCell addSubview:siteurlField];
    [siteurlField setPlaceholder:NSLocalizedString(@"yoursiteurl", nil)];


    usernameCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[usernameCell textLabel] setText:NSLocalizedString(@"usernamelabel", nil)];
    usernameField = [self _createCellTextField];
    usernameField.frame = CGRectMake(115, 12, usernameCell.bounds.size.width - 125, 30);
    [usernameField setReturnKeyType:UIReturnKeyNext];
    [usernameCell addSubview:usernameField];
    [usernameField setPlaceholder:NSLocalizedString(@"yourusername", nil)];


    passwordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [[passwordCell textLabel] setText:NSLocalizedString(@"passwordlabel", nil)];
    passwordField = [self _createCellTextField];
    passwordField.frame = CGRectMake(115, 12, passwordCell.bounds.size.width - 125, 30);
    [passwordField setSecureTextEntry:YES];
    [passwordField setReturnKeyType:UIReturnKeyDone];
    [passwordCell addSubview:passwordField];
    [passwordField setPlaceholder:NSLocalizedString(@"yourpassword", nil)];


    topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [self.view bounds].size.width, 40.0f)];
    [topLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin];
    [topLabel setTextAlignment:UITextAlignmentCenter];
    [topLabel setBackgroundColor:[UIColor clearColor]];
    [topLabel setShadowColor:[UIColor blackColor]];
    [topLabel setShadowOffset:CGSizeMake(0, 1.0f)];
    [topLabel setTextColor:[UIColor whiteColor]];
    [topLabel setFont:[UIFont fontWithName:@"SoulPapa" size:42]];
    [topLabel setText:@"moodle"];


    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard:)];
    tap.delegate = self;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfEditableRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0)
    {
        return siteurlCell;
    }
    else if ([indexPath row] == 1)
    {
        return usernameCell;
    }
    else if ([indexPath row] == 2)
    {
        return passwordCell;
    }
    else
    {
        return nil;
    }
}
#pragma mark -
#pragma mark Table Delegate Methods
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 65.0f;
    }
    else
    {
        return 0.0f;
    }
}

- (UIView *)tableView:(UITableView *)table viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return topLabel;
    }
    else
    {
        return nil;
    }
}

#pragma mark -
#pragma mark textfield delegate method
- (void)textFieldDidBeginEditing:(UITextField *)textField;
{
    editingField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == siteurlField)
    {
        [usernameField becomeFirstResponder];
    }
    else if (textField == usernameField)
    {
        [passwordField becomeFirstResponder];
    }
    else if (textField == passwordField)
    {
        [self saveButtonPressed:nil];
    }

    return YES;
}

#pragma mark -
#pragma mark Tap gusture
- (void)dismissKeyboard:(UITapGestureRecognizer *)sender
{
    [editingField resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]])
    {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden
{
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

@end
