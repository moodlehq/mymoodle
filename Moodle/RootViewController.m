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
- (void)launchNotification {
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath: @"tt://sync/"] applyAnimated:YES]];
}

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

/**
 * Set up dashboard
 *
 */
- (void)loadView {
    

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = [appDelegate managedObjectContext];
    [super loadView];    
    
    
    //    self.view.backgroundColor = UIColorFromRGB(RootBackground);
    //    CGRect rect = self.view.bounds;
    NSLog(@"AppFrame: %@", NSStringFromCGRect([UIScreen mainScreen].applicationFrame));
    NSLog(@"ViewBounds: %@", NSStringFromCGRect(self.view.bounds));
    NSLog(@"view : %@", NSStringFromCGRect(self.view.frame));
    CGRect rect = [UIScreen mainScreen].applicationFrame;

    UIImageView *appBg = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"app_bg.png"]];
    appBg.frame = CGRectMake(0, 0, 320, 460);
    [self.view addSubview:appBg];
    [appBg release];

    UIImageView *header = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"header.png"]];
    header.frame = CGRectMake((rect.size.width-240)/2, 35, 240, 34);
    [self.view addSubview:header];
    [header release];
    
    UITextView *connectedSite = [[UITextView alloc] initWithFrame:CGRectMake(20, 69, rect.size.width-40, 40)];
    [connectedSite setText: [NSString stringWithFormat:@"Connected to: %@", [appDelegate.site valueForKey: @"url"]]];
    [connectedSite setBackgroundColor:[UIColor clearColor]];
    [connectedSite setScrollEnabled: NO];
    [connectedSite setEditable: NO];
    [connectedSite setTextAlignment:UITextAlignmentCenter];
    [connectedSite setFont: [UIFont boldSystemFontOfSize:11]];
    [self.view addSubview:connectedSite];
    [connectedSite release];
    

    int headerHeight = 90;
    
    
    int bgWidth = 276;
    int bgHeight = 299;
    UIImageView *rootBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"root_bg.png"]];
    rootBackground.frame = CGRectMake((rect.size.width-276)/2, rect.origin.y+headerHeight, bgWidth, bgHeight);
    [self.view addSubview: rootBackground];
    [rootBackground release];

    CGRect launcherFrame = CGRectMake(rootBackground.frame.origin.x+10, rootBackground.frame.origin.y+30, bgWidth-20, bgHeight-30);
    launcherView = [[TTLauncherView alloc] initWithFrame: launcherFrame];
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
    [self.view addSubview: launcherView];
    //defautl toolbar height ;44

    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(10, rect.size.height - 40, rect.size.width-20, 33)];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:toolbar.bounds 
                                                byRoundingCorners:UIRectCornerBottomLeft|UIRectCornerBottomRight
                                                        cornerRadii:CGSizeMake(10.0, 10.0)];

    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = toolbar.bounds;
    maskLayer.path = maskPath.CGPath;
    // Set the newly created shape layer as the mask for the image view's layer
    toolbar.layer.mask = maskLayer;
    toolbar.tintColor = TTSTYLEVAR(toolbarTintColor);
    
    UIBarButtonItem *btnSync = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync.png"] style:UIBarButtonItemStylePlain target:self action:@selector(launchNotification)];
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

//    TTButton *syncButton = [TTButton buttonWithStyle:@"notificationButton:" title: @"Sync"];
////    [syncButton setImage:@"bundle://sync.png" forState:UIControlStateNormal];
//    [syncButton addTarget:self
//               action:@selector(launchNotification:) forControlEvents: UIControlEventTouchUpInside];
//
//    syncButton.frame = ;
//    [self.view addSubview: syncButton];

}

- (void)viewWillAppear:(BOOL)animated
{
    [[self navigationController] setNavigationBarHidden:YES animated:NO];

    [webLauncherItem setURL:[[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteUrlKey]];
    self.navigationBarTintColor = UIColorFromRGB(ColorNavigationBar);
    self.title = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteNameKey];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
    [[self navigationController] setNavigationBarHidden:NO animated:NO];

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
