//
//  RootViewController.h
//  Moodle
//
//  Created by jerome Mouneyrac on 17/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

#import "SettingsViewController.h"

@interface DashboardViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    SettingsViewController *settingsViewController;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
