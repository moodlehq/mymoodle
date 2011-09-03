//
//  DetailViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 16/06/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "DetailViewController.h"
#import "MoodleKit.h"
#import "Participant.h"
// temp fix for https://github.com/facebook/three20/issues/194
#import <Three20UINavigator/UIViewController+TTNavigator.h>
#import "Three20Core/NSStringAdditions.h"

#import "MapViewController.h"


@implementation DetailViewController
@synthesize participant = _participant;
@synthesize course = _course;

#pragma mark - Button actions
- (void)displayComposerSheet:(NSString *)email
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));

    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            NSLog(@"picker %@", picker);
            picker.mailComposeDelegate = self;

            // Set up recipients
            NSArray *toRecipients = [NSArray arrayWithObject:email];

            [picker setToRecipients:toRecipients];

            [self presentModalViewController:picker animated:YES];
            [picker release];
        }
        else
        {
            NSString *email = [NSString stringWithFormat:@"%@", email];
            email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
        }
    }
    else
    {
        NSString *email = [NSString stringWithFormat:@"%@", email];
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
    }

}

- (IBAction)clickedUploadButton:(id)sender
{
    HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
    [self.view.window addSubview:HUD];
    [HUD showWhileExecuting:@selector(refreshUserInfo) onTarget:self withObject:nil animated:YES];
}

#pragma mark - private methods

- (void)setupTableHeader
{
    CGRect tableViewFrame = self.tableView.frame;
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(TABLE_MARGIN, TABLE_MARGIN, tableViewFrame.size.width - TABLE_MARGIN * 2, 120)];

    // user picture
    userpicture = [[[UIImageView alloc] initWithFrame:CGRectMake(TABLE_MARGIN, TABLE_MARGIN, 100, 100)] autorelease];

    userpicture.layer.cornerRadius = 9.0;
    userpicture.layer.masksToBounds = YES;
    userpicture.layer.borderColor = UIColorFromRGB(ColorBackground).CGColor;
    userpicture.layer.borderWidth = 3.0;

    NSURL *url = [NSURL URLWithString:[self.participant valueForKey:@"profileimageurl"]];

    SDWebImageManager *manager = [SDWebImageManager sharedManager];

    UIImage *cachedImage = [manager imageWithURL:url];

    if (cachedImage)
    {
        userpicture.image = cachedImage;
    }
    else
    {
        [manager downloadWithURL:url delegate:self];
    }

    // user fullname
    UILabel *fullname = [[UILabel alloc] initWithFrame:CGRectMake(TABLE_MARGIN + 100 + 20, TABLE_MARGIN, tableViewFrame.size.width - TABLE_MARGIN * 2 - 100, 100)];
    fullname.text = [self.participant valueForKey:@"fullname"];
    fullname.backgroundColor = [UIColor clearColor];
    fullname.font = [UIFont fontWithName:@"Arial-BoldMT" size:24.0];

    [tableHeaderView addSubview:userpicture];
    [tableHeaderView addSubview:fullname];
    [fullname release];
    self.tableView.tableHeaderView = tableHeaderView;
    [tableHeaderView release];
}

