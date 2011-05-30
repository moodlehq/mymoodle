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


@implementation MoodleMedia
+ (void)upload:(NSString *)filePath;
{
    NSLog(@"Enter MoodleMedia Class");
    NSString *host      = [[NSUserDefaults standardUserDefaults] valueForKey: kSelectedSiteUrlKey];
    NSString *uploadurl = [[NSString alloc] initWithFormat: @"%@/files/upload.php", host];
    NSURL *url          = [NSURL URLWithString: uploadurl];
    NSString *token     = [[NSUserDefaults standardUserDefaults] valueForKey: kSelectedSiteTokenKey];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue: token forKey: @"token"];
    [request setFile: filePath   forKey: @"thefile"];
    [request startSynchronous];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath: filePath error:nil];
    NSLog(@"Done deleted");
}
@end
