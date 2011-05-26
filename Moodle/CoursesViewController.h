//
//  ParticipantsViewController.h
//  Moodle
//
//  Created by Jerome Mouneyrac on 11/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticipantListViewController.h"


@interface CoursesViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    ParticipantListViewController *participantListViewController;
    NSManagedObjectContext *managedObjectContext;
    NSManagedObject *site;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) ParticipantListViewController *participantListViewController;
@property (nonatomic, retain) NSManagedObject *site;
@end