- (void)setupTableFooter
{
    tableviewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120)];
    tableviewFooter.userInteractionEnabled = YES;

    UIButton *buttonSendMsg = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonSendMsg setTitle:NSLocalizedString(@"sendmessage", nil) forState:UIControlStateNormal];
    [buttonSendMsg setFrame:CGRectMake(TABLE_MARGIN, 0, 320 - TABLE_MARGIN * 2, 50)];
    buttonSendMsg.tag = TAG_BUTTON_SEND;
    [buttonSendMsg addTarget:@"tt://post" action:@selector(openURLFromButton:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *buttonAddNote = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonAddNote setTitle:NSLocalizedString(@"addnote", nil) forState:UIControlStateNormal];
    [buttonAddNote setFrame:CGRectMake(TABLE_MARGIN, 60, BUTTON_WIDTH, 50)];
    buttonAddNote.tag = TAG_BUTTON_NOTE;
    [buttonAddNote addTarget:@"tt://post" action:@selector(openURLFromButton:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *buttonAddContact = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonAddContact setTitle:NSLocalizedString(@"addcontact", nil) forState:UIControlStateNormal];
    [buttonAddContact addTarget:self action:@selector(addContact) forControlEvents:UIControlEventTouchUpInside];
    [buttonAddContact setFrame:CGRectMake(self.view.frame.size.width - TABLE_MARGIN - BUTTON_WIDTH, 60, BUTTON_WIDTH, 50)];
    buttonAddContact.tag = TAG_BUTTON_CONTACT;

    [tableviewFooter addSubview:buttonSendMsg];
    [tableviewFooter addSubview:buttonAddNote];
    [tableviewFooter addSubview:buttonAddContact];

    [self.tableView setTableFooterView:tableviewFooter];
    [tableviewFooter release];
}


- (NSDictionary *)createInfo:(NSString *)key value:(NSString *)value
{
    NSDictionary *dict = [[[NSDictionary alloc] initWithObjectsAndKeys:value, key, nil] autorelease];

    return dict;
}

- (void)initialiseTableData
{
    /** contact information */
    contactinfo = [[NSMutableArray alloc] init];
    if ([self.participant valueForKey:@"email"])
    {
        [contactinfo addObject:[self createInfo:@"email" value:[self.participant valueForKey:@"email"]]];
    }
    if ([self.participant valueForKey:@"phone1"])
    {
        [contactinfo addObject:[self createInfo:@"phone1" value:[self.participant valueForKey:@"phone1"]]];
    }
    if ([self.participant valueForKey:@"phone2"])
    {
        [contactinfo addObject:[self createInfo:@"phone2" value:[self.participant valueForKey:@"phone2"]]];
    }

    /** geo information */
    geoinfo = [[NSMutableArray alloc] init];
    if ([self.participant valueForKey:@"country"])
    {
        [geoinfo addObject:[self createInfo:@"country" value:[self.participant valueForKey:@"country"]]];
    }
    if ([self.participant valueForKey:@"city"])
    {
        [geoinfo addObject:[self createInfo:@"city" value:[self.participant valueForKey:@"city"]]];
    }
    if ([self.participant valueForKey:@"address"])
    {
        [geoinfo addObject:[self createInfo:@"address" value:[self.participant valueForKey:@"address"]]];
    }
}

// load user
- (void)updateUserData
{
    WSClient *client = [[WSClient alloc] init];

    // build individual user
    NSNumber *userid = [self.participant valueForKey:@"userid"];
    NSNumber *courseid = [self.course valueForKey:@"id"];
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys:userid, @"userid", courseid, @"courseid", nil];

    // build user list, we have only one user
    NSArray *userlist = [[NSArray alloc] initWithObjects:user, nil];

    NSArray *vals = [[NSArray alloc] initWithObjects:userlist, nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"userlist", nil];

    NSDictionary *params = [[NSDictionary alloc] initWithObjects:vals forKeys:keys];
    NSArray *result;

    @try {
        result = [client invoke:@"moodle_user_get_course_participants_by_id" withParams:(NSArray *)params];

        if (result && [result isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *theparticipant in result)
            {
                [Participant update:self.participant dict:theparticipant course:nil];
            }
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate:self cancelButtonTitle:NSLocalizedString(@"continue", @"") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }

    [user release];
    [userlist release];
    [vals release];
    [keys release];
    [client release];
}

- (void)refreshUserInfo
{
    [self updateUserData];
    [self initialiseTableData];

    [self setupTableHeader];

    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void)addContact
{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef person = ABPersonCreate();

    NSData *dataRef = UIImagePNGRepresentation(userpicture.image);

    ABPersonSetImageData(person, (CFDataRef)dataRef, nil);

    ABRecordSetValue(person, kABPersonFirstNameProperty, _participant.fullname, nil);
    ABRecordSetValue(person, kABPersonNoteProperty, NSLocalizedString(@"importedfrommoodle", @"an extra info added to iphone contact"), nil);

    // adding phone number
    ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    if (_participant.phone1)
    {
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, _participant.phone1, (CFStringRef)@"Phone", NULL);
    }
    if (_participant.phone2)
    {
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, _participant.phone2, (CFStringRef)@"Mobile", NULL);
    }
    ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
    CFRelease(phoneNumberMultiValue);

    // Adding emails
    if (_participant.email)
    {
        ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emailMultiValue, _participant.email, (CFStringRef)@"Work", NULL);
        ABRecordSetValue(person, kABPersonURLProperty, emailMultiValue, nil);
        CFRelease(emailMultiValue);
    }

    // Adding address
    ABMutableMultiValueRef addressMultipleValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
    NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
    if (_participant.address)
    {
        [addressDictionary setObject:_participant.address forKey:(NSString *)kABPersonAddressStreetKey];
    }
    if (_participant.city)
    {
        [addressDictionary setObject:_participant.city forKey:(NSString *)kABPersonAddressCityKey];
    }
//    [addressDictionary setObject:@"6000" forKey:(NSString *)kABPersonAddressZIPKey];
    if (_participant.country)
    {
        [addressDictionary setObject:_participant.country forKey:(NSString *)kABPersonAddressCountryKey];
    }
//    [addressDictionary setObject:@"au" forKey:(NSString *)kABPersonAddressCountryCodeKey];
    ABMultiValueAddValueAndLabel(addressMultipleValue, addressDictionary, kABHomeLabel, NULL);
    [addressDictionary release];
    ABRecordSetValue(person, kABPersonAddressProperty, addressMultipleValue, nil);
    CFRelease(addressMultipleValue);

    ABAddressBookAddRecord(addressBook, person, nil);
    ABAddressBookSave(addressBook, nil);
    CFRelease(person);
    CFRelease(addressBook);

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"contact", @"Contact") message:NSLocalizedString(@"contactadd", @"prompt user that contact has been added") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (UIViewController *)post:(NSDictionary *)query
{
    UIButton *btn = [query objectForKey:@"__target__"];
    NSString *title;

    if (btn.tag == TAG_BUTTON_SEND)
    {
        title = NSLocalizedString(@"sendmessage", @"");
    }
    else if (btn.tag == TAG_BUTTON_NOTE)
    {
        title = NSLocalizedString(@"addnote", @"");
    }
    else
    {
        title = @"";
    }
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"text", self, @"delegate", title, @"title", nil];

    TTPostController *controller = [[[TTPostController alloc] initWithNavigatorURL:nil query:options] autorelease];
    postControllerType = btn.tag;

    controller.originView = btn;

    return controller;
}

# pragma mark - TTPostControllerDelegate
/**
 * The user has posted text and an animation is about to show the text return to its origin.
 *
 * @return whether to dismiss the controller or wait for the user to call dismiss.
 */
- (BOOL)postController:(TTPostController *)postController willPostText:(NSString *)text
{
    return YES;
}

/**
 * The text has been posted.
 */
