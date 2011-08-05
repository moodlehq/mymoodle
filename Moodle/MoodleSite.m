//
//  MoodleSite.m
//  Moodle
//
//  Created by Dongsheng Cai on 25/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "MoodleSite.h"
#import "Constants.h"

@implementation MoodleSite


+ (BOOL)siteExistsForURL:(NSString *)theURL withContext:(NSManagedObjectContext *)moc andUsername:(NSString *)username
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Site"
                                        inManagedObjectContext:moc]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"url like %@ AND username = %@", theURL, username]];
    NSError *error = nil;
    NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    fetchRequest = nil;

    return results.count > 0;
}
+ (NSInteger)countWithContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

    [request setEntity:[NSEntityDescription entityForName:@"Site" inManagedObjectContext:context]];
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

+ (void)deleteSite:(NSManagedObjectContext *)context withSite:(NSManagedObject *)site
{
    // delete the user/site default is they were matching the delete site
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultSiteUrl = [defaults objectForKey:kSelectedSiteUrlKey];
    NSNumber *defaultUserId = [defaults objectForKey:kSelectedUserIdKey];

    BOOL resetCurrentSite = NO;

    // delete current site
    if (([[site valueForKey:@"url"] isEqualToString:defaultSiteUrl] && [[site valueForKeyPath:@"mainuser.userid"] isEqualToNumber:defaultUserId]))
    {
        [defaults removeObjectForKey:kSelectedSiteUrlKey];
        [defaults removeObjectForKey:kSelectedSiteTokenKey];
        [defaults removeObjectForKey:kSelectedSiteNameKey];
        [defaults removeObjectForKey:kSelectedUserIdKey];
        NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"", kSelectedSiteUrlKey,
                                     @"", kSelectedSiteNameKey,
                                     @"", kSelectedSiteTokenKey,
                                     @"", kSelectedUserIdKey,
                                     nil];

        [defaults registerDefaults:appDefaults];
        [NSUserDefaults resetStandardUserDefaults];
        resetCurrentSite = YES;
    }

    // delete main user
    NSFetchRequest *mainuserRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *mainuserDescription = [NSEntityDescription entityForName:@"MainUser" inManagedObjectContext:context];
    [mainuserRequest setEntity:mainuserDescription];
    NSPredicate *mainuserPredicate = [NSPredicate predicateWithFormat:@"(site = %@)", site];
    [mainuserRequest setPredicate:mainuserPredicate];
    NSArray *mainusers = [context executeFetchRequest:mainuserRequest error:nil];
    for (NSManagedObject *mainuser in mainusers)
    {
        [context deleteObject:mainuser];
    }
    [mainuserRequest release];
    NSLog(@"Deleted mainuser");

    // delete web services
    NSFetchRequest *wsRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *wsDescription = [NSEntityDescription entityForName:@"WebService" inManagedObjectContext:context];
    [wsRequest setEntity:wsDescription];
    NSPredicate *wsPredicate = [NSPredicate predicateWithFormat:@"(site = %@)", site];
    [wsRequest setPredicate:wsPredicate];
    NSArray *webservices = [context executeFetchRequest:wsRequest error:nil];
    for (NSManagedObject *ws in webservices)
    {
        [context deleteObject:ws];
    }
    [wsRequest release];
    NSLog(@"Deleted web services");

    // delete all jobs
    NSFetchRequest *taskRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *taskDescription = [NSEntityDescription entityForName:@"Job" inManagedObjectContext:context];
    [taskRequest setEntity:taskDescription];
    NSPredicate *taskPredicate = [NSPredicate predicateWithFormat:@"(site = %@)", site];
    [taskRequest setPredicate:taskPredicate];
    NSArray *tasks = [context executeFetchRequest:taskRequest error:nil];
    for (NSManagedObject *task in tasks)
    {
        [context deleteObject:task];
    }
    [taskRequest release];
    NSLog(@"Deleted tasks");

    // delete all courses
    NSFetchRequest *courseRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *courseDescription = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:context];
    [courseRequest setEntity:courseDescription];
    NSPredicate *coursePredicate = [NSPredicate predicateWithFormat:@"(site = %@)", site];
    [courseRequest setPredicate:coursePredicate];
    NSArray *allCourses = [context executeFetchRequest:courseRequest error:nil];
    for (NSManagedObject *course in allCourses)
    {
        [context deleteObject:course];
    }
    [courseRequest release];
    NSLog(@"Deleted courses");

    // delete all participants
    NSFetchRequest *userRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *userDescription = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext:context];
    [userRequest setEntity:userDescription];
    NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"(site = %@)", site];
    [userRequest setPredicate:userPredicate];
    NSArray *users = [context executeFetchRequest:userRequest error:nil];
    for (NSManagedObject *user in users)
    {
        [context deleteObject:user];
    }
    [userRequest release];
    NSLog(@"Deleted users");

    // delete site entry
    [context deleteObject:site];
    NSLog(@"Deleted site");

    NSError *error;
    if (![context save:&error])
    {
        NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
        NSArray *detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
        if (detailedErrors != nil && [detailedErrors count] > 0)
        {
            for (NSError *detailedError in detailedErrors)
            {
                NSLog(@"Detailed Error: %@", [detailedError userInfo]);
            }
        }
        else
        {
            NSLog(@"  %@", [error userInfo]);
        }
    }

    if (resetCurrentSite)
    {
        // send notification to appdelete to reset site
        [[NSNotificationCenter defaultCenter] postNotificationName:kResetSite
                                                            object:nil];
    }

}
@end
