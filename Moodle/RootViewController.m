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
#import "WSClient.h"


@implementation RootViewController

#pragma mark -
#pragma mark toolbar event handler
- (void)displaySettingsView
{
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://sites/"] applyAnimated:YES]];
}

- (void)displaySyncView
{
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://sync/"] applyAnimated:YES]];
}

#pragma mark -
#pragma mark Private methods

/** generate individual launcher item object */
- (TTLauncherItem *)launcherItemWithTitle:(NSString *)pTitle image:(NSString *)image URL:(NSString *)url
{
    TTLauncherItem *launcherItem = [[TTLauncherItem alloc] initWithTitle:pTitle
                                                                   image:image
                                                                     URL:url canDelete:NO];

    launcherItem.style = @"MoodleLauncherButton:";
    return [launcherItem autorelease];
}

/** check if web service available*/
- (BOOL)featureExists:(NSString *)name
{
    if ([features indexOfObject:name] == NSNotFound)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
/** generate available launcher items*/
- (NSArray *)generateLauncherItems
{
    features = [NSMutableArray array];
    NSFetchRequest *wsRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *wsDescription = [NSEntityDescription entityForName:@"WebService" inManagedObjectContext:appDelegate.managedObjectContext];
    [wsRequest setEntity:wsDescription];
    NSPredicate *wsPredicate = [NSPredicate predicateWithFormat:@"(site = %@)", appDelegate.site];
    [wsRequest setPredicate:wsPredicate];
    NSArray *webservices = [appDelegate.managedObjectContext executeFetchRequest:wsRequest error:nil];
    for (NSManagedObject *ws in webservices)
    {
        [features addObject:[ws valueForKey:@"name"]];
    }
    [wsRequest release];

    NSMutableArray *pages = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *items = [NSMutableArray array];
    // always available
    [items addObject:[self launcherItemWithTitle:NSLocalizedString(@"Upload", "Upload") image:@"bundle://Upload.png" URL:@"tt://upload/"]];
    if ([self featureExists:@"moodle_user_get_course_participants_by_id"] && [self featureExists:@"moodle_user_get_users_by_courseid"])
    {
        [items addObject:[self launcherItemWithTitle:NSLocalizedString(@"Participants", "Participants") image:@"bundle://Participants.png" URL:@"tt://courses/participants"]];
    }
    BOOL candownloadfiles = YES;
    NSLog(@"can download %@", [appDelegate.site valueForKey:@"downloadfiles"]);
    if ([appDelegate.site valueForKey:@"downloadfiles"] == nil)
    {
        candownloadfiles = NO;
    }
    else
    {
        if ([[appDelegate.site valueForKey:@"downloadfiles"] intValue] != 1)
        {
            candownloadfiles = NO;
        }
    }
    if ([self featureExists:@"core_course_get_contents"] && candownloadfiles)
    {
        [items addObject:[self launcherItemWithTitle:NSLocalizedString(@"Contents", nil) image:@"bundle://Contents.png" URL:@"tt://courses/contents"]];
    }
    [items addObject:[self launcherItemWithTitle:NSLocalizedString(@"Web", "Web") image:@"bundle://Web.png" URL:[[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteUrlKey]]];
    [items addObject:[self launcherItemWithTitle:NSLocalizedString(@"Help", "Help") image:@"bundle://MoodleHelp.png" URL:URL_MOODLE_HELP]];


    [pages addObject:items];
    return pages;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

/**
 * Set up dashboard
 *
 */
- (void)loadView
{
    [super loadView];
    self.navigationBarTintColor = UIColorFromRGB(ColorNavigationBar);

    CGRect appRect = [UIScreen mainScreen].applicationFrame;

    // app background
    UIImageView *appBg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"screen_bg.png"]];
    appBg.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    CGRect view = self.view.frame;
    [self.view addSubview:appBg];
    [appBg release];


    rootBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"root_bg.png"]];
    rootBackground.frame = CGRectMake((view.size.width - 276) / 2, appRect.origin.y + HEADER_HEIGHT, BG_WIDTH, BG_HEIGHT);
    [self.view addSubview:rootBackground];
    [rootBackground release];

    // defautl toolbar height: 44
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(10, view.size.height - 40, view.size.width - 20, 33)];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:toolbar.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(10.0, 10.0)];
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = toolbar.bounds;
    maskLayer.path = maskPath.CGPath;
    // Set the newly created shape layer as the mask for the image view's layer
    toolbar.layer.mask = maskLayer;
    toolbar.tintColor = UIColorFromRGB(ColorToolbar);

    btnSync = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySyncView)];
    btnSync.tag = 1;

    UIBarButtonItem *btnSettings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySettingsView)];
    btnSettings.tag = 2;

    UIBarItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    toolbar.items = [NSArray arrayWithObjects:
                     btnSync,
                     space,
                     btnSettings,
                     nil];
    [space release];
    [btnSync release];
    [btnSettings release];
    [self.view addSubview:toolbar];
    [toolbar release];

    // Header
    header = [[UITextView alloc] initWithFrame:CGRectMake(90, 10, 310 - 90, 70)];
    [header setTextColor:UIColorFromRGB(ColorToolbar)];
    [header setFont:[UIFont systemFontOfSize:24.0f]];
    [header setBackgroundColor:[UIColor clearColor]];
    [header setTextAlignment:UITextAlignmentRight];
    header.userInteractionEnabled = NO;
    [header setEditable:NO];
    [self.view addSubview:header];
    [header release];

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    CGRect launcherFrame = CGRectMake(rootBackground.frame.origin.x + 10, rootBackground.frame.origin.y + 30, BG_WIDTH - 20, BG_HEIGHT + 40);
    launcherView = [[TTLauncherView alloc] initWithFrame:launcherFrame];
    launcherView.persistenceMode = TTLauncherPersistenceModeAll;
    launcherView.delegate = self;
    [self.view addSubview:launcherView];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![launcherView restoreLauncherItems])
    {
        launcherView.pages = [self generateLauncherItems];
        if ([[launcherView.pages lastObject] count] > 4)
        {
            launcherView.columnCount = 3;
        }
        else
        {
            launcherView.columnCount = 2;

        }

    }

    managedObjectContext = [appDelegate managedObjectContext];
    [connectedSite setText:[NSString stringWithFormat:NSLocalizedString(@"connectedto", @"Connect to:"), [appDelegate.site valueForKey:@"name"]]];

    [header setText:[appDelegate.site valueForKey:@"name"]];
}


