//
//  NSStringAdditions.h
//  Moodle
//
//  Created by Dongsheng Cai on 17/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSStringAdditions)

+ (NSString *)base64StringFromData:(NSData *)data length:(int)length;

@end
