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
- (void)updateParticipants;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObject *course;
@property (nonatomic, retain) DetailViewController *detailViewController;

@end
