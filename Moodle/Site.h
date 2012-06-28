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
//  Site.h
//  Moodle
//
//  Created by Dongsheng Cai on 18/11/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Site : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *userpictureurl;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSNumber *downloadfiles;
@property (nonatomic, retain) NSSet *jobs;
@property (nonatomic, retain) NSSet *courses;
@property (nonatomic, retain) NSSet *users;
@property (nonatomic, retain) NSManagedObject *mainuser;
@property (nonatomic, retain) NSSet *webservices;
@end

@interface Site (CoreDataGeneratedAccessors)

- (void)addJobsObject:(NSManagedObject *)value;
- (void)removeJobsObject:(NSManagedObject *)value;
- (void)addJobs:(NSSet *)values;
- (void)removeJobs:(NSSet *)values;
- (void)addCoursesObject:(NSManagedObject *)value;
- (void)removeCoursesObject:(NSManagedObject *)value;
- (void)addCourses:(NSSet *)values;
- (void)removeCourses:(NSSet *)values;
- (void)addUsersObject:(NSManagedObject *)value;
- (void)removeUsersObject:(NSManagedObject *)value;
- (void)addUsers:(NSSet *)values;
- (void)removeUsers:(NSSet *)values;
- (void)addWebservicesObject:(NSManagedObject *)value;
- (void)removeWebservicesObject:(NSManagedObject *)value;
- (void)addWebservices:(NSSet *)values;
- (void)removeWebservices:(NSSet *)values;

@end


@interface Site (Moodle)
#pragma mark -
#pragma mark Class methods
+ (BOOL)siteExistsForURL:(NSString *)theURL withContext:(NSManagedObjectContext *)moc andUsername:(NSString *)username;
+ (NSInteger)countWithContext:(NSManagedObjectContext *)context;
+ (void)deleteSite:(NSManagedObject *)site;
+ (NSManagedObject *)updateSite:(NSManagedObject *)site info:(NSDictionary *)wsSiteinfo newEntry:(BOOL)newEntry;
@end
