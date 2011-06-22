//
//  Participant.m
//  Moodle
//
//  Created by Dongsheng Cai on 20/06/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import "Participant.h"


@implementation Participant
@dynamic userid;
@dynamic lastname;
@dynamic lang;
@dynamic fullname;
@dynamic url;
@dynamic firstname;
@dynamic idnumber;
@dynamic country;
@dynamic descformat;
@dynamic icq;
@dynamic profileimgurlsmall;
@dynamic city;
@dynamic lastaccess;
@dynamic aim;
@dynamic phone2;
@dynamic profileimgurl;
@dynamic msn;
@dynamic department;
@dynamic email;
@dynamic institution;
@dynamic timezone;
@dynamic yahoo;
@dynamic phone1;
@dynamic skype;
@dynamic firstaccess;
@dynamic interests;
@dynamic desc;
@dynamic address;
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
