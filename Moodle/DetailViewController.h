//
//  DetailViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 16/06/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DetailViewController : UITableViewController <UIGestureRecognizerDelegate> {

    NSManagedObject *_participant;
    NSManagedObject *_course;
    NSMutableArray  *contactinfo;
    NSMutableArray  *geoinfo;
    UISwipeGestureRecognizer *swipeLeftRecognizer;

}
@property (nonatomic, retain) NSManagedObject *participant;
@property (nonatomic, retain) NSManagedObject *course;

-(void)updateParticipant;
-(NSDictionary *)createInfo: (NSString *) key value: (NSString *)value;
@end


