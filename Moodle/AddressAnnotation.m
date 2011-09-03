//
//  AddressAnnotation.m
//  Moodle
//
//  Created by Dongsheng Cai on 29/08/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "AddressAnnotation.h"

@implementation AddressAnnotation

@synthesize coordinate;

- (NSString *)subtitle {
	return mSubTitle;
}
- (NSString *)title {
	return mTitle;
}
- (void)setContact: (NSString *)name withAddress: (NSString *)address {
    mTitle = name;
    mSubTitle = address;
}


-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
	coordinate=c;
	return self;
}

@end
