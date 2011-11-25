//
//  NSURL+Additions.h
//  Moodle
//
//  Created by Dongsheng Cai on 25/11/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Additions)
- (NSURL *)URLByAppendingQueryString:(NSString *)queryString;
@end
