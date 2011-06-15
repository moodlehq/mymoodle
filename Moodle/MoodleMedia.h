//
//  MoodleMedia.h
//  Moodle
//
//  Created by Dongsheng Cai on 30/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MoodleUploadDelegate
-(void)uploadCallback: (id)data;
-(NSString *)getFilepath;
@end

@interface MoodleMedia : NSObject {
    
}

+ (void)upload:(id<MoodleUploadDelegate>)sender;
+ (void)upload:(id)data format: (NSString *)dataformat;
+ (BOOL)test:(id)data format: (NSString *)dataformat;
@end
