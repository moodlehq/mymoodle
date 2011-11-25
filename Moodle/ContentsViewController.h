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
