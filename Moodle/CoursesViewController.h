//
//  ParticipantsViewController.h
//  Moodle
//
//  Created by Jerome Mouneyrac on 11/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Three20/Three20.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "EGORefreshTableHeaderView.h"
#import "MBProgressHUD.h"

@interface CoursesViewController : UITableViewController <UITableViewDataSource, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, UIScrollViewDelegate, EGORefreshTableHeaderDelegate, MBProgressHUDDelegate> {
    NSManagedObjectContext *managedObjectContext;
    AppDelegate *appDelegate;

    EGORefreshTableHeaderView *_refreshHeaderView;
    MBProgressHUD *HUD;

    NSString *viewControllerType;

    BOOL _reloading;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (id)initWithType:(NSString *)type;
@end
