//
//  DetailViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 29/08/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "MapViewController.h"
#import "AddressAnnotation.h"

@implementation MapViewController

@synthesize mapView;


#pragma mark -

- (void)gotoLocation
{
    // start off by default in San Francisco
    MKCoordinateRegion newRegion;

    newRegion.center.latitude = location.latitude;
    newRegion.center.longitude = location.longitude;
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    AddressAnnotation *addr = [[AddressAnnotation alloc] initWithCoordinate:location];
    [addr setContact:name withAddress:address];
    [self.mapView addAnnotation:addr];
    [addr release];
    [self.mapView setRegion:newRegion animated:YES];
    [self.mapView regionThatFits:newRegion];
}

- (id)initWithAddress:(NSString *)_address withName:(NSString *)_name
{
    if ((self = [super init]))
    {
    }
    address = _address;
    [address retain];
    name = _name;
    return self;
}

- (void)loadView
{
    [super loadView];
    mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:mapView];
}

- (void)viewDidLoad
{
    self.mapView.mapType = MKMapTypeStandard;

    // create a custom navigation bar button and set it to always says "Back"
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = NSLocalizedString(@"back", nil);
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [temporaryBarButtonItem release];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/geo?q=%@&output=csv",
                           [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *locationString = [NSString stringWithContentsOfURL:[NSURL URLWithString:urlString] encoding:NSUTF8StringEncoding error:nil];
    NSArray *listItems = [locationString componentsSeparatedByString:@","];
    double latitude = 0.0;
    double longitude = 0.0;

    if ([listItems count] >= 4 && [[listItems objectAtIndex:0] isEqualToString:@"200"])
    {
        latitude = [[listItems objectAtIndex:2] doubleValue];
        longitude = [[listItems objectAtIndex:3] doubleValue];
    }
    else
    {
        // Show error
    }
    location.latitude = latitude;
    location.longitude = longitude;
    [self gotoLocation];
}

- (void)viewDidUnload
{
    address = nil;
    self.mapView = nil;
}

- (void)dealloc
{
    [address release];
    [mapView release];
    [super dealloc];
}

@end
