//
//  ParticipantViewController.h
//  Moodle
//
//  Created by jerome Mouneyrac on 11/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ParticipantViewController : UIViewController {
    NSManagedObject *participant;
    UIImageView *profilePictureView;
    UILabel *phoneNumber;
    UILabel *fullname;
    NSManagedObject *course;
}

@property (nonatomic, retain) NSManagedObject *participant;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) IBOutlet UIImageView *profilePictureView;
@property (nonatomic, retain) IBOutlet UILabel *phoneNumber;
@property (nonatomic, retain) IBOutlet UILabel *fullname;
@property (nonatomic, retain) NSManagedObject *course;


@end


