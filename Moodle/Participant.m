//
//  Participant.m
//  Moodle
//
//  Created by Dongsheng Cai on 26/05/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import "Participant.h"


@implementation Participant
@dynamic userid;
@dynamic profileimgurl;
@dynamic lastname;
@dynamic firstname;
@dynamic username;
@dynamic site;
@dynamic courses;


- (void)addCoursesObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"courses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"courses"] addObject:value];
    [self didChangeValueForKey:@"courses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeCoursesObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"courses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"courses"] removeObject:value];
    [self didChangeValueForKey:@"courses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addCourses:(NSSet *)value {    
    [self willChangeValueForKey:@"courses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"courses"] unionSet:value];
    [self didChangeValueForKey:@"courses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeCourses:(NSSet *)value {
    [self willChangeValueForKey:@"courses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"courses"] minusSet:value];
    [self didChangeValueForKey:@"courses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
