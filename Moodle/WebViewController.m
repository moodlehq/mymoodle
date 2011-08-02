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

-(void)loadView
{
    [super loadView];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationBarTintColor = UIColorFromRGB(ColorNavigationBar);
    [super viewWillAppear:animated];
}

@end
