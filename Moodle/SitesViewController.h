//
//  Settings.h
//  Moodle
//
//  Created by Jerome Mouneyrac on 21/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "AppDelegate.h"

@interface SitesViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSArray *list;
    NSManagedObjectContext *managedObjectContext;
    NSFetchedResultsController *__fetchedResultsController;
    AppDelegate *appDelegate;
    UIImageView *lastCheckMark;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end