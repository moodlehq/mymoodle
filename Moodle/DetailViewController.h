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
#import "SDWebImageManager.h"
#import "Participant.h"
#import "AppDelegate.h"

#define TAG_BUTTON_SEND 1
#define TAG_BUTTON_NOTE 2
#define TAG_BUTTON_UPDATE 3
#define TAG_BUTTON_CONTACT 4


#define ALERT_MSG 1
#define ALERT_NOTE 2

@interface DetailViewController : UITableViewController <UIGestureRecognizerDelegate, TTPostControllerDelegate, SDWebImageManagerDelegate, UIAlertViewDelegate> {
    AppDelegate *appDelegate;
    NSManagedObjectContext *managedObjectContext;
    Participant *_participant;
    NSManagedObject *_course;
    NSMutableArray  *contactinfo;
    NSMutableArray  *geoinfo;
    UIView *tableviewFooter;
    UIImageView *userpicture;
    NSInteger postControllerType;
    UISwipeGestureRecognizer *swipeLeftRecognizer;
}
@property (nonatomic, retain) Participant *participant;
@property (nonatomic, retain) NSManagedObject *course;
-(void)updateParticipant;
-(NSDictionary *)createInfo: (NSString *) key value: (NSString *)value;
@end


