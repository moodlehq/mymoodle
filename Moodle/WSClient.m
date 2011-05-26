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
#import "Constants.h"

@implementation WSClient

@synthesize url;

-(id)initWithToken: (NSString *)token withHost:(NSString *)host{
    //Note: [NSString stringWithFormat] => autorelease, I changed it for alloc, note I could also have choosen to comment [wsurl release] line instead to do alloc manually
    NSString *wsurl = [[NSString alloc] initWithFormat:@"%@/webservice/xmlrpc/server.php?wstoken=%@", host, token];
    self.url = [NSURL URLWithString: wsurl];
    [wsurl release];
    return self;
}

-(id)invoke:(NSString *)method withParams: (NSArray *)params {
    if (self.url == nil) {
        NSString *host = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteUrlKey];
        NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:kSelectedSiteTokenKey];
        NSString *wsurl = [[NSString alloc] initWithFormat:@"%@/webservice/xmlrpc/server.php?wstoken=%@", host, token];
        self.url = [NSURL URLWithString: wsurl];
        //[host release]; //Note for dongsheng => no needed, autorelease.  Anything in Cocoa that is not alloc, copy or new are autoreleased before they are returned to the caller
        //[token release];
        [wsurl release];
    }
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
        [http release];
		return err;
	}
	XMLRPCResponse *data = [[[XMLRPCResponse alloc] initWithData: [http responseData]] autorelease];
    [http release];
    return [data object];
}


- (void)dealloc {
    //[self.url release]; //you didn't create it
    [super dealloc];
}
@end
