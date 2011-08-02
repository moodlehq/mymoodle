//
//  Job.h
//  Moodle
//
//  Created by Dongsheng Cai on 3/06/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MoodleJob : NSManagedObject {
    @private
}
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *target;
@property (nonatomic, retain) NSString *action;
@property (nonatomic, retain) NSString *data;
@property (nonatomic, retain) NSString *dataformat;
@property (nonatomic, retain) NSString *created;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, retain) NSManagedObject *site;
+ (NSInteger)countWithContext:(NSManagedObjectContext *)context;

@end