- (void)postController:(TTPostController *)postController
   didPostText:(NSString *)text
   withResult:(id)result
{
    // retrieve the participant information
    WSClient *client = [[WSClient alloc] init];
    NSArray *wsinfo;

    if (postControllerType == TAG_BUTTON_SEND)
    {
        NSNumber *userid = [self.participant valueForKey:@"userid"];
        NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys:userid, @"touserid", text, @"text", nil];
        NSArray *messages = [[NSArray alloc] initWithObjects:message, nil];
        NSArray *paramvalues = [[NSArray alloc] initWithObjects:messages, nil];
        NSArray *paramkeys = [[NSArray alloc] initWithObjects:@"messages", nil];
        NSDictionary *params = [[NSDictionary alloc] initWithObjects:paramvalues forKeys:paramkeys];
        [message release];
        [messages release];
        [paramvalues release];
        [paramkeys release];

        if (appDelegate.netStatus == NotReachable)
        {
            NSData *jsonData = [[CJSONSerializer serializer] serializeObject:params error:nil];
            NSString *data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", data);

            NSManagedObject *job = [[[NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:managedObjectContext] retain] autorelease];

            [job setValue:@"TaskHandler"    forKey:@"target"];
            [job setValue:@"sendMessage"    forKey:@"action"];
            [job setValue:text forKey:@"desc"];
            [job setValue:data forKey:@"data"];
            [job setValue:@"json"           forKey:@"dataformat"];
            [job setValue:@"undone"         forKey:@"status"];
            [job setValue:appDelegate.site forKey:@"site"];
            [job setValue:[NSDate date]     forKey:@"created"];
            NSError *error;
            if (![managedObjectContext save:&error])
            {
                NSLog(@"Error saving entity: %@", [error localizedDescription]);
            }

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkerror", @"") message:NSLocalizedString(@"cannotsendmessage", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"") otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else
        {
            @try {
                wsinfo = [client invoke:@"moodle_message_send_instantmessages" withParams:(NSArray *)params];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"messagesent", @"prompt user message has been sent") delegate:self cancelButtonTitle:NSLocalizedString(@"continue", @"") otherButtonTitles:nil];
                [alert show];
                [alert release];
                NSDictionary *msg = [wsinfo lastObject];
                if ([msg valueForKey:@"errormessage"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error") message:[[wsinfo lastObject] valueForKey:@"errormessage"] delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
            }
            @catch (NSException *exception) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate:self cancelButtonTitle:NSLocalizedString(@"continue", @"") otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
        [params release];
    }
    else if (postControllerType == TAG_BUTTON_NOTE)
    {
        NSNumber *userid = [_participant valueForKey:@"userid"];
        NSDictionary *note = [[NSDictionary alloc] initWithObjectsAndKeys:userid, @"userid", text, @"text", @"text", @"format", [self.course valueForKey:@"id"], @"courseid", @"personal", @"publishstate", nil];
        NSArray *notes = [[NSArray alloc] initWithObjects:note, nil];
        NSArray *paramvalues = [[NSArray alloc] initWithObjects:notes, nil];
        NSArray *paramkeys = [[NSArray alloc] initWithObjects:@"notes", nil];
        NSDictionary *params = [[NSDictionary alloc] initWithObjects:paramvalues forKeys:paramkeys];

        [note release];
        [notes release];
        [paramvalues release];
        [paramkeys release];
        if (appDelegate.netStatus == NotReachable)
        {
            NSData *jsonData = [[CJSONSerializer serializer] serializeObject:params error:nil];
            NSString *data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"%@", data);

            NSManagedObject *job = [[[NSEntityDescription insertNewObjectForEntityForName:@"Job" inManagedObjectContext:managedObjectContext] retain] autorelease];

            [job setValue:@"TaskHandler"    forKey:@"target"];
            [job setValue:@"addNote"        forKey:@"action"];
            [job setValue:text forKey:@"desc"];
            [job setValue:data forKey:@"data"];
            [job setValue:@"json"           forKey:@"dataformat"];
            [job setValue:@"undone"         forKey:@"status"];
            [job setValue:appDelegate.site forKey:@"site"];
            [job setValue:[NSDate date]     forKey:@"created"];
            NSError *error;
            if (![managedObjectContext save:&error])
            {
                NSLog(@"Error saving entity: %@", [error localizedDescription]);
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkerror", @"") message:NSLocalizedString(@"cannotaddnote", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"") otherButtonTitles:nil];
            alert.tag = ALERT_NOTE;
            [alert show];
            [alert release];
        }
        else
        {
            @try {
                wsinfo = [client invoke:@"moodle_notes_create_notes" withParams:(NSArray *)params];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"noteadded", @"Note added") delegate:self cancelButtonTitle:NSLocalizedString(@"continue", @"") otherButtonTitles:nil];
                [alert show];
                [alert release];
                NSDictionary *msg = [wsinfo lastObject];
                if ([msg valueForKey:@"errormessage"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error") message:[[wsinfo lastObject] valueForKey:@"errormessage"] delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
            }
            @catch (NSException *exception) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate:self cancelButtonTitle:NSLocalizedString(@"continue", @"") otherButtonTitles:nil];
                [alert show];
                [alert release];
            }

        }
        [params release];
    }
    else
    {
        // do nothing
        return;
    }
    [client release];
}

