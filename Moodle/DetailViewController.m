//
//  DetailViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 16/06/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "DetailViewController.h"
#import "Reachability.h"
#import "WSClient.h"
#import "Constants.h"

// temp fix for https://github.com/facebook/three20/issues/194
#import <Three20UINavigator/UIViewController+TTNavigator.h> 


#pragma mark - view controller


@implementation DetailViewController


@synthesize participant=_participant;
@synthesize course=_course;

- (void)addContact {
    ABAddressBookRef addressBook = ABAddressBookCreate();
    ABRecordRef person = ABPersonCreate();
    ABRecordSetValue(person, kABPersonFirstNameProperty, _participant.fullname, nil);
    ABRecordSetValue(person, kABPersonNoteProperty, @"Imported from moodle", nil);  
    
    // adding phone number
    ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    if (_participant.phone1)
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, _participant.phone1, (CFStringRef)@"Phone", NULL);
    if (_participant.phone2)
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, _participant.phone2, (CFStringRef)@"Mobile", NULL);
    ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil);
    CFRelease(phoneNumberMultiValue);
    
    // Adding emails
    ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    ABMultiValueAddValueAndLabel(emailMultiValue, _participant.email, (CFStringRef)@"Work", NULL);
    ABRecordSetValue(person, kABPersonURLProperty, emailMultiValue, nil);
    CFRelease(emailMultiValue);
    
    // Adding address  
    ABMutableMultiValueRef addressMultipleValue = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);  
    NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
    if (_participant.address)
        [addressDictionary setObject:_participant.address forKey:(NSString *)kABPersonAddressStreetKey];
    if (_participant.city)
        [addressDictionary setObject:_participant.city forKey:(NSString *)kABPersonAddressCityKey];  
//    [addressDictionary setObject:@"6000" forKey:(NSString *)kABPersonAddressZIPKey];
    if (_participant.country)
        [addressDictionary setObject:_participant.country forKey:(NSString *)kABPersonAddressCountryKey];  
//    [addressDictionary setObject:@"au" forKey:(NSString *)kABPersonAddressCountryCodeKey];  
    ABMultiValueAddValueAndLabel(addressMultipleValue, addressDictionary, kABHomeLabel, NULL);  
    [addressDictionary release];  
    ABRecordSetValue(person, kABPersonAddressProperty, addressMultipleValue, nil);  
    CFRelease(addressMultipleValue);  

    ABAddressBookAddRecord(addressBook, person, nil);
    ABAddressBookSave(addressBook, nil);
    CFRelease(person);

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Contact" message:@"Contact added" delegate: self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (UIViewController*)post: (NSDictionary *)query {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"text", self, @"delegate", nil];
    TTPostController* controller = [[[TTPostController alloc] initWithNavigatorURL: nil query: options] autorelease];
    UIButton *btn = [query objectForKey:@"__target__"];
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
- (BOOL)postController:(TTPostController*)postController willPostText:(NSString*)text {
    return YES;
}

/**
 * The text has been posted.
 */
