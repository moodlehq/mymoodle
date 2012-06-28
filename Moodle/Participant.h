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
//  Participant.h
//  Moodle
//
//  Created by Dongsheng Cai on 20/06/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Participant : NSManagedObject {
    @private
}
@property (nonatomic, retain) NSNumber *userid;
@property (nonatomic, retain) NSString *lastname;
@property (nonatomic, retain) NSString *lang;
@property (nonatomic, retain) NSString *fullname;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *firstname;
@property (nonatomic, retain) NSString *idnumber;
@property (nonatomic, retain) NSString *country;
@property (nonatomic, retain) NSNumber *descformat;
@property (nonatomic, retain) NSString *icq;
@property (nonatomic, retain) NSString *profileimgurlsmall;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSDate *lastaccess;
@property (nonatomic, retain) NSString *aim;
@property (nonatomic, retain) NSString *phone2;
@property (nonatomic, retain) NSString *profileimgurl;
@property (nonatomic, retain) NSString *msn;
@property (nonatomic, retain) NSString *department;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *institution;
@property (nonatomic, retain) NSString *timezone;
@property (nonatomic, retain) NSString *yahoo;
@property (nonatomic, retain) NSString *phone1;
@property (nonatomic, retain) NSString *skype;
@property (nonatomic, retain) NSDate *firstaccess;
@property (nonatomic, retain) NSString *interests;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSManagedObject *site;
@property (nonatomic, retain) NSSet *courses;
- (void)addCoursesObject:(NSManagedObject *)value;
- (void)removeCoursesObject:(NSManagedObject *)value;
+ (NSInteger)countWithContext:(NSManagedObjectContext *)context course:(NSManagedObject *)course;
+ (void)update:(Participant *)db dict:(NSDictionary *)dict course:(NSManagedObject *)course;
@end
