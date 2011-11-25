//
//  WebViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 22/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Three20/Three20.h>

@interface WebViewController : TTWebController {
}
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

@end
