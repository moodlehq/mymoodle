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
//  Site.m
//  Moodle
//
//  Created by Dongsheng Cai on 18/11/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import "Site.h"
#import "AppDelegate.h"
#import "MoodleKit.h"


@implementation Site

@dynamic name;
@dynamic url;
@dynamic userpictureurl;
@dynamic token;
@dynamic downloadfiles;
@dynamic jobs;
@dynamic courses;
@dynamic users;
@dynamic mainuser;
@dynamic webservices;

+ (NSManagedObject *)updateSite:(NSManagedObject *)site info:(NSDictionary *)wsSiteinfo newEntry:(BOOL)newEntry
{
    NSError *error;

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =  appDelegate.managedObjectContext;

    // create/update the site
    [site setValue:[wsSiteinfo objectForKey:@"sitename"] forKey:@"name"];
    [site setValue:[wsSiteinfo objectForKey:@"userpictureurl"] forKey:@"userpictureurl"];
    [site setValue:[wsSiteinfo objectForKey:@"token"] forKey:@"token"];
    [site setValue:[wsSiteinfo objectForKey:@"url"] forKey:@"url"];
    [site setValue:[wsSiteinfo objectForKey:@"downloadfiles"] forKey:@"downloadfiles"];

    NSManagedObject *user;
    // retrieve participant main user
    if (newEntry)
    {
        NSEntityDescription *mainUserDesc = [NSEntityDescription entityForName:@"MainUser" inManagedObjectContext:context];
        user = [NSEntityDescription insertNewObjectForEntityForName:[mainUserDesc name]
                                             inManagedObjectContext:context];
    }
    else
    {
        user = [site valueForKey:@"mainuser"];
        // delete old web service records
        NSFetchRequest *wsRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *wsEntity = [NSEntityDescription entityForName:@"WebService" inManagedObjectContext:context];
        [wsRequest setEntity:wsEntity];
        NSPredicate *wsPredicate = [NSPredicate predicateWithFormat:@"(site = %@)", site];
        [wsRequest setPredicate:wsPredicate];
        NSArray *wsObjects = [context executeFetchRequest:wsRequest error:nil];
        for (NSManagedObject *wsObject in wsObjects)
        {
            [context deleteObject:wsObject];
        }

        [wsRequest release];
    }

    // set user values
    [user setValue:[wsSiteinfo objectForKey:@"userid"]    forKey:@"userid"];
    [user setValue:[wsSiteinfo objectForKey:@"username"]  forKey:@"username"];
    [user setValue:[wsSiteinfo objectForKey:@"firstname"] forKey:@"firstname"];
    [user setValue:[wsSiteinfo objectForKey:@"fullname"]  forKey:@"fullname"];
    [user setValue:[wsSiteinfo objectForKey:@"lastname"]  forKey:@"lastname"];
    [user setValue:site forKey:@"site"];
    [site setValue:user forKey:@"mainuser"];

    // Insert new web services
    NSManagedObject *webservice;
    NSArray *webservices = [wsSiteinfo objectForKey:@"functions"];
    NSEntityDescription *wsDesc = [NSEntityDescription entityForName:@"WebService" inManagedObjectContext:context];
    for (NSDictionary *function in webservices)
    {
        int version = [[function valueForKey:@"version"] intValue];
        webservice = [NSEntityDescription insertNewObjectForEntityForName:[wsDesc name] inManagedObjectContext:context];

        [webservice setValue:[function valueForKey:@"name"] forKey:@"name"];
        [webservice setValue:site forKey:@"site"];
        [webservice setValue:[NSNumber numberWithInt:version] forKey:@"version"];
    }
    // save the modification
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
    return site;
}

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

+ (void)deleteSite:(NSManagedObject *)site
{

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context =  appDelegate.managedObjectContext;

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
    NSLog(@"Deleting mainuser");
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

    // delete web services
    NSLog(@"Deleting web services");
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

    // delete all jobs
    NSLog(@"Deleting tasks");
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

    // delete all courses
    NSLog(@"Deleting courses");
    NSFetchRequest *courseRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *courseDescription = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:context];
    [courseRequest setEntity:courseDescription];
    NSPredicate *coursePredicate = [NSPredicate predicateWithFormat:@"(site = %@)", site];
    [courseRequest setPredicate:coursePredicate];
    NSArray *allCourses = [context executeFetchRequest:courseRequest error:nil];
    for (Course *course in allCourses)
    {
        if ([course respondsToSelector:@selector(removeSections)])
        {
            [course removeSections];
        }
        [context deleteObject:course];
    }
    [courseRequest release];

    // delete all participants
    NSLog(@"Deleting users");
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

    // delete site entry
    NSLog(@"Deleting the site finally");
    [context deleteObject:site];

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
