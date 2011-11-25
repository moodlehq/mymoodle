//
//  Downloader.m
//  Moodle
//
//  Created by Dongsheng Cai on 5/10/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import "Downloader.h"
#import "ASIHTTPRequest.h"

@implementation Downloader


- (id)initWithFiles:(NSArray *)files
{

    if (self = [super init])
    {
        connections = [[NSMutableArray alloc] init];
    }
    NSError *error = nil;
    NSFileManager *fm = [[NSFileManager alloc] init];

    for (NSDictionary *file in files)
    {
        NSString *filePath = [file valueForKey:@"filepath"];
        NSString *fileName = [filePath lastPathComponent];
        NSRange range = [filePath rangeOfString:fileName];
        NSString *dirName = [filePath substringToIndex:range.location];

        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:dirName
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:&error];
        if (!success || error)
        {
            NSLog(@"Error! %@", error);
        }
        else
        {
            NSLog(@"Dir created: %@", dirName);
        }

        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[file valueForKey:@"url"]];
        [request setDelegate:self];
        [request setDownloadDestinationPath:[file valueForKey:@"filepath"]];
        [request setShowAccurateProgress:YES];
        [request setUserInfo:[file valueForKey:@"userinfo"]];

        [request setDelegate:[file valueForKey:@"delegate"]];
        [request setDidFinishSelector:@selector(requestDone:)];
        [request setDidFailSelector:@selector(requestWentWrong:)];

        [connections addObject:request];
    }
    [fm release];
    return self;
}

- (NSArray *)getRequests
{
    return connections;
}


- (void)dealloc
{
    [connections release];
    [super dealloc];
}

@end
