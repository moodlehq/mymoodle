//
//  NSURL+Additions.m
//  Moodle
//
//  Created by Dongsheng Cai on 25/11/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import "NSURL+Additions.h"

@implementation NSURL (Additions)
- (NSURL *)URLByAppendingQueryString:(NSString *)queryString {
    if (![queryString length]) {
        return self;
    }

    NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [self absoluteString],
                           [self query] ? @"&" : @"?", queryString];
    NSLog(@"new url: %@", URLString);
    NSURL *theURL = [NSURL URLWithString:URLString];
    [URLString release];
    return theURL;
}
@end
