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

@implementation TaskHandler

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
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
