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


-(void)addCoursesObject:(NSManagedObject *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

    [self willChangeValueForKey:@"courses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"courses"] addObject:value];
    [self didChangeValueForKey:@"courses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

-(void)removeCoursesObject:(NSManagedObject *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];

    [self willChangeValueForKey:@"courses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"courses"] removeObject:value];
    [self didChangeValueForKey:@"courses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

-(void)addCourses:(NSSet *)value
{
    [self willChangeValueForKey:@"courses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"courses"] unionSet:value];
    [self didChangeValueForKey:@"courses" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

-(void)removeCourses:(NSSet *)value
{
    [self willChangeValueForKey:@"courses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"courses"] minusSet:value];
    [self didChangeValueForKey:@"courses" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

+(NSInteger)countWithContext:(NSManagedObjectContext *)context course:(NSManagedObject *)course
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    [request setEntity:[NSEntityDescription entityForName:@"Participant" inManagedObjectContext:context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(ANY courses == %@)", course]];
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

+(void)update:(Participant *)db dict:(NSDictionary *)dict course:(NSManagedObject *)course
{
    [db setValue:[dict objectForKey:@"id"]    forKey:@"userid"];
    [db setValue:[dict objectForKey:@"firstname"] forKey:@"firstname"];
    [db setValue:[dict objectForKey:@"lastname"]  forKey:@"lastname"];
    [db setValue:[dict objectForKey:@"fullname"]  forKey:@"fullname"];
    [db setValue:[dict objectForKey:@"username"]  forKey:@"username"];
    [db setValue:[dict objectForKey:@"profileimageurl"] forKey:@"profileimageurl"];
    [db setValue:[dict objectForKey:@"profileimageurlsmall"] forKey:@"profileimageurlsmall"];
    [db setValue:[dict objectForKey:@"id"] forKey:@"userid"];
    [db setValue:[dict objectForKey:@"username"] forKey:@"username"];
    [db setValue:[dict objectForKey:@"firstname"] forKey:@"firstname"];
    [db setValue:[dict objectForKey:@"lastname"] forKey:@"lastname"];
    [db setValue:[dict objectForKey:@"fullname"] forKey:@"fullname"];
    [db setValue:[dict objectForKey:@"email"]  forKey:@"email"];
    [db setValue:[dict objectForKey:@"address"] forKey:@"address"];
    [db setValue:[dict objectForKey:@"phone1"] forKey:@"phone1"];
    [db setValue:[dict objectForKey:@"phone2"] forKey:@"phone2"];
    [db setValue:[dict objectForKey:@"icq"] forKey:@"icq"];
    [db setValue:[dict objectForKey:@"skype"] forKey:@"skype"];
    [db setValue:[dict objectForKey:@"yahoo"] forKey:@"yahoo"];
    [db setValue:[dict objectForKey:@"aim"] forKey:@"aim"];
    [db setValue:[dict objectForKey:@"msn"] forKey:@"msn"];
    [db setValue:[dict objectForKey:@"department"] forKey:@"department"];
    [db setValue:[dict objectForKey:@"institution"] forKey:@"institution"];
    [db setValue:[dict objectForKey:@"interests"] forKey:@"interests"];
    [db setValue:[NSDate dateWithTimeIntervalSince1970:(int)[dict objectForKey:@"firstaccess"]] forKey:@"firstaccess"];
    [db setValue:[NSDate dateWithTimeIntervalSince1970:(int)[dict objectForKey:@"lastaccess"]] forKey:@"lastaccess"];
    [db setValue:[dict objectForKey:@"idnumber"] forKey:@"idnumber"];
    [db setValue:[dict objectForKey:@"lang"] forKey:@"lang"];
    [db setValue:[dict objectForKey:@"timezone"] forKey:@"timezone"];
    [db setValue:[dict objectForKey:@"description"] forKey:@"desc"];
    [db setValue:[dict objectForKey:@"descriptionformat"] forKey:@"descformat"];
    [db setValue:[dict objectForKey:@"city"] forKey:@"city"];
    [db setValue:[dict objectForKey:@"url"] forKey:@"url"];
    [db setValue:[dict objectForKey:@"country"] forKey:@"country"];

    if (course)
    {
        [db setValue:[course valueForKey:@"site"] forKey:@"site"];
        [db addCoursesObject:course];
    }

    NSError *error;
    // save the modification
    if (![[db managedObjectContext] save:&error])
    {
        NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
        NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if (detailedErrors != nil && [detailedErrors count] > 0)
        {
            for (NSError *detailedError in detailedErrors)
            {
                NSLog(@"  DetailedError: %@", [detailedError userInfo]);
            }
        }
        else
        {
            NSLog(@"  %@", [error userInfo]);
        }
    }
}
@end
