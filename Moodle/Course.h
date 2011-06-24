//
//  Course.h
//  Moodle
//
//  Created by Dongsheng Cai on 24/06/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Course : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * idnumber;
@property (nonatomic, retain) NSString * shortname;
@property (nonatomic, retain) NSString * fullname;
@property (nonatomic, retain) NSSet* participants;
@property (nonatomic, retain) NSManagedObject * site;
+ (NSInteger)countWithContext:(NSManagedObjectContext *)context site: (NSManagedObject *)site;

@end
