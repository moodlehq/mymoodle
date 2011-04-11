//
//  Settings.h
//  Moodle
//
//  Created by jerome Mouneyrac on 21/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsSiteViewController.h"
#import "Config.h"


@interface SettingsViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSArray *list;
    SettingsSiteViewController *settingsSiteViewController;
    NSIndexPath *lastIndexPath;
    UIImageView *lastCheckMark;
}

@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) SettingsSiteViewController *settingsSiteViewController;
- (void)addSite;
- (void)switchOfflineMode;
@end
