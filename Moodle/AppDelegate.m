//
//  AppDelegate.h
//  Moodle
//
//  Created by Dongsheng Cai on 20/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "AppDelegate.h"
#import "MoodleKit.h"
// view controllers
#import "RootViewController.h"
#import "SitesViewController.h"
#import "SettingsSiteViewController.h"
#import "UploadViewController.h"
#import "WebViewController.h"
#import "SyncViewController.h"
#import "RecorderViewController.h"
#import "CoursesViewController.h"
#import "TaskHandler.h"

@implementation AppDelegate

@synthesize site, netStatus;

static AppDelegate *moodleApp = NULL;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;

- (id)init
{
    MLog(@"Moodle app init");
    if (!moodleApp)
    {
        moodleApp = [super init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        NSNumber *autoSync = [NSNumber numberWithInt:1];
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];

        NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                     autoSync, kAutoSync,
                                     appVersion, @"moodle_app_version",
                                     nil];

        [defaults registerDefaults:appDefaults];

        [NSUserDefaults resetStandardUserDefaults];
    }

    return moodleApp;
}


+ (AppDelegate *)sharedMoodleApp
{
    if (!moodleApp)
    {
        moodleApp = [[AppDelegate alloc] init];
    }

    return moodleApp;
}


- (void)resetSite:(id)object
{
    NSLog(@"Resetting active site");
    self.site = nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSManagedObjectContext *context = [self managedObjectContext];

    if (!context)
    {
        MLog(@"Cannot create NSManagedObjectContext");
    }
    NSInteger count = [Site countWithContext:context];

    MLog(@"%d sites in core data", count);
    if (count > 0)
    {
        // restore active site info
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(url = %@ AND token = %@)",
                                  [defaults stringForKey:kSelectedSiteUrlKey],
                                  [defaults stringForKey:kSelectedSiteTokenKey]];
        [request setPredicate:predicate];
        NSError *error = nil;
        NSArray *sites = [self.managedObjectContext executeFetchRequest:request error:&error];
        self.site = [sites lastObject];
        NSLog(@"Active site: %@", self.site);
    }

    [TTStyleSheet setGlobalStyleSheet:[[[MoodleStyleSheet alloc] init] autorelease]];
    TTNavigator *navigator = [TTNavigator navigator];
    navigator.persistenceMode = TTNavigatorPersistenceModeNone;
    // register component
    [navigator.URLMap from:@"*"                   toViewController:[WebViewController class]];
    [navigator.URLMap from:@"tt://dashboard/"     toViewController:[RootViewController class]];
    [navigator.URLMap from:@"tt://upload/"        toViewController:[UploadViewController class]];
    [navigator.URLMap from:@"tt://courses/(initWithType:)"  toViewController:[CoursesViewController class]];
    [navigator.URLMap from:@"tt://recorder/"      toViewController:[RecorderViewController class]];
    [navigator.URLMap from:@"tt://sites/"         toViewController:[SitesViewController class]];
    [navigator.URLMap from:@"tt://settings/"      toViewController:[SettingsSiteViewController class]];
    [navigator.URLMap from:@"tt://settings/(initWithNew:)" toViewController:[SettingsSiteViewController class]];
    [navigator.URLMap from:@"tt://sync/"  toModalViewController:[SyncViewController class]];

    [navigator openURLAction:[TTURLAction actionWithURLPath:@"tt://dashboard/"]];

    // make all dictionary ready
    NSFileManager *NSFm = [NSFileManager defaultManager];
    BOOL isDir = YES;
    NSError *error;
    if (![NSFm fileExistsAtPath:AUDIO_FOLDER isDirectory:&isDir])
    {
        if (![NSFm createDirectoryAtPath:AUDIO_FOLDER withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Error: Create folder failed %@", error);
        }
        else
        {
            NSLog(@"Folder created");
        }
    }
    if (![NSFm fileExistsAtPath:PHOTO_FOLDER isDirectory:&isDir])
    {
        if (![NSFm createDirectoryAtPath:PHOTO_FOLDER withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Error: Create folder failed %@", error);
        }
        else
        {
            NSLog(@"Folder created");
        }
    }

    if (![NSFm fileExistsAtPath:VIDEO_FOLDER isDirectory:&isDir])
    {
        if (![NSFm createDirectoryAtPath:VIDEO_FOLDER withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Error: Create folder failed %@", error);
        }
        else
        {
            NSLog(@"Folder created");
        }
    }

    if (![NSFm fileExistsAtPath:OFFLINE_FOLDER isDirectory:&isDir])
    {
        if (![NSFm createDirectoryAtPath:OFFLINE_FOLDER withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Error: Create folder failed %@", error);
        }
        else
        {
            NSLog(@"Folder created");
        }
    }

    if (![NSFm fileExistsAtPath:DOWNLOADS_FOLDER isDirectory:&isDir])
    {
        if (![NSFm createDirectoryAtPath:DOWNLOADS_FOLDER withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Error: Create folder failed %@", error);
        }
        else
        {
            NSLog(@"Folder created");
        }
    }
    // Set a method to be called when a notification is sent.
    NSURL *url = [NSURL URLWithString:[self.site valueForKey:@"url"]];
    NSLog(@"target host: %@", url.host);
//    Reachability *reachability = [[Reachability reachabilityWithHostName: url.host] retain];
    Reachability *reachability = [[Reachability reachabilityWithHostName:@"apple.com"] retain];

    [reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:@"NetworkReachabilityChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:[TaskHandler class] selector:@selector(reachabilityChanged:) name:@"NetworkReachabilityChangedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetSite:) name:kResetSite object:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     * Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     * Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     * Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     * If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     * Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     * Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)dealloc
{
    [__managedObjectContext release];
    [__managedObjectModel release];
    [__persistentStoreCoordinator release];
    [super dealloc];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;

    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             * Replace this implementation with code to handle the error appropriately.
             *
             * abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/**
 * Returns the managed object context for the application.
 * If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 * Returns the managed object model for the application.
 * If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Moodle" withExtension:@"momd"];
    // there is VersionInfo.plist in that directory to determind dest version
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 * Returns the persistent store coordinator for the application.
 * If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSError *error = nil;

    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];


    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Moodle.sqlite"];

    // get source meta data
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
                                                                                              URL:storeURL
                                                                                            error:&error];
    // get dest model
    NSManagedObjectModel *destinationModel = [self managedObjectModel];
    NSLog(@"Destination model version identifiers: %@", [destinationModel versionIdentifiers]);

    if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata] || sourceMetadata == nil)
    {
        NSLog(@"Data model looks ok");
        [__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
    }
    else
    {
        NSLog(@"Needs migration");

        NSURL *destStoreURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"upgrade.sqlite"];
        NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil forStoreMetadata:sourceMetadata];

        NSMappingModel *mappingModel = [NSMappingModel
                                        mappingModelFromBundles:[NSArray arrayWithObject:[NSBundle mainBundle]]
                                                 forSourceModel:sourceModel
                                               destinationModel:destinationModel];

        NSMigrationManager *manager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinationModel];
        NSLog(@"Main Bundle: %@", [NSBundle mainBundle]);

        if (mappingModel == nil)
        {
            NSLog(@"Cannot find mapping model");
        }

        // perform migration
        BOOL ok = [manager migrateStoreFromURL:storeURL
                                          type:NSSQLiteStoreType
                                       options:nil
                              withMappingModel:mappingModel
                              toDestinationURL:destStoreURL
                               destinationType:NSSQLiteStoreType
                            destinationOptions:nil
                                         error:&error];
        [manager release];
        if (ok)
        {
            NSLog(@"Migration went ok");
        }
        else
        {
            NSLog(@"Migration failed: %@", [error localizedDescription]);
        }
        NSPersistentStore *destStore = [__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:destStoreURL options:nil error:&error];
        // try open migrated data
        if (!destStore)
        {
            // delete storage
            [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:nil];
            if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
            {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }

            // if the app did not quit, show the alert to inform the users that the data have been deleted
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error establishing database connection.", @"")
                                                             message:NSLocalizedString(@"Please delete the app and reinstall.", @"")
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                   otherButtonTitles:nil] autorelease];
            [alert show];
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        else
        {
            if (![[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error])
            {
                NSLog(@"Removing old sqlite.db failed %@", [error localizedDescription]);
            }
            if (![[NSFileManager defaultManager] moveItemAtURL:destStoreURL toURL:storeURL error:&error])
            {
                NSLog(@"Moving upgraded db to source db failed %@", [error localizedDescription]);
            }
            // remove dest db from persistent store coordinator
            [__persistentStoreCoordinator removePersistentStore:destStore error:&error];
            if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
            {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
            else
            {
                NSLog(@"New storage established!");
            }
        }
    }


    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 * Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
// /////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)navigator:(TTNavigator *)navigator shouldOpenURL:(NSURL *)URL
{
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)URL
{
    TTOpenURL([URL absoluteString]);
    return YES;
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability *curReach = [note object];

    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
            NSLog(@"Network not reachable");
            break;

        case ReachableViaWWAN:
            NSLog(@"Network via WWAN");
            break;

        case ReachableViaWiFi:
            NSLog(@"Network via WiFi");
            break;

        default:
            break;
    }
}
@end
