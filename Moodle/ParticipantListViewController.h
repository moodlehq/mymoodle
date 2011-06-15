//
//  ParticipantListViewController.h
//  Moodle
//
//  Created by jerome Mouneyrac on 14/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticipantViewController.h"
#import "EGORefreshTableHeaderView.h"


@interface ParticipantListViewController : UITableViewController <NSFetchedResultsControllerDelegate, EGORefreshTableHeaderDelegate> {
    NSManagedObject *course;
    ParticipantViewController *participantViewController;
    NSManagedObjectContext *managedObjectContext;
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObject *course;
@property (nonatomic, retain) ParticipantViewController *participantViewController;

@end
