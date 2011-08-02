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
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"
#import <Three20/Three20.h>

@interface CoursesViewController : UITableViewController <UITableViewDataSource, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, EGORefreshTableHeaderDelegate, MBProgressHUDDelegate> {
    NSManagedObjectContext *managedObjectContext;
    AppDelegate *appDelegate;

    EGORefreshTableHeaderView *_refreshHeaderView;
    MBProgressHUD *HUD;

    ParticipantListViewController *participantListViewController;

    //  Reloading var should really be your tableviews datasource
    //  Putting it here for demo purposes
    BOOL _reloading;
}
-(void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) ParticipantListViewController *participantListViewController;
@end
