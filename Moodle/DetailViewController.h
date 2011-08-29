//
//  DetailViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 16/06/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import <AddressBook/AddressBook.h>
#import "MoodleKit.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MapKit/MapKit.h>


#define TAG_BUTTON_SEND    1
#define TAG_BUTTON_NOTE    2
#define TAG_BUTTON_UPDATE  3
#define TAG_BUTTON_CONTACT 4

#define ALERT_MSG          1
#define ALERT_NOTE         2

#define BUTTON_WIDTH       130
#define TABLE_MARGIN       20

@class Participant;

@interface DetailViewController : UITableViewController <UIGestureRecognizerDelegate, TTPostControllerDelegate, SDWebImageManagerDelegate, MBProgressHUDDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
    AppDelegate *appDelegate;
    NSManagedObjectContext *managedObjectContext;
    Participant *_participant;
    NSManagedObject *_course;
    // table data
    NSMutableArray *contactinfo;
    NSMutableArray *geoinfo;
    // UI controls
    UIView *tableviewFooter;
    UIImageView *userpicture;
    MBProgressHUD *HUD;

    // gesture
    UISwipeGestureRecognizer *swipeLeftRecognizer;

    // flag
    NSInteger postControllerType;

}
@property (nonatomic, retain) Participant *participant;
@property (nonatomic, retain) NSManagedObject *course;
@end
