//
//  RootViewController.m
//  Moodle
//
//  Created by Jerome Mouneyrac on 17/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "RootViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "MoodleStyleSheet.h"
#import "MoodleJob.h"
#import "Course.h"


@implementation RootViewController

/**
 * "Sites" button action
 *
 */
- (void)displaySettingsView {
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath: @"tt://sites/"] applyAnimated:YES]];
}

- (void)launchNotification {
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath: @"tt://sync/"] applyAnimated:YES]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

/**
 * Set up dashboard
 *
 */
- (void)loadView {

    [super loadView];
    
    self.navigationBarTintColor = UIColorFromRGB(ColorNavigationBar);

    CGRect appRect = [UIScreen mainScreen].applicationFrame;
    NSLog(@"app frame: %@", NSStringFromCGRect(appRect));
    NSLog(@"viewp frame: %@", NSStringFromCGRect(self.view.frame));


    // app background
    UIImageView *appBg = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"screen_bg.png"]];
    appBg.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    CGRect view = self.view.frame;
    [self.view addSubview:appBg];
    [appBg release];

    // Header
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake((appRect.size.width-240)/2, 35, 240, 34)];
    [header setText:@"moodle"];
    [header setTextColor:UIColorFromRGB(ColorToolbar)];
    [header setFont:[UIFont fontWithName:@"SoulPapa" size:46]];
    [header setBackgroundColor:[UIColor clearColor]];
    [header setTextAlignment:UITextAlignmentCenter];
    [self.view addSubview:header];
    [header release];

    int headerHeight = 65;

    int bgWidth = 276;
    int bgHeight = 280;
    UIImageView *rootBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"root_bg.png"]];
    rootBackground.frame = CGRectMake((view.size.width-276)/2, appRect.origin.y+headerHeight, bgWidth, bgHeight);
    [self.view addSubview: rootBackground];
    [rootBackground release];

    CGRect launcherFrame = CGRectMake(rootBackground.frame.origin.x+10, rootBackground.frame.origin.y+30, bgWidth-20, bgHeight+40);
    launcherView = [[TTLauncherView alloc] initWithFrame: launcherFrame];
    launcherView.columnCount = 2;
    webLauncherItem = [[TTLauncherItem alloc] initWithTitle:NSLocalizedString(@"Web", "Web")
                                                        image:@"bundle://Web.png"
                                                        URL:@"" canDelete: NO];
    webLauncherItem.style = @"MoodleLauncherButton:";
    launcherView.pages = [NSArray arrayWithObjects:
                            [NSArray arrayWithObjects:
                                [self launcherItemWithTitle:NSLocalizedString(@"Upload", "Upload") image: @"bundle://Upload.png" URL:@"tt://upload/"],
                                [self launcherItemWithTitle:NSLocalizedString(@"Participants", "Participants") image: @"bundle://Participants.png" URL:@"tt://participants/"],
                                webLauncherItem,
                                [self launcherItemWithTitle:NSLocalizedString(@"Help", "Help") image: @"bundle://MoodleHelp.png" URL:URL_MOODLE_HELP],
                                nil]
                          , nil];
    launcherView.delegate = self;
    [self.view addSubview: launcherView];
    
    //defautl toolbar height: 44
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(10, view.size.height - 40, view.size.width-20, 33)];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:toolbar.bounds 
                                                byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                                                        cornerRadii:CGSizeMake(10.0, 10.0)];
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = toolbar.bounds;
    maskLayer.path = maskPath.CGPath;
    // Set the newly created shape layer as the mask for the image view's layer
    toolbar.layer.mask = maskLayer;
    toolbar.tintColor = UIColorFromRGB(ColorToolbar);
    
    btnSync = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync.png"] style:UIBarButtonItemStylePlain target:self action:@selector(launchNotification)];
    btnSync.tag = 1;

    UIBarButtonItem *btnSettings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySettingsView)];
    btnSettings.tag = 2;
    
    UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
                         UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

    toolbar.items = [NSArray arrayWithObjects:
                      btnSync,
                      space,
                      btnSettings,
                      nil];
    [btnSync release];
    [btnSettings release];
    [self.view addSubview: toolbar];
    [toolbar release];
}

- (void)viewWillAppear:(BOOL)animated
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = [appDelegate managedObjectContext];
    [webLauncherItem setURL:[[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteUrlKey]];
    self.title = [appDelegate.site valueForKey: @"name"];
    [connectedSite setText: [NSString stringWithFormat:NSLocalizedString(@"connectedto", @"Connect to:"), [appDelegate.site valueForKey: @"name"]]];
    [super viewWillAppear:animated];
    
    BOOL autosync = [[NSUserDefaults standardUserDefaults] boolForKey: kAutoSync];
    NSLog(@"autosync: %d", autosync);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *defaultSiteUrl = [[NSUserDefaults standardUserDefaults] objectForKey: kSelectedSiteUrlKey];
    NSLog(@"root site url %@", defaultSiteUrl);
    NSLog(@"root site obj %@", appDelegate.site);
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
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)launcherViewDidEndEditing:(TTLauncherView*)launcher {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)launcherView:(TTLauncherView *)launcher didSelectItem:(TTLauncherItem *)item {
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:item.URL] applyAnimated:YES]];
}

@end
