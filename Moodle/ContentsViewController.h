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
//  ContentsViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 11/08/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "EGORefreshTableHeaderView.h"

@interface ContentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate, EGORefreshTableHeaderDelegate> {
    MBProgressHUD *HUD;
    AppDelegate *appDelegate;
    EGORefreshTableHeaderView *_refreshHeaderView;

    NSMutableDictionary *downloadingContents;

    NSManagedObject *course;

    UITableView *tableView;

    NSOperationQueue *queue;

    NSArray *sections;
    NSArray *sectionDescs;

    BOOL _reloading;
}
@property (nonatomic, retain) NSManagedObject *course;
- (void)downloadResources:(NSIndexPath *)indexPath;
- (void)updateTable;
- (void)updateCourseContents;
@end
