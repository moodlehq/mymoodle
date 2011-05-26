//
//  Participant.h
//  Moodle
//
//  Created by Dongsheng Cai on 26/05/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Participant : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * userid;
@property (nonatomic, retain) NSString * profileimgurl;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * firstname;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSManagedObject * site;
@property (nonatomic, retain) NSSet* courses;

@end
