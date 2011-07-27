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
    MLog(@"MoodleMedia:upload is handling file uploading");
    NSString *host      = [[NSUserDefaults standardUserDefaults] valueForKey: kSelectedSiteUrlKey];
    NSString *uploadurl = [[NSString alloc] initWithFormat: @"%@/webservice/upload.php", host];
    NSURL *url          = [NSURL URLWithString: uploadurl];
    [uploadurl release];
    NSString *token     = [[NSUserDefaults standardUserDefaults] valueForKey: kSelectedSiteTokenKey];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue: token forKey: @"token"];
    [request setFile: [sender getFilepath] forKey: @"thefile"];
    [request startSynchronous];
    
    NSError *error;
    NSDictionary *result = [[CJSONDeserializer deserializer] deserializeAsArray: [request responseData] error: &error];
    NSLog(@"Response: %@", result);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath: [sender getFilepath] error:nil];
    [sender uploadCallback:nil];
}

@end
