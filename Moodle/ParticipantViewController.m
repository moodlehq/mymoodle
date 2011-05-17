//
//  ParticipantViewController.m
//  Moodle
//
//  Created by jerome Mouneyrac on 11/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "ParticipantViewController.h"
#import "HashValue.h"
#import "Reachability.h"


@implementation ParticipantViewController
@synthesize participant;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize profilePictureView;
@synthesize phoneNumber;
@synthesize fullname;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
            }
    return self;
}

- (void)dealloc
{
    [profilePictureView release];
    [phoneNumber release];
    [fullname release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    self.profilePictureView = nil;
    self.phoneNumber = nil;
    self.fullname = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.title = NSLocalizedString(@"info", @"info");
    
    //Set the image
    //retrieve Documents folder path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths lastObject];
    //create file path (Documents/md5(profileimgurl))
    NSString *md5ProfileUrl = [HashValue getMD5FromString:[participant valueForKey:@"profileimgurl"]];
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@", documentsDirectoryPath, md5ProfileUrl];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSData *imageData;
    BOOL displayDefaultImg = NO;
    if (fileExists) {
        imageData = [[NSData alloc] initWithContentsOfFile:filePath];
        NSLog(@"the file exists: %@", filePath);
    } else if ([Reachability reachabilityForInternetConnection]) {
        imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[participant valueForKey:@"profileimgurl"]]];
        NSLog(@"the file doesn't exist: %@", filePath);
    } else {
        displayDefaultImg = YES;
    }
    
    if (displayDefaultImg) {
        //no cached profile picture and no connection, display a dummy picture
        profilePictureView.image = [UIImage imageNamed:@"Participants.png"];
    } else {
        [imageData writeToFile:filePath atomically:YES];
        profilePictureView.image = [UIImage imageWithData: imageData];
        [imageData release];
    }
    [filePath release];

    //Set the labels
    fullname.text = [NSString stringWithFormat:@"%@ %@",[participant valueForKey:@"firstname"], [participant valueForKey:@"lastname"]];
    
    
}

@end
