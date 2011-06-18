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
#import "AppDelegate.h"

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
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *token = [app.site valueForKey: @"token"];
        NSString *wsurl = [[NSString alloc] initWithFormat:@"%@/webservice/xmlrpc/server.php?wstoken=%@", host, token];
        self.url = [NSURL URLWithString: wsurl];
        [wsurl release];
    }

    NSLog(@"API URL: %@", self.url);
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
        NSLog(@"Error: %@", err);
        [http release];
		return err;
	}
//    NSLog(@"XML: %@", [http responseString]);
	XMLRPCResponse *xmlrpcdata = [[[XMLRPCResponse alloc] initWithData: [http responseData]] autorelease];
    [http release];

    id object = [xmlrpcdata object];
    NSLog(@"WSClient: %@", object);
    if ([object isKindOfClass: [NSDictionary class]]) {
        if ([object valueForKey:@"faultString"]) {
            [NSException raise:@"XMLRPC Error" format:@"%@", [object valueForKey:@"faultString"]];
        }
    }
    return object;
}


- (void)dealloc {
    [super dealloc];
}
@end
