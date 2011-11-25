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
