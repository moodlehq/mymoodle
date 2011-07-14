//
//  ParticipantListViewController.h
//  Moodle
//
//  Created by Jerome Mouneyrac on 14/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailViewController.h"
#import "EGORefreshTableHeaderView.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"


@interface ParticipantListViewController : UITableViewController <NSFetchedResultsControllerDelegate, EGORefreshTableHeaderDelegate, MBProgressHUDDelegate> {
    AppDelegate *appDelegate;
    NSManagedObjectContext *managedObjectContext;

    NSManagedObject *course;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    MBProgressHUD *HUD;
    
    DetailViewController *participantViewController;
	BOOL _reloading;
}
- (void) updateParticipants;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObject *course;
@property (nonatomic, retain) DetailViewController *detailViewController;

@end
