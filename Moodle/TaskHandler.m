//
//  TaskHandler.m
//  Moodle
//
//  Created by Dongsheng Cai on 26/07/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "TaskHandler.h"
#import "WSClient.h"
#import "MoodleKit.h"
#import "MoodleJob.h"
#import "AppDelegate.h"

@implementation TaskHandler

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }

    return self;
}

//Called by Reachability whenever status changes.
+ (void) reachabilityChanged: (NSNotification* )note
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSInteger count = [MoodleJob countWithContext: managedObjectContext];
    if (count < 1) {
        return;
    }
    BOOL autosync = [[NSUserDefaults standardUserDefaults] boolForKey: kAutoSync];
    if (!autosync) {
        return;
    }
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            NSLog(@"Network not reachable");
            break;
        case ReachableViaWWAN:
        case ReachableViaWiFi:
            // available
            [NSThread detachNewThreadSelector: @selector(sync) toTarget: [TaskHandler class] withObject: nil];
            break;
        default:
            break;
    }
}
+ (void)sync {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Job" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    [request setFetchBatchSize: 10];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(site = %@)", appDelegate.site];
    [request setPredicate: predicate];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"created" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSError *error = nil;
    NSArray *jobs = [managedObjectContext executeFetchRequest:request error:&error];
    for (NSManagedObject *job in jobs) {
        NSLog(@"processing");
        id target = NSClassFromString([job valueForKey:@"target"]);
        SEL method = NSSelectorFromString([NSString stringWithFormat:@"%@:format:", [job valueForKey:@"action"]]);
        @try {
            [target performSelector: method withObject: [job valueForKey:@"data"] withObject:[job valueForKey:@"dataformat"]];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        [managedObjectContext deleteObject:job];
        [managedObjectContext save:nil];
    }

    [pool drain];
}


+ (void)upload:(id)data format: (NSString *)dataformat {
    NSString *host      = [[NSUserDefaults standardUserDefaults] valueForKey: kSelectedSiteUrlKey];
    NSString *uploadurl = [[NSString alloc] initWithFormat: @"%@/webservice/upload.php", host];
    NSURL *url          = [NSURL URLWithString: uploadurl];
    [uploadurl release];
    NSString *token     = [[NSUserDefaults standardUserDefaults] valueForKey: kSelectedSiteTokenKey];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue: token forKey: @"token"];
    [request setFile: data   forKey: @"thefile"];
    [request startSynchronous];
    NSError *error;
    NSDictionary *result = [[CJSONDeserializer deserializer] deserializeAsArray: [request responseData] error: &error];
    // print out error message if detected
    NSLog(@"Moodle Response: %@", result);
    NSLog(@"Deleting %@", data);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath: data error:nil];
}


+ (void)sendMessage:(id)json format: (NSString *)dataformat {
    NSData *data=[json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = [[CJSONDeserializer deserializer] deserializeAsDictionary: data error: nil];
    WSClient *client   = [[WSClient alloc] init];
    NSArray *wsinfo;
    @try {
        wsinfo = [client invoke: @"moodle_message_send_instantmessages" withParams: (NSArray *)params];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate:self cancelButtonTitle: NSLocalizedString(@"continue", @"") otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    [client release];
}

+ (void)addNote:(id)json format: (NSString *)dataformat {
    NSData *data=[json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = [[CJSONDeserializer deserializer] deserializeAsDictionary: data error: nil];
    WSClient *client   = [[WSClient alloc] init];
    NSArray *wsinfo;
    @try {
        wsinfo = [client invoke: @"moodle_notes_create_notes" withParams: (NSArray *)params];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate:self cancelButtonTitle: NSLocalizedString(@"continue", @"") otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    [client release];
}
@end
