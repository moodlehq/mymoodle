//
//  DetailViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 16/06/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>
{
    MKMapView *mapView;
    NSString *address;
    NSString *name;
    CLLocationCoordinate2D location;
}

@property (nonatomic, retain) MKMapView *mapView;

- (id)initWithAddress: (NSString *)_ddress withName: (NSString *)_name;
@end
