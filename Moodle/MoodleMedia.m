//
// This file is part of My Moodle - https://github.com/moodlehq/mymoodle
//
// My Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Moodle.  If not, see <http://www.gnu.org/licenses/>.
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
    NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:[request responseData] error:&error];

    BOOL uploadSuccess = YES;
    if (dictionary == nil)
    {
        NSArray *result = [[CJSONDeserializer deserializer] deserializeAsArray:[request responseData] error:&error];
        for (NSDictionary *file in result)
        {
            if ([file valueForKey:@"error"])
            {
                uploadSuccess = NO;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:[file valueForKey:@"error"] delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
                [alert show];
                [alert release];
            }
        }
        NSLog(@"Response: %@", result);
    }
    else
    {
        // probably user quota limit
        if ([dictionary valueForKey:@"error"])
        {
            uploadSuccess = NO;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) message:[dictionary valueForKey:@"error"] delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }

    if (uploadSuccess)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[sender uploadFilepath] error:nil];
        [sender uploadDidFinishUploading:nil];
        sleep(1);
    }
    else
    {
        [sender uploadFailed:nil];
    }
}

@end
