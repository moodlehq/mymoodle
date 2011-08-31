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
    NSString *host = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteUrlKey];
    NSString *uploadurl = [[NSString alloc] initWithFormat:@"%@/webservice/upload.php", host];
    NSURL *url = [NSURL URLWithString:uploadurl];
    [uploadurl release];
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteTokenKey];

    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addPostValue:token forKey:@"token"];
    NSLog(@"Uploading file: %@", [sender uploadFilepath]);
    [request setFile:[sender uploadFilepath] forKey:@"thefile"];
    [request startSynchronous];
    NSLog(@"Server Response: %@", [request responseString]);

    NSError *error;
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary: [request responseData] error:&error];

    BOOL uploadSuccess = YES;
    if (dictionary == nil) {
        NSArray *result = [[CJSONDeserializer deserializer] deserializeAsArray:[request responseData] error:&error];
        for (NSDictionary *file in result) {
            if ([file valueForKey:@"error"]) {
                uploadSuccess = NO;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:[file valueForKey:@"error"] delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
        }
        NSLog(@"Response: %@", result);
    } else {
        // probably user quota limit
        if ([dictionary valueForKey:@"error"]) {
            uploadSuccess = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:[dictionary valueForKey:@"error"] delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }

    if (uploadSuccess) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[sender uploadFilepath] error:nil];
        [sender uploadDidFinishUploading:nil];
        sleep(1);
    } else {
        [sender uploadFailed:nil];
    }
}

@end