- (void)postController: (TTPostController*)postController
           didPostText: (NSString*)text
            withResult: (id)result {
    
    //retrieve the participant information
    WSClient *client   = [[WSClient alloc] init];
    NSArray *wsinfo;
    if (postControllerType == 1) {
        NSNumber *userid   = [self.participant valueForKey:@"userid"];
        NSDictionary *message = [[NSDictionary alloc] initWithObjectsAndKeys: userid, @"touserid", text, @"text", nil];
        NSArray *messages = [[NSArray alloc] initWithObjects: message, nil];
        NSArray *paramvalues = [[NSArray alloc] initWithObjects: messages, nil];
        NSArray *paramkeys   = [[NSArray alloc] initWithObjects:@"messages", nil];
        NSDictionary *params = [[NSDictionary alloc] initWithObjects: paramvalues forKeys:paramkeys];
        @try {
            wsinfo = [client invoke: @"moodle_message_send_instantmessages" withParams: (NSArray *)params];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        [message release];
        [messages release];
        [paramvalues release];
        [paramkeys release];
        [params release];
    } else {
        NSNumber *userid   = [self.participant valueForKey:@"userid"];
        NSDictionary *note = [[NSDictionary alloc] initWithObjectsAndKeys: userid, @"userid", text, @"text", @"text", @"format", [self.course valueForKey:@"id"], @"courseid", @"personal", @"publishstate", nil];
        NSArray *notes = [[NSArray alloc] initWithObjects: note, nil];
        NSArray *paramvalues = [[NSArray alloc] initWithObjects: notes, nil];
        NSArray *paramkeys   = [[NSArray alloc] initWithObjects:@"notes", nil];
        NSDictionary *params = [[NSDictionary alloc] initWithObjects: paramvalues forKeys:paramkeys];
        @try {
            wsinfo = [client invoke: @"moodle_notes_create_notes" withParams: (NSArray *)params];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        [note release];
        [notes release];
        [paramvalues release];
        [paramkeys release];
        [params release];
    }
    NSDictionary *msg = [wsinfo lastObject];
    if ([msg valueForKey:@"errormessage"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[[wsinfo lastObject] valueForKey:@"errormessage"] delegate:self cancelButtonTitle: @"cancel" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    [client release];
}
/**
 * The controller was cancelled before posting.
 */
- (void)postControllerDidCancel:(TTPostController*)postController {
    
}

- (void)dealloc
{
    [contactinfo release];
    [geoinfo release];
    [self.participant release];
    [self.course release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (id)initWithNew: (NSString *)new {
    if ((self = [self initWithStyle:UITableViewStyleGrouped])) {
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
-(NSDictionary *)createInfo: (NSString *) key value: (NSString *)value {
    NSDictionary *dict = [[[NSDictionary alloc] initWithObjectsAndKeys:value, key, nil] autorelease];
    return dict;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    contactinfo = [[NSMutableArray alloc] init];
    if ([self.participant valueForKey: @"email"]) {
        [contactinfo addObject:[self createInfo:@"email" value:[self.participant valueForKey: @"email"]]];
    }
    if ([self.participant valueForKey: @"phone1"]) {
        [contactinfo addObject:[self createInfo:@"phone1" value:[self.participant valueForKey: @"phone1"]]];
    }
    if ([self.participant valueForKey: @"phone2"]) {
        [contactinfo addObject:[self createInfo:@"phone2" value:[self.participant valueForKey: @"phone2"]]];
    }
    geoinfo = [[NSMutableArray alloc] init];
    if ([self.participant valueForKey: @"country"]) {
        [geoinfo addObject:[self createInfo:@"country" value:[self.participant valueForKey: @"country"]]];
    }
    if ([self.participant valueForKey: @"city"]) {
        [geoinfo addObject:[self createInfo:@"city" value:[self.participant valueForKey: @"city"]]];
    }
    if ([self.participant valueForKey: @"address"]) {
        [geoinfo addObject:[self createInfo:@"address" value:[self.participant valueForKey: @"address"]]];
    }
    
    
    UIGestureRecognizer *recognizer;
	
    /*
     Create a swipe gesture recognizer to recognize right swipes (the default).
     We're only interested in receiving messages from this recognizer, and the view will take ownership of it, so we don't need to keep a reference to it.
     */
	recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	[self.view addGestureRecognizer:recognizer];
	[recognizer release];
    

    [[TTNavigator navigator].URLMap from:@"tt://post" toViewController:self selector:@selector(post:)];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.participant = nil;
    self.course = nil;
    [[TTNavigator navigator].URLMap removeURL:@"tt://post"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateParticipant];
    // Scroll the table view to the top before it appears
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    self.tableView.autoresizesSubviews = YES;
    
    CGRect size = self.tableView.frame;
    NSInteger margin = 20;
    UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(margin, margin, size.size.width-margin*2, 120)] autorelease];
    
    // user picture
    userpicture = [[[UIImageView alloc] initWithFrame:CGRectMake(margin, margin, 100, 100)] autorelease];
    
    userpicture.layer.cornerRadius = 9.0;
    userpicture.layer.masksToBounds = YES;
    userpicture.layer.borderColor = UIColorFromRGB(ColorBackground).CGColor;
    userpicture.layer.borderWidth = 3.0;

    NSURL *url = [NSURL URLWithString: [self.participant valueForKey:@"profileimageurl"]];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    UIImage *cachedImage = [manager imageWithURL:url];
    
    if (cachedImage)
    {
        userpicture.image = cachedImage;
    }
    else
    {
//        userpicture.image =  
        NSLog(@"URL: %@", url);
        [manager downloadWithURL:url delegate:self];
    }
    
    // user fullname
    UILabel *fullname = [[[UILabel alloc] initWithFrame:CGRectMake(margin+100+20, margin, size.size.width-margin*2-100, 100)] autorelease];
    fullname.text = [self.participant valueForKey:@"fullname"];
    fullname.backgroundColor = [UIColor clearColor];
    fullname.font = [UIFont fontWithName:@"Arial-BoldMT" size:24.0];
    
    [containerView addSubview: userpicture];
    [containerView addSubview: fullname];
    self.tableView.tableHeaderView = containerView;
    
    float button_width = 130;
    tableviewFooter = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 120)];
    tableviewFooter.userInteractionEnabled = YES;
    
    UIButton *buttonSendMsg = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonSendMsg setTitle:@"Send Message" forState: UIControlStateNormal];
    [buttonSendMsg setFrame:CGRectMake(margin, 0, button_width, 50)];
    buttonSendMsg.tag = 1;
    //    [buttonSendMsg addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
    [buttonSendMsg addTarget:@"tt://post" action:@selector(openURLFromButton:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonAddNote = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonAddNote setTitle:@"Add Note" forState: UIControlStateNormal];
    [buttonAddNote setFrame:CGRectMake(self.view.frame.size.width-margin-button_width, 0, button_width, 50)];
    buttonAddNote.tag = 2;
    [buttonAddNote addTarget:@"tt://post" action:@selector(openURLFromButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *buttonRefresh = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonRefresh setTitle:@"Update" forState: UIControlStateNormal];
    [buttonRefresh addTarget:self action:@selector(updateParticipant) forControlEvents:UIControlEventTouchUpInside];
    [buttonRefresh setFrame:CGRectMake(margin, 60, button_width, 50)];
    buttonRefresh.tag = 3;
    
    UIButton *buttonAddContact = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [buttonAddContact setTitle:@"Add contact" forState: UIControlStateNormal];
    [buttonAddContact addTarget:self action:@selector(addContact) forControlEvents:UIControlEventTouchUpInside];
    [buttonAddContact setFrame:CGRectMake(self.view.frame.size.width-margin-button_width, 60, button_width, 50)];
    buttonAddContact.tag = 4;
    
    [tableviewFooter addSubview:buttonSendMsg];
    [tableviewFooter addSubview:buttonAddNote];
    [tableviewFooter addSubview:buttonRefresh];
    [tableviewFooter addSubview:buttonAddContact];

    [self.tableView setTableFooterView:tableviewFooter];
    [tableviewFooter release];
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    return YES;
}

/*
 In response to a swipe gesture, show the image view appropriately then move the image view in the direction of the swipe as it fades out.
 */
- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    
	CGPoint location = [recognizer locationInView:self.view];
	
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        location.x -= 220.0;
    }
    else {
        location.x += 220.0;
    }
    NSLog(@"swiped!!!");
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.55];
	[UIView commitAnimations];
}
#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // There are three sections, for date, genre, and characters, in that order.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	/*
	 The number of rows varies by section.
	 */
    NSInteger rows = 0;
    switch (section) {
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

- (void)configureCell {

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Cache a date formatter to create a string representation of the date object.
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy"];
    }
    
    // Set the text in the cell for the section/row.
    
    NSString *cellText = nil;
    NSDictionary *info;
    NSString *key;
    switch (indexPath.section) {
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
    if (indexPath.section == 1 || indexPath.section == 2) {
        key = [[info allKeys] lastObject];

        
        CGRect labelFrame = CGRectMake(10, 4, 70, 32);
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:labelFrame];
        labelView.text = NSLocalizedString(key, key);
        [labelView setTextAlignment: UITextAlignmentRight];
        [labelView setFont:[UIFont boldSystemFontOfSize:16.0]];
        
        CGRect textviewFrame = CGRectMake(90, 2, 200, 32);
        UITextView *textView = [[UITextView alloc] initWithFrame:textviewFrame];
        cellText = [info valueForKey: key];
        [textView setText:cellText];
        [textView setEditable:NO];
        [textView setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [textView setDataDetectorTypes: UIDataDetectorTypeAll];
        [textView setScrollEnabled:NO];
        [cell.contentView addSubview:textView];
        [cell.contentView addSubview:labelView];
        [textView release];
    } else if (indexPath.section == 0) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.text = [self.participant valueForKey:@"desc"];
    }
    return cell;
}


#pragma mark -
#pragma mark Section header titles

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
    switch (section) {
        case 0:
            title = NSLocalizedString(@"description", @"Description");
            break;
        case 1:
            title = NSLocalizedString(@"Contact", @"Contact info");
            break;
        case 2:
            title = NSLocalizedString(@"Location", @"Location");
            break;
        default:
            break;
    }
    return title;
}


// load user
-(void)updateParticipant {
    WSClient *client   = [[WSClient alloc] init];
    
    // build individual user
    NSNumber *userid   = [self.participant valueForKey:@"userid"];
    NSNumber *courseid = [self.course      valueForKey:@"id"];
    NSDictionary *user = [[NSDictionary alloc] initWithObjectsAndKeys: userid, @"userid", courseid, @"courseid", nil];
    
    // build user list, we have only one user
    NSArray *userlist = [[NSArray alloc] initWithObjects: user, nil];

    NSArray *vals = [[NSArray alloc] initWithObjects: userlist,    nil];
    NSArray *keys = [[NSArray alloc] initWithObjects: @"userlist", nil];

    NSDictionary *params = [[NSDictionary alloc] initWithObjects:vals forKeys:keys];
    NSArray *result;
    @try {
        result = [client invoke: @"moodle_user_get_course_participants_by_id" withParams: (NSArray *)params];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }

    [user release];
    [userlist release];
    [vals release];
    [keys release];
    [client release];

    if (result && [result isKindOfClass:[NSArray class]]) {
        for (NSDictionary *theparticipant in result) {
            [Participant update:self.participant dict:theparticipant course:nil];
        }
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    userpicture.image = image;
}
@end