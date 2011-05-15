//
//  RootViewController.m
//  Moodle
//
//  Created by jerome Mouneyrac on 17/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "RootViewController.h"
#import "Config.h"

@implementation RootViewController

@synthesize managedObjectContext=__managedObjectContext;
@synthesize modules;

-(void)displaySettingsView {
    if (settingsViewController == nil) {
        settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    settingsViewController.managedObjectContext = self.managedObjectContext;
    //set the dashboard back button just before to push the settings view
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"dashboard", "dashboard") style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

/**
 * Display upload interface
 *
 */
-(IBAction)displayUploadView: (id)sender {
    if (uploadViewController== nil) {
        uploadViewController = [[UploadViewController alloc] init];
    }
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"dashboard", "dashboard") style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
    [self.navigationController pushViewController:uploadViewController animated:YES];
}

/**
 * Display participants view
 *
 */
-(IBAction)displayParticipantsView:(id)sender {
    if (participantsViewController == nil) {
        participantsViewController = [[ParticipantsViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    participantsViewController.managedObjectContext = self.managedObjectContext;
    //set the dashboard back button just before to push the settings view
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"dashboard", "dashboard") style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
    [self.navigationController pushViewController:participantsViewController animated:YES];
    
}

/**
 * Set up dashboard
 *
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *sitesButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Sites"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(displaySettingsView)];
    self.navigationItem.rightBarButtonItem = sitesButton;
    [sitesButton release];
    NSDictionary *grade        = [[NSDictionary alloc] initWithObjectsAndKeys:@"Grade.png", @"icon",
                                  NSLocalizedString(@"grade", "grade"), @"title", nil];
    NSDictionary *message      = [[NSDictionary alloc] initWithObjectsAndKeys:@"Message.png", @"icon",
                                  NSLocalizedString(@"message", "message"), @"title", nil];
    NSDictionary *calendar     = [[NSDictionary alloc] initWithObjectsAndKeys:@"Calendar.png", @"icon",
                                  NSLocalizedString(@"calendar", "calendar"), @"title", nil];
    NSDictionary *upload       = [[NSDictionary alloc] initWithObjectsAndKeys:@"Upload.png", @"icon",
                                  NSLocalizedString(@"upload", "upload"), @"title", nil];
    NSDictionary *participants = [[NSDictionary alloc] initWithObjectsAndKeys:@"Participants.png", @"icon",
                                  NSLocalizedString(@"participants", "participants"), @"title", nil];
    NSDictionary *attendance   = [[NSDictionary alloc] initWithObjectsAndKeys:@"Attendance.png", @"icon",
                                  NSLocalizedString(@"attendance", "attendance"), @"title", nil];
    NSDictionary *poll         = [[NSDictionary alloc] initWithObjectsAndKeys:@"Poll.png",   @"icon",
                                  NSLocalizedString(@"poll", "poll"),       @"title", nil];
    NSDictionary *toolguide    = [[NSDictionary alloc] initWithObjectsAndKeys:@"ToolGuide.png",     @"icon",
                                  NSLocalizedString(@"toolguide", "toolguide"), @"title", nil];
    NSDictionary *moodlehelp   = [[NSDictionary alloc] initWithObjectsAndKeys:@"MoodleHelp.png", @"icon",
                                  NSLocalizedString(@"moodlehelp", "moodlehelp"), @"title", nil];
    NSArray *array = [NSArray arrayWithObjects:
                      grade,
                      message,
                      calendar,
                      upload,
                      participants,
                      attendance,
                      poll,
                      toolguide,
                      moodlehelp, nil];
    self.modules = array;
    [grade release];
    [message release];
    [calendar release];
    [upload release];
    [participants release];
    [attendance release];
    [poll release];
    [toolguide release];
    [moodlehelp release];
    [array release];
    
    UIButton *icon;
    UILabel  *label;
    int top = 20;
    int left = 30;
    int h_span = 42;
    int v_span = 24;
    int frame_width = 59;
    int frame_height = 75;
    int label_height = 16;
    int label_width = frame_width;
    for (int i=0; i<[modules count]; i++) {
        CGRect frame;
        NSDictionary *module = [modules objectAtIndex:i];
        icon = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [icon setImage:[UIImage imageNamed:[module valueForKey:@"icon"]] forState:UIControlStateNormal];        
        icon.tag = i;
        
        frame.size.width = frame_width;
        frame.size.height = frame_height;
        frame.origin.x = (i%3)*(frame_width+h_span)+left;
        frame.origin.y = floor(i/3)*(frame_height+v_span)+top;
        [icon setFrame:frame];
        
        CGRect labelFrame;
        labelFrame.size.width = label_width;
        labelFrame.size.height = label_height;
        labelFrame.origin.x = frame.origin.x;
        labelFrame.origin.y = frame.origin.y + frame.size.height;
        label = [[UILabel alloc] initWithFrame:labelFrame];
        [label setText:[module valueForKey:@"title"]];
        label.font = [UIFont systemFontOfSize:11];
        label.shadowColor = [UIColor grayColor];
        label.shadowOffset = CGSizeMake(0,1);
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        
        [icon setBackgroundColor:[UIColor clearColor]];
        [icon addTarget:self action:@selector(iconPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:icon];
        [self.view addSubview:label];
        
        // release objects
        [icon release];
        [label release];
    }

    self.title = @"Moodle.org";
}

- (void)loadView {
    UIImageView *contentView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [contentView setImage:[UIImage imageNamed:@"view_bg.jpg"]];
    [contentView setUserInteractionEnabled:YES];
    self.view = contentView;
    [contentView release];
}

-(void)iconPressed:(id)sender{
    UIButton *Btn = (UIButton *)sender;
    int index = Btn.tag;
    switch (index) {
        case 3:
            [self displayUploadView:sender];
            break;
        case 4:
            [self displayParticipantsView:sender];
            break;
        default:
            NSLog(@"ICON %d pressed", index);
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteNameKey];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //if there is no site selected go to the site selection
    NSString *defaultSiteUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteUrlKey];
    if (defaultSiteUrl == nil) {
        [self displaySettingsView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    self.modules = nil;
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    [self.modules release];
//    [__fetchedResultsController release];
    [__managedObjectContext release];
    [settingsViewController release];
    [super dealloc];
}

@end
