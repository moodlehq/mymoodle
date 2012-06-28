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
//  Content.h
//  Moodle
//
//  Created by Dongsheng Cai on 12/10/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Module;

@interface Content : NSManagedObject

@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSNumber *timemodified;
@property (nonatomic, retain) NSNumber *timecreated;
@property (nonatomic, retain) NSNumber *filesize;
@property (nonatomic, retain) NSNumber *userid;
@property (nonatomic, retain) NSString *fileurl;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *localpath;
@property (nonatomic, retain) NSString *license;
@property (nonatomic, retain) Module *module;

+ (void)addToModule:(NSDictionary *)item module:(NSManagedObject *)module;
+ (void)removeContents:(Module *)module;
+ (void)removeFiles:(Module *)module;
@end
