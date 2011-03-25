//
//  WSClient.m
//  Moodle
//
//  Created by Dongsheng Cai <dongsheng@moodle.com> on 25/03/11.
//  Copyright 2011 Moodle Pty Ltd. All rights reserved.
//

#import "WSClient.h"
#import "ASIHTTPRequest.h"
#import "XMLRPCRequest.h"
#import "XMLRPCResponse.h"

@implementation WSClient

@synthesize url;

-(id)initWithToken: (NSString *)host {
    self.url = [NSURL URLWithString:host];
    return self;
}

-(id)invoke:(NSString *)method withParams: (NSArray *)params {
    
    XMLRPCRequest *req = [[[XMLRPCRequest alloc] initWithHost: self.url] autorelease];
    [req setMethod:method withObjects: params];
    
	ASIHTTPRequest *http =[[ASIHTTPRequest alloc] initWithURL: [req host]];
	[http setRequestMethod:@"POST"];
	[http setShouldPresentCredentialsBeforeChallenge: YES];
	[http setShouldPresentAuthenticationDialog: YES];
	[http setUseKeychainPersistence: YES];
	[http setValidatesSecureCertificate: NO];
	[http setNumberOfTimesToRetryOnTimeout:2];
	
	[http appendPostData: [[req source] dataUsingEncoding: NSUTF8StringEncoding]];
	[http startSynchronous];
	
	NSError *err = [http error];
	
	if (err) {
		NSLog(@"%@", err);
		return err;
	}
	
	NSLog(@"Before parsing: %@", [http responseString]);
	XMLRPCResponse *data = [[[XMLRPCResponse alloc] initWithData: [http responseData]] autorelease];
	NSLog(@"Done: %@", [data object]);
	return [data object];
}

@end
