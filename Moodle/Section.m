//
//  Section.m
//  Moodle
//
//  Created by Dongsheng Cai on 11/10/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import "Section.h"
#import "Module.h"
#import "AppDelegate.h"
#import "Content.h"

@implementation Section

@dynamic id;
@dynamic summary;
@dynamic name;
@dynamic course;
@dynamic modules;

// delete modules don't exists in web service response
+ (void)removeModulesFromSection:(Section *)section excludedModules:(NSArray *)modules
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // retrieve all courses that will need to be deleted from core data if they are not returned by the web service call
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *moduleEntry = [NSEntityDescription entityForName:@"Module" inManagedObjectContext:appDelegate.managedObjectContext];

    [request setEntity:moduleEntry];
    NSError *error;

    NSMutableArray *arrayOfExcludedObjects = [NSMutableArray array];

    for (NSDictionary *mod in modules)
    {
        NSPredicate *sectionPredicate = [NSPredicate predicateWithFormat:@"(section = %@ AND id = %@)", section, [mod valueForKey:@"id"]];
        [request setPredicate:sectionPredicate];
        NSArray *theModule = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
        if ([theModule count] == 1)
        {
            [arrayOfExcludedObjects addObject:[theModule lastObject]];
        }
    }


    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (self IN %@) AND section = %@", arrayOfExcludedObjects, section];

    [request setPredicate:predicate];
    NSArray *deletingMods = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    for (Module *deletingMod in deletingMods)
    {
        NSLog(@"Deleting module %@", [deletingMod valueForKey:@"name"]);
        [Content removeContents:deletingMod];
        [appDelegate.managedObjectContext deleteObject:deletingMod];
    }
    [appDelegate.managedObjectContext performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];

}


- (void)removeModules
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSError *error;

    // retrieve all courses that will need to be deleted from core data if they are not returned by the web service call
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *sectionEntry = [NSEntityDescription entityForName:@"Module" inManagedObjectContext:context];

    [request setEntity:sectionEntry];

    NSPredicate *sectionPredicate = [NSPredicate predicateWithFormat:@"section = %@", self];
    [request setPredicate:sectionPredicate];
    NSArray *modules = [context executeFetchRequest:request error:&error];

    for (Module *mod in modules)
    {
        [mod removeContents];
        [context deleteObject:mod];
    }

    [context performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];
}


+ (void)addModulesFromArray:(NSManagedObject *)section modules:(NSArray *)wsModules
{
    NSLog(@"add modules to section from web service return [addModulesFromArray]");
    int sortorder = 1;

    for (NSDictionary *wsModule in wsModules)
    {
        // remember the order in webservice response
        [wsModule setValue:[NSNumber numberWithInt:sortorder] forKey:@"sortorder"];
        sortorder++;
        // add new modules or update existing modules
        [Module addToSection:wsModule section:section];
    }

    // remove modules which doesn't exist in web service response
    [Section removeModulesFromSection:(Section *)section excludedModules:wsModules];
}
@end
