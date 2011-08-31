//
//  MoodleMedia.h
//  Moodle
//
//  Created by Dongsheng Cai on 30/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MoodleUploadDelegate
@required
- (void)uploadDidFinishUploading: (id)data;
- (void)uploadFailed:(id)data;
- (NSString *)uploadFilepath;
@end

@interface MoodleMedia : NSObject {
}

+ (void)upload:(id<MoodleUploadDelegate>)sender;
@end
