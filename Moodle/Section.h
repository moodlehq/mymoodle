//
//  Section.h
//  Moodle
//
//  Created by Dongsheng Cai on 11/10/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Module;

@interface Section : NSManagedObject

@property (nonatomic, retain) NSNumber *id;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSManagedObject *course;
@property (nonatomic, retain) NSSet *modules;
@end

@interface Section (CoreDataGeneratedAccessors)

- (void)addModulesObject:(Module *)value;
- (void)removeModulesObject:(Module *)value;
- (void)addModules:(NSSet *)values;
- (void)removeModules:(NSSet *)values;
@end


@interface Section (Moodle)
- (void)removeModules;
+ (void)addModulesFromArray:(NSManagedObject *)section modules:(NSArray *)wsModules;
+ (void)removeModulesFromSection:(Section *)section excludedModules:(NSArray *)modules;
@end
