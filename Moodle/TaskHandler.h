//
//  TaskHandler.h
//  Moodle
//
//  Created by Dongsheng Cai on 26/07/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskHandler : NSObject
+(void)sendMessage:(id)data format:(NSString *)dataformat;
+(void)addNote:(id)data format:(NSString *)dataformat;
+(void)upload:(id)data format:(NSString *)dataformat;
@end
