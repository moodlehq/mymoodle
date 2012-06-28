//
// This file is part of My Moodle - https://github.com/moodlehq/mymoodle
//
// My Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Moodle.  If not, see <http://www.gnu.org/licenses/>.
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
