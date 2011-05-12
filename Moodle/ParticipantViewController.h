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
}

@property (nonatomic, retain) NSManagedObject *participant;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end


