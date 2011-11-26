//
//  Content.m
//  Moodle
//
//  Created by Dongsheng Cai on 12/10/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import "Content.h"
#import "Module.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ASIHTTPRequest.h"
#import "NSURL+Additions.h"

@implementation Content

@dynamic author;
@dynamic timemodified;
@dynamic timecreated;
@dynamic filesize;
@dynamic userid;
@dynamic fileurl;
@dynamic filename;
@dynamic type;
@dynamic localpath;
@dynamic license;
@dynamic module;

+ (void)addToModule:(NSDictionary *)item module:(NSManagedObject *)module
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    // retrieve all courses that will need to be deleted from core data if they are not returned by the web service call
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *moduleItem = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:appDelegate.managedObjectContext];

    [request setEntity:moduleItem];
    NSPredicate *contentPredicate = [NSPredicate predicateWithFormat:@"(module = %@ AND filename = %@ AND filepath = %@)", module, [item valueForKey:@"filename"], [item valueForKey:@"filepath"]];
    [request setPredicate:contentPredicate];
    NSArray *content = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];

    NSManagedObject *contentObject;
    if ([content count] == 1)
    {
        contentObject = [content lastObject];
    }
    else if ([content count] == 0)
    {
        contentObject = [NSEntityDescription insertNewObjectForEntityForName:[moduleItem name]
                                                      inManagedObjectContext:appDelegate.managedObjectContext];
    }
    else
    {
        NSLog(@"some thing went wrong! [adding module contents]");
        return;
    }

    [contentObject setValue:module forKey:@"module"];
    [contentObject setValue:[item valueForKey:@"type"] forKey:@"type"];

    [contentObject setValue:[item valueForKey:@"filename"] forKey:@"filename"];
    [contentObject setValue:[item valueForKey:@"filepath"] forKey:@"filepath"];
    [contentObject setValue:[item valueForKey:@"filesize"] forKey:@"filesize"];
    if ([(NSString *)[item valueForKey:@"type"] isEqualToString:@"content"])
    {
        [contentObject setValue:[item valueForKey:@"content"] forKey:@"content"];
    }
    else
    {
        [contentObject setValue:[item valueForKey:@"fileurl"] forKey:@"fileurl"];
    }
    [contentObject setValue:[item valueForKey:@"timecreated"] forKey:@"timecreated"];
    NSLog(@"ws time modified: %d", [[item valueForKey:@"timemodified"] intValue]);
    NSLog(@"db time modified: %d", [[contentObject valueForKey:@"timemodified"] intValue]);

    if ([[item valueForKey:@"timemodified"] intValue] != [[contentObject valueForKey:@"timemodified"] intValue])
    {
        // file may need update
        NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteTokenKey];

        if ([contentObject valueForKey:@"localpath"])
        {
            NSString *filePath = [contentObject valueForKey:@"localpath"];
            NSLog(@"Re-download file stored at %@", filePath);
            NSURL *url = [NSURL URLWithString:[item valueForKey:@"fileurl"]];
            // redownload contents
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[url URLByAppendingQueryString:[NSString stringWithFormat:@"token=%@", token]]];
            [request setDownloadDestinationPath:filePath];
            [request startSynchronous];
        }
    }
    [contentObject setValue:[item valueForKey:@"timemodified"] forKey:@"timemodified"];
    [contentObject setValue:[item valueForKey:@"sortorder"] forKey:@"sortorder"];
    [contentObject setValue:[item valueForKey:@"userid"] forKey:@"userid"];
    [contentObject setValue:[item valueForKey:@"author"] forKey:@"author"];
    [contentObject setValue:[item valueForKey:@"license"] forKey:@"license"];
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];
}

+ (void)removeContents:(Module *)module
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [module retain];

    NSArray *items = [module valueForKey:@"contents"];
    NSError *error;

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    for (Content *item in items)
    {
        NSString *path = [item valueForKey:@"localpath"];
        if (path)
        {
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            if (fileURL)
            {
                [fileMgr removeItemAtPath:path error:&error];
            }
        }
        [appDelegate.managedObjectContext deleteObject:item];
    }
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];
    [module release];
}

+ (void)removeFiles:(Module *)module
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [module retain];
    NSArray *items = [module valueForKey:@"contents"];
    NSError *error;

    NSFileManager *fileMgr = [NSFileManager defaultManager];
    for (Content *item in items)
    {
        NSString *path = [item valueForKey:@"localpath"];
        if (path)
        {
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            if (fileURL)
            {
                [fileMgr removeItemAtPath:path error:&error];
                [item setValue:@"" forKey:@"localpath"];
            }
        }
    }
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];
    [module release];
}
@end
