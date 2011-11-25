//
//  WebViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 22/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "WebViewController.h"
#import "Constants.h"

@implementation WebViewController

- (void)loadView
{
    [super loadView];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationBarTintColor = UIColorFromRGB(ColorNavigationBar);
    [super viewWillAppear:animated];
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [_webView loadHTMLString:string baseURL:baseURL];
}
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    [_webView loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
}

@end
