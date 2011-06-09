//
//  ParticipantsViewController.h
//  Moodle
//
//  Created by Jerome Mouneyrac on 11/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticipantListViewController.h"
#import "AppDelegate.h"


@interface CoursesViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIAlertViewDelegate> {
    ParticipantListViewController *participantListViewController;
    NSManagedObjectContext *managedObjectContext;
    AppDelegate *appDelegate;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) ParticipantListViewController *participantListViewController;
@end
