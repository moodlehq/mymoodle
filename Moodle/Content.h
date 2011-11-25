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
