//
//  Downloader.h
//  Moodle
//
//  Created by Dongsheng Cai on 5/10/11.
//  Copyright (c) 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Downloader : NSObject {
    NSMutableArray *connections;
}

- (id)initWithFiles:(NSArray *)files;
- (NSArray *)getRequests;
@end
