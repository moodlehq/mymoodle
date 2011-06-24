//
//  DetailViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 16/06/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "SDWebImageManager.h"
#import "Participant.h"

@interface DetailViewController : UITableViewController <UIGestureRecognizerDelegate, TTPostControllerDelegate, SDWebImageManagerDelegate> {
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