- (void)updateSiteIfNecessary
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    int now = (int)[[NSDate date] timeIntervalSince1970];

    NSString *lastUpdate = [defaults valueForKey:kLastUpdateDate];
    NSLog(@"last update %@", lastUpdate);
    if (lastUpdate)
    {
        NSLog(@"Interval since last update siteinfo: %d", now - [lastUpdate intValue]);
        if ((now - [lastUpdate intValue]) < kUpdateSiteInterval)
        {
            NSLog(@"less than a day");
            // less than a day so don't update
            return;
        }
    }


    // retrieve the site name
    WSClient *client = [[[WSClient alloc] init] autorelease];
    NSDictionary *siteinfo = [client get_siteinfo];
    NSString *host = [defaults valueForKey:kSelectedSiteUrlKey];
    NSString *token = [appDelegate.site valueForKey:@"token"];
    [siteinfo setValue:token forKey:@"token"];
    [siteinfo setValue:host forKey:@"url"];

    if ([siteinfo isKindOfClass:[NSDictionary class]])
    {
        NSError *error;
        NSFetchRequest *siteRequest = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *siteEntity = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:[appDelegate managedObjectContext]];
        [siteRequest setEntity:siteEntity];
        NSPredicate *sitePredicate = [NSPredicate predicateWithFormat:@"(url like %@ AND mainuser.userid = %@)", host, [siteinfo objectForKey:@"userid"]];
        [siteRequest setPredicate:sitePredicate];
        NSArray *sites = [managedObjectContext executeFetchRequest:siteRequest error:&error];
        if ([sites count] > 0)
        {
            NSManagedObject *editingSite = [sites lastObject];
            editingSite = [Site updateSite:editingSite info:siteinfo newEntry:NO];
            [defaults setObject:[NSNumber numberWithInt:now] forKey:kLastUpdateDate];
            [defaults synchronize];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *defaultSiteUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteUrlKey];
    if (defaultSiteUrl == nil || appDelegate.site == nil)
    {
        [self displaySettingsView];
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^(void){
            [self updateSiteIfNecessary];
        });
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
    launcherView = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    // release view controllers
    [launcherView release];
    [super dealloc];
}

#pragma mark -
#pragma mark TTLauncherViewDelegate methods
- (void)launcherViewDidBeginEditing:(TTLauncherView *)launcher
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:launcherView action:@selector(endEditing)];

    self.navigationItem.rightBarButtonItem = doneButton;
    [doneButton release];
}

- (void)launcherViewDidEndEditing:(TTLauncherView *)launcher
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)launcherView:(TTLauncherView *)launcher didSelectItem:(TTLauncherItem *)item
{
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:item.URL] applyAnimated:YES]];
}

@end
