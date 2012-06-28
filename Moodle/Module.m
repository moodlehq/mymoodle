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
//  Module.m
//  Moodle
//
//  Created by Dongsheng Cai on 3/10/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import "Module.h"
#import "AppDelegate.h"
#import "Content.h"
#import "Section.h"

@implementation Module

@dynamic modname;
@dynamic name;
@dynamic id;
@dynamic desc;
@dynamic modicon;
@dynamic contents;
@dynamic section;

+ (NSManagedObject *)addToSection:(NSDictionary *)wsModule section:(Section *)section
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSError *error;
    // retrieve all courses that will need to be deleted from core data if they are not returned by the web service call
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *moduleEntry = [NSEntityDescription entityForName:@"Module" inManagedObjectContext:appDelegate.managedObjectContext];

    [request setEntity:moduleEntry];
    NSPredicate *sectionPredicate = [NSPredicate predicateWithFormat:@"(section = %@ AND id = %@)", section, [wsModule valueForKey:@"id"]];
    [request setPredicate:sectionPredicate];
    NSArray *theModule = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];

    NSManagedObject *moduleObject;
    if ([theModule count] == 1)
    {
        moduleObject = [theModule lastObject];
    }
    else if ([theModule count] == 0)
    {
        NSLog(@"Insert new module");
        moduleObject = [NSEntityDescription insertNewObjectForEntityForName:[moduleEntry name]
                                                     inManagedObjectContext:appDelegate.managedObjectContext];
    }
    else
    {
        NSLog(@"some thing went wrong");
        return [theModule lastObject];
    }

    [moduleObject setValue:section forKey:@"section"];
    // module instance id
    [moduleObject setValue:[wsModule valueForKey:@"id"] forKey:@"id"];
    // activity name
    [moduleObject setValue:[wsModule valueForKey:@"name"] forKey:@"name"];
    // URL to the module
    [moduleObject setValue:[wsModule valueForKey:@"url"] forKey:@"url"];
    // created by course contents view
    [moduleObject setValue:[wsModule valueForKey:@"sortorder"] forKey:@"sortorder"];
    [moduleObject setValue:@"" forKey:@"desc"];
    [moduleObject setValue:[wsModule valueForKey:@"modicon"] forKey:@"modicon"];
    [moduleObject setValue:[wsModule valueForKey:@"modname"] forKey:@"modname"];
    [moduleObject setValue:[wsModule valueForKey:@"visible"] forKey:@"visible"];
    [moduleObject setValue:[wsModule valueForKey:@"availablefrom"] forKey:@"availablefrom"];
    [moduleObject setValue:[wsModule valueForKey:@"availableuntil"] forKey:@"availableuntil"];
    // Finish updating/adding modules

    NSArray *wsContents = [wsModule valueForKey:@"contents"];

    for (NSDictionary *wsItem in wsContents)
    {
        // add/update contents
        [Content addToModule:wsItem module:moduleObject];
    }
    // remove deleted contents
    [Module removeContentsFromModule:(Module *)moduleObject excludedItems:wsContents];
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];
    return moduleObject;
}


// for remove contents not presented in web service reponse
+ (void)removeContentsFromModule:(Module *)module excludedItems:(NSArray *)items
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // retrieve all courses that will need to be deleted from core data if they are not returned by the web service call
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *itemEntry = [NSEntityDescription entityForName:@"Content" inManagedObjectContext:appDelegate.managedObjectContext];

    [request setEntity:itemEntry];
    NSError *error;

    NSMutableArray *arrayOfExcludedObjects = [NSMutableArray array];

    for (NSDictionary *item in items)
    {
        NSPredicate *itemPredicate = [NSPredicate predicateWithFormat:
                                      @"(module = %@ AND filename = %@ AND filepath = %@ AND filesize = %@ AND timemodified = %@)", module,
                                      [item valueForKey:@"filename"], [item valueForKey:@"filepath"], [item valueForKey:@"filesize"],
                                      [item valueForKey:@"timemodified"]];
        [request setPredicate:itemPredicate];
        NSArray *theItem = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
        if ([theItem count] == 1)
        {
            [arrayOfExcludedObjects addObject:[theItem lastObject]];
        }
    }
    NSLog(@"reserved items %@ [removeContentsFromModule]", arrayOfExcludedObjects);

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (self IN %@) AND module = %@", arrayOfExcludedObjects, module];

    [request setPredicate:predicate];
    NSArray *itemsToBeDeleted = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    NSFileManager *fileMgr = [NSFileManager defaultManager];

    for (Content *itemToBeDeleted in itemsToBeDeleted)
    {
        // delete files
        NSString *path = [itemToBeDeleted valueForKey:@"localpath"];
        if (path)
        {
            if ([NSURL fileURLWithPath:path])
            {
                NSLog(@"Deleting file at %@", path);
                [fileMgr removeItemAtPath:path error:&error];
            }
        }
        [appDelegate.managedObjectContext deleteObject:itemToBeDeleted];
    }
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];
}

+ (void)removeContentsFromModule:(Module *)module
{
    [module retain];
    [Content removeContents:module];
    [module release];
}

+ (void)removeFilesFromModule:(Module *)module
{
    [module retain];
    [Content removeFiles:module];
    [module release];
}

- (void)removeContents
{
    [Content removeContents:self];
}

@end