/**
 * The controller was cancelled before posting.
 */
- (void)postControllerDidCancel:(TTPostController *)postController
{
}



#pragma mark - View lifecycle

- (id)initWithNew:(NSString *)new
{
    if ((self = [self initWithStyle:UITableViewStyleGrouped]))
    {
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[TTNavigator navigator].URLMap from:@"tt://post" toViewController:self selector:@selector(post:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"details", nil);

    UIGestureRecognizer *recognizer;

    /*
     * Create a swipe gesture recognizer to recognize right swipes (the default).
     * We're only interested in receiving messages from this recognizer, and the view will take ownership of it, so we don't need to keep a reference to it.
     */
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [self.view addGestureRecognizer:recognizer];
    [recognizer release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.participant = nil;
    self.course = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[TTNavigator navigator].URLMap removeURL:@"tt://post"];
}

- (void)dealloc
{
    [contactinfo release];
    [geoinfo release];
    [self.participant release];
    [self.course release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = [appDelegate managedObjectContext];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"update", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(clickedUploadButton:)] autorelease];

    [self initialiseTableData];
    // Scroll the table view to the top before it appears
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    self.tableView.autoresizesSubviews = YES;

    [self setupTableHeader];
    [self setupTableFooter];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - guesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

/*
 * In response to a swipe gesture, show the image view appropriately then move the image view in the direction of the swipe as it fades out.
 */
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];

    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        location.x -= 220.0;
    }
    else
    {
        location.x += 220.0;
    }

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.55];
    [UIView commitAnimations];
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // There are three sections, for date, genre, and characters, in that order.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
     * The number of rows varies by section.
     */
    NSInteger rows = 0;

    switch (section)
    {
        case 0:
            rows = 1;
            break;

        case 1:
            rows = [contactinfo count];
            break;

        case 2:
            rows = [geoinfo count];
            break;

        default:
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
    }

    // Set the text in the cell for the section/row.

    NSString *cellText = nil;
    NSDictionary *info;
    switch (indexPath.section)
    {
        case 0:
            break;

        case 1:
            info = [contactinfo objectAtIndex:indexPath.row];
            break;

        case 2:
            info = [geoinfo objectAtIndex:indexPath.row];
            break;

        default:
            break;
    }

    if (indexPath.section == 0)
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero] autorelease];
        NSString *desc = [self.participant valueForKey:@"desc"];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setLineBreakMode:UILineBreakModeWordWrap];
        [label setMinimumFontSize:FONT_SIZE];
        [label setNumberOfLines:0];
        [label setFont:[UIFont systemFontOfSize:FONT_SIZE]];
        [label setTag:1];
        [[cell contentView] addSubview:label];

        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);

        CGSize textSize;
        if ([desc stringByRemovingHTMLTags] == nil || [[desc stringByRemovingHTMLTags] isEqualToString:@""])
        {
            textSize = CGSizeMake(0, 0);
        }
        else
        {
            textSize = [[desc stringByRemovingHTMLTags] sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        }

        if (!label)
        {
            label = (UILabel *)[cell viewWithTag:1];
        }
        [label setText:[desc stringByRemovingHTMLTags]];
        [label setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAX(textSize.height, 44.0f))];
    }
    else
    {
        NSString *key;
        // contact and location
        key = [[info allKeys] lastObject];
        cell.textLabel.text = NSLocalizedString(key, key);

        cellText = [[info valueForKey:key] stringByRemovingHTMLTags];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.numberOfLines = 0;

        CGSize constraint = CGSizeMake(200.0f, 20000.0f);
        CGSize textSize;
        if ([cellText stringByRemovingHTMLTags] == nil || [[cellText stringByRemovingHTMLTags] isEqualToString:@""])
        {
            textSize = CGSizeMake(0, 0);
        }
        else
        {
            textSize = [[cellText stringByRemovingHTMLTags] sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        }
        // 12 => inside cell margin * 2
        CGRect detailTextFrame = cell.detailTextLabel.frame;
        detailTextFrame.size.height = MAX(textSize.height + 12, 44.0f);
        [cell.detailTextLabel setFrame:detailTextFrame];
        cell.detailTextLabel.text = cellText;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.section == 0)
    {
        NSString *text = [[self.participant valueForKey:@"desc"] stringByRemovingHTMLTags];
        if (text == nil)
        {
            text = @"";
        }

        CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);

        CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];

        CGFloat height = MAX(textSize.height, 44.0f);
        return height + (CELL_CONTENT_MARGIN * 2);
    }

    NSDictionary *info;
    switch (indexPath.section)
    {

        case 1:
            info = [contactinfo objectAtIndex:indexPath.row];
            break;

        case 2:
            info = [geoinfo objectAtIndex:indexPath.row];
            break;

        default:
            break;
    }
    NSString *key = [[info allKeys] lastObject];
    NSString *text = [info valueForKey:key];
    CGSize constraint = CGSizeMake(200, 20000.0f);
    if (text == nil)
    {
        text = @"";
    }

    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];

    CGFloat height = MAX(textSize.height + (CELL_CONTENT_MARGIN * 2) + 12, 44.0f);

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (cell.detailTextLabel.text == nil)
    {
        return;
    }
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingAllTypes error:nil];
    NSArray *matches = [detector matchesInString:cell.detailTextLabel.text
                                         options:0
                                           range:NSMakeRange(0, [cell.detailTextLabel.text length])];
    for (NSTextCheckingResult *match in matches)
    {
        if ([match resultType] == NSTextCheckingTypeLink)
        {
            NSURL *url = [match URL];
            if ([url.scheme isEqualToString:@"mailto"])
            {
                // mail to
                [self displayComposerSheet:cell.detailTextLabel.text];
            }
            else
            {
                // other scheme including http, https
                [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:[url absoluteString]]];
            }
        }
        else if ([match resultType] == NSTextCheckingTypePhoneNumber)
        {
            NSString *phoneNumber = [NSString stringWithFormat:@"%@/%@", @"tel://", [match phoneNumber]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        }
        else if ([match resultType] == NSTextCheckingTypeAddress)
        {
            NSString *country = [self.participant valueForKey:@"country"];
            NSString *city = [self.participant valueForKey:@"city"];
            NSString *fulladdress = [NSString stringWithFormat:@"%@ %@ %@", cell.detailTextLabel.text, city, country];
            MapViewController *mapView = [[MapViewController alloc] initWithAddress:fulladdress withName:[self.participant valueForKey:@"fullname"]];
            [self.navigationController pushViewController:mapView animated:YES];
            [mapView release];
        }
    }
}

#pragma mark -
#pragma mark Section header titles

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;

    switch (section)
    {
        case 0:
            title = NSLocalizedString(@"description", @"User's Description");
            break;

        case 1:
            title = NSLocalizedString(@"contact", @"User's Contact info");
            break;

        case 2:
            title = NSLocalizedString(@"location", @"User's geo location");
            break;

        default:
            break;
    }
    return title;
}

#pragma mark - SDWebImage delegate

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    userpicture.image = image;
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden
{
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

#pragma mark - dismiss mail composer
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
