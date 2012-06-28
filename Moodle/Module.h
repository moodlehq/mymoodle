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
//  Module.h
//  Moodle
//
//  Created by Dongsheng Cai on 3/10/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Section.h"


@interface Module : NSManagedObject

@property (nonatomic, retain) NSString *modname;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSString *modicon;
@property (nonatomic, retain) NSSet *contents;
@property (nonatomic, retain) NSManagedObject *section;
@end

@interface Module (CoreDataGeneratedAccessors)

- (void)addContentsObject:(NSManagedObject *)value;
- (void)removeContentsObject:(NSManagedObject *)value;
- (void)addContents:(NSSet *)values;
- (void)removeContents:(NSSet *)values;
- (void)removeContents;

+ (NSManagedObject *)addToSection:(NSDictionary *)module section:(NSManagedObject *)section;

+ (void)removeContentsFromModule:(Module *)module excludedItems:(NSArray *)items;
+ (void)removeContentsFromModule:(Module *)module;
+ (void)removeFilesFromModule:(Module *)module;

@end
