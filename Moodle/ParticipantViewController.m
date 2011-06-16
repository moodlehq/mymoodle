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
#import "WSClient.h"


@implementation ParticipantViewController
@synthesize participant;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize profilePictureView;
@synthesize phoneNumber;
@synthesize fullname;
@synthesize course;

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

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //retrieve the participant information
        WSClient *client   = [[WSClient alloc] init];
        NSNumber *participantid = [participant valueForKey:@"userid"];
        NSArray *userids = [[NSArray alloc] initWithObjects: participantid, nil];
        NSArray *paramvalues = [[NSArray alloc] initWithObjects: userids, nil];
        NSArray *paramkeys   = [[NSArray alloc] initWithObjects:@"userids", nil];
        NSDictionary *params = [[NSDictionary alloc] initWithObjects: paramvalues forKeys:paramkeys];
        NSLog(@"%@", params);
        NSArray *result;
        @try {
            result = [client invoke: @"moodle_user_get_users_by_id" withParams: (NSArray *)params];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        
        [client release];
    
        //TODO: make it more generic to support when call from a view where the participant hasn't been previously added in core data
        //or manage when the user has been deleted on the Moodle site
        
        NSError *error = nil;
        if (result && [result isKindOfClass:[NSDictionary class]]) {
            for (NSDictionary *theparticipant in result) { //only one participant is returned
                
                //set the participant values
                [participant setValue:[theparticipant objectForKey: @"username"] forKey:@"username"];
                [participant setValue:[theparticipant objectForKey: @"firstname"] forKey:@"firstname"];
                [participant setValue:[theparticipant objectForKey: @"lastname"] forKey:@"lastname"];
                [participant setValue:[theparticipant objectForKey: @"fullname"] forKey:@"fullname"];
                [participant setValue:[theparticipant objectForKey: @"email"]  forKey:@"email"];
                [participant setValue:[theparticipant objectForKey: @"address"] forKey:@"address"];
                [participant setValue:[theparticipant objectForKey: @"phone1"] forKey:@"phone1"];
                [participant setValue:[theparticipant objectForKey: @"phone2"] forKey:@"phone2"];
                [participant setValue:[theparticipant objectForKey: @"icq"] forKey:@"icq"];
                [participant setValue:[theparticipant objectForKey: @"skype"] forKey:@"skype"];
                [participant setValue:[theparticipant objectForKey: @"yahoo"] forKey:@"yahoo"];
                [participant setValue:[theparticipant objectForKey: @"aim"] forKey:@"aim"];
                [participant setValue:[theparticipant objectForKey: @"msn"] forKey:@"msn"];
                [participant setValue:[theparticipant objectForKey: @"department"] forKey:@"department"];
                [participant setValue:[theparticipant objectForKey: @"institution"] forKey:@"institution"];
                [participant setValue:[theparticipant objectForKey: @"interests"] forKey:@"interests"];
                [participant setValue:[NSDate dateWithTimeIntervalSince1970:(int)[theparticipant objectForKey: @"firstaccess"]] forKey:@"firstaccess"];
                [participant setValue:[NSDate dateWithTimeIntervalSince1970:(int)[theparticipant objectForKey: @"lastaccess"]] forKey:@"lastaccess"];
                [participant setValue:[theparticipant objectForKey: @"idnumber"] forKey:@"idnumber"];
                [participant setValue:[theparticipant objectForKey: @"lang"] forKey:@"lang"];
                [participant setValue:[theparticipant objectForKey: @"timezone"] forKey:@"timezone"];
                [participant setValue:[theparticipant objectForKey: @"description"] forKey:@"desc"];
                [participant setValue:[theparticipant objectForKey: @"descriptionformat"] forKey:@"descformat"];
                [participant setValue:[theparticipant objectForKey: @"city"] forKey:@"city"];
                [participant setValue:[theparticipant objectForKey: @"url"] forKey:@"url"];
                [participant setValue:[theparticipant objectForKey: @"country"] forKey:@"country"];
                [participant setValue:[theparticipant objectForKey: @"profileimageurlsmall"] forKey:@"profileimgurlsmall"];
                [participant setValue:[theparticipant objectForKey: @"profileimageurl"] forKey:@"profileimgurl"];

                //save the modification
                if (![[participant managedObjectContext] save:&error]) {
                    NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
                    NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
                    if(detailedErrors != nil && [detailedErrors count] > 0) {
                        for(NSError* detailedError in detailedErrors) {
                            NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                        }
                    }
                    else {
                        NSLog(@"  %@", [error userInfo]);
                    }
                }
            }
        }
}

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
    fullname.text = [NSString stringWithFormat:@"%@",[participant valueForKey:@"fullname"]];


}

@end
