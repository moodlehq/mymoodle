//
// This file is part of My Moodle - https://github.com/moodlehq/mymoodle
//
// My Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Moodle.  If not, see <http://www.gnu.org/licenses/>.
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
