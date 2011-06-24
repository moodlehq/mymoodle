//
//  RootViewController.m
//  Moodle
//
//  Created by jerome Mouneyrac on 17/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "RootViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "MoodleStyleSheet.h"
#import "Course.h"

@implementation RootViewController

/**
 * "Sites" button action
 *
 */
-(void)displaySettingsView {
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath: @"tt://sites/"] applyAnimated:YES]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    UIBarButtonItem *sitesButton = [[UIBarButtonItem alloc]
                                    initWithTitle:@"Sites"
                                    style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(displaySettingsView)];
    self.navigationItem.rightBarButtonItem = sitesButton;
    [sitesButton release];

}

/**
 * Set up dashboard
 *
 */
- (void)loadView {
    [super loadView];
    self.view.backgroundColor = UIColorFromRGB(ColorBackground);
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    NSLog(@"%@", NSStringFromCGRect(rect));
    launcherView = [[TTLauncherView alloc] initWithFrame: self.view.bounds];
    launcherView.columnCount = 2;
    webLauncherItem = [[TTLauncherItem alloc] initWithTitle:NSLocalizedString(@"Web", "Web")
                                                        image:@"bundle://ToolGuide.png"
                                                        URL:@"" canDelete: NO];
    webLauncherItem.style = @"MoodleLauncherButton:";
    launcherView.pages = [NSArray arrayWithObjects:
                            [NSArray arrayWithObjects:
                                [self launcherItemWithTitle:NSLocalizedString(@"Upload", "Upload") image: @"bundle://Upload.png" URL:@"tt://upload/"],
                                [self launcherItemWithTitle:NSLocalizedString(@"Participants", "Participants") image: @"bundle://Participants.png" URL:@"tt://participants/"],
                                webLauncherItem,
                                [self launcherItemWithTitle:NSLocalizedString(@"Help", "Help") image: @"bundle://MoodleHelp.png" URL:@"http://docs.moodle.org/"],
                                nil]
                          , nil];
    launcherView.delegate = self;
    launcherView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height-80);

    [self.view addSubview: launcherView];

    TTButton *syncButton = [TTButton buttonWithStyle:@"notificationButton:" title: @""];
    [syncButton setImage:@"bundle://sync.png" forState:UIControlStateNormal];
    [syncButton addTarget:self
               action:@selector(launchNotification:) forControlEvents: UIControlEventTouchUpInside];

    syncButton.frame = CGRectMake(0, rect.size.height - 80, rect.size.width+10, 36.0);
    [self.view addSubview: syncButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [webLauncherItem setURL:[[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteUrlKey]];
    self.navigationBarTintColor = UIColorFromRGB(ColorNavigationBar);
    self.title = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteNameKey];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *defaultSiteUrl = [[NSUserDefaults standardUserDefaults] objectForKey: kSelectedSiteUrlKey];
    if (defaultSiteUrl == nil || appDelegate.site == nil) {
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
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    settingsViewController = nil;
    launcherView = nil;
    webLauncherItem = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    // release view controllers
    [settingsViewController release];
    [launcherView release];
    [webLauncherItem release];
    [super dealloc];
}
- (void)launchNotification: (id)sender {
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://sync/"] applyAnimated:YES]];
}

#pragma mark -
#pragma mark Private methods
- (TTLauncherItem *)launcherItemWithTitle:(NSString *)pTitle image:(NSString *)image URL:(NSString *)url {
	TTLauncherItem *launcherItem = [[TTLauncherItem alloc] initWithTitle:pTitle
																   image:image
																	 URL:url canDelete:NO];
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
	self.navigationItem.leftBarButtonItem = nil;
}

- (void)launcherView:(TTLauncherView *)launcher didSelectItem:(TTLauncherItem *)item {
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:item.URL] applyAnimated:YES]];
}

@end
