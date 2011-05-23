//
//  RootViewController.m
//  Moodle
//
//  Created by jerome Mouneyrac on 17/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "RootViewController.h"
#import "Config.h"
#import "AppDelegate.h"
#import "MoodleStyleSheet.h"



@implementation RootViewController

@synthesize managedObjectContext=__managedObjectContext;

-(void)displaySettingsView {
    if (settingsViewController == nil) {
        settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    settingsViewController.managedObjectContext = self.managedObjectContext;
    //set the dashboard back button just before to push the settings view
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"dashboard", "dashboard") style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
    [self.navigationController pushViewController:settingsViewController animated:YES];
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
    
}

- (void)loadView {
    [TTStyleSheet setGlobalStyleSheet:[[[MoodleStyleSheet alloc] init] autorelease]];
    [super loadView];
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
//    UIImageView *contentView = [[UIImageView alloc] initWithFrame: rect];
//    [contentView setImage:[UIImage imageNamed:@"view_bg.jpg"]];
//    [contentView setUserInteractionEnabled:YES];
//    self.view = contentView;
//    [contentView release];

    launcherView = [[TTLauncherView alloc]
                                    initWithFrame:self.view.bounds];
    launcherView.backgroundColor = UIColorFromRGB(ColorBackground);
    launcherView.columnCount = 2;
    launcherView.pages = [NSArray arrayWithObjects:
                            [NSArray arrayWithObjects:
                                [self launcherItemWithTitle:NSLocalizedString(@"Upload", "Upload") image: @"bundle://Upload.png" URL:@"tt://upload/"],
                                [self launcherItemWithTitle:NSLocalizedString(@"Participants", "Participants") image: @"bundle://Participants.png" URL:@"tt://participants/"],
                                [self launcherItemWithTitle:NSLocalizedString(@"Web", "Web") image: @"bundle://ToolGuide.png" URL:[[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteUrlKey]],
                                [self launcherItemWithTitle:NSLocalizedString(@"Help", "Help") image: @"bundle://MoodleHelp.png" URL:@"http://docs.moodle.org/"],
                                nil]
                          , nil];
    launcherView.delegate = self;
    
    [self.view addSubview: launcherView];
    TTButton *button = [TTButton buttonWithStyle:@"notificationButton:" title: NSLocalizedString(@"Sync", "Sync") ];
    [button addTarget:self
               action:@selector(launchNotification:) forControlEvents:UIControlEventTouchDown];
    button.frame = CGRectMake(-5, rect.size.height-72.0, rect.size.width+10, 36.0);
    [self.view addSubview:button];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationBarTintColor = UIColorFromRGB(ColorNavigationBar);
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
    settingsViewController = nil;
    [super viewDidUnload];
    [launcherView release];
    launcherView = nil;
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
    // release view controllers
    [settingsViewController release];
    [__managedObjectContext release];
    [super dealloc];
}

#pragma mark -
#pragma mark Private methods



- (TTLauncherItem *)launcherItemWithTitle:(NSString *)pTitle image:(NSString *)image URL:(NSString *)url {
	TTLauncherItem *launcherItem = [[TTLauncherItem alloc] initWithTitle:pTitle 
																   image:image
																	 URL:url canDelete:YES];
    launcherItem.canDelete = NO;
    launcherItem.style = @"MoodleLauncherButton:";
	return [launcherItem autorelease];
}


#pragma mark -
#pragma mark TTLauncherViewDelegate methods

- (void)launcherViewDidBeginEditing:(TTLauncherView*)launcher {
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:launcherView action:@selector(endEditing)];
	self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
}

- (void)launcherViewDidEndEditing:(TTLauncherView*)launcher {
	//UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:launcherView action:@selector(endEditing)];
	self.navigationItem.leftBarButtonItem = nil;
	//[editButton release];
}

- (void)launcherView:(TTLauncherView *)launcher didSelectItem:(TTLauncherItem *)item {
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:item.URL] applyAnimated:YES]];        
}
- (void)launchNotification: (id)sender {
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://notification/"] applyAnimated:YES]];        
}
@end
