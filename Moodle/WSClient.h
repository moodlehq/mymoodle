//
//  WSClient.h
//  Moodle
//
//  Created by Dongsheng Cai <dongsheng@moodle.com> on 25/03/11.
//  Copyright 2011 Moodle Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMLRPCRequest;

@interface WSClient : NSObject {
    NSURL *url;
}

@property (nonatomic, copy) NSURL *url;

-(id)invoke:(NSString *)method withParams: (NSArray *)params;

-(id)initWithToken: (NSString *)host withHost: (NSString *)host;
@end
