//
//  Course.m
//  Moodle
//
//  Created by Dongsheng Cai on 24/06/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import "Course.h"
#import "AppDelegate.h"
#import "Section.h"

@implementation Course
@dynamic id;
@dynamic idnumber;
@dynamic shortname;
@dynamic fullname;
@dynamic participants;
@dynamic site;

- (void)addParticipantsObject:(NSManagedObject *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

    [self willChangeValueForKey:@"participants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"participants"] addObject:value];
    [self didChangeValueForKey:@"participants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeParticipantsObject:(NSManagedObject *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

    [self willChangeValueForKey:@"participants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"participants"] removeObject:value];
    [self didChangeValueForKey:@"participants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addParticipants:(NSSet *)value
{
    [self willChangeValueForKey:@"participants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"participants"] unionSet:value];
    [self didChangeValueForKey:@"participants" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeParticipants:(NSSet *)value
{
    [self willChangeValueForKey:@"participants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"participants"] minusSet:value];
    [self didChangeValueForKey:@"participants" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

+ (NSInteger)countWithContext:(NSManagedObjectContext *)context site:(NSManagedObject *)site
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    [request setEntity:[NSEntityDescription entityForName:@"Course" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(site = %@)", site]];
    [request setIncludesSubentities:NO];
    NSError *err;
    NSUInteger count = [context countForFetchRequest:request error:&err];
    [request release];
    if (count == NSNotFound)
    {
        count = 0;
    }
    return count;
}

- (void)removeSections
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    // retrieve all courses that will need to be deleted from core data if they are not returned by the web service call
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *sectionEntry = [NSEntityDescription entityForName:@"Section" inManagedObjectContext:context];

    [request setEntity:sectionEntry];
    NSError *error;

    NSPredicate *sectionPredicate = [NSPredicate predicateWithFormat:@"course = %@", self];
    [request setPredicate:sectionPredicate];
    NSArray *sections = [context executeFetchRequest:request error:&error];

    if (!error)
    {
        for (Section *section in sections)
        {
            [section removeModules];
            [context deleteObject:section];
        }
    }

    [context performSelectorOnMainThread:@selector(save:) withObject:nil waitUntilDone:YES];
}
@end
