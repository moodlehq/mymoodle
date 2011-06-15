//
//  MoodleMedia.m
//  Moodle
//
//  Created by Dongsheng Cai on 30/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "MoodleMedia.h"
#import "Constants.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"
#import "CJSONDeserializer.h"


@implementation MoodleMedia
+ (void)upload:(id<MoodleUploadDelegate>)sender;
{
    NSString *host      = [[NSUserDefaults standardUserDefaults] valueForKey: kSelectedSiteUrlKey];
    NSString *uploadurl = [[NSString alloc] initWithFormat: @"%@/webservice/upload.php", host];
    NSURL *url          = [NSURL URLWithString: uploadurl];
    [uploadurl release];
    NSString *token     = [[NSUserDefaults standardUserDefaults] valueForKey: kSelectedSiteTokenKey];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue: token forKey: @"token"];
    [request setFile: [sender getFilepath] forKey: @"thefile"];
    [request startSynchronous];
    
    NSLog(@"before decode: %@", [request responseString]);
    NSError *error;
    NSDictionary *result = [[CJSONDeserializer deserializer] deserializeAsDictionary: [request responseData] error: &error];
    // print out error message if detected
    NSLog(@"result: %@", result);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath: [sender getFilepath] error:nil];
    [sender uploadCallback:nil];
}

+ (void)upload:(id)data format: (NSString *)dataformat {
    NSLog(@"Data: %@ in \"%@\" format", data, dataformat);
    NSString *host      = [[NSUserDefaults standardUserDefaults] valueForKey: kSelectedSiteUrlKey];
    NSString *uploadurl = [[NSString alloc] initWithFormat: @"%@/webservice/upload.php", host];
    NSURL *url          = [NSURL URLWithString: uploadurl];
    [uploadurl release];
    NSString *token     = [[NSUserDefaults standardUserDefaults] valueForKey: kSelectedSiteTokenKey];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue: token forKey: @"token"];
    [request setFile: data   forKey: @"thefile"];
    [request startSynchronous];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath: data error:nil];
}

+ (BOOL)test: (id)data format:(NSString *)dataformat {
    NSLog(@"Received signal, start to work");
    sleep(1);
    NSLog(@"Done ==%@== using %@", data, dataformat);
    return YES;
}
@end
