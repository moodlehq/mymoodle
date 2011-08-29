//
//  AddressAnnotation.h
//  Moodle
//
//  Created by Dongsheng Cai on 29/08/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AddressAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;

	NSString *mTitle;
	NSString *mSubTitle;
}
-(id)initWithCoordinate:(CLLocationCoordinate2D) c;
- (void)setContact: (NSString *)name withAddress: (NSString *)address;
@end
