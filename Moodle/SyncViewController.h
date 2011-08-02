//
//  SyncViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 23/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Three20/Three20.h>
#import "AppDelegate.h"

@interface SyncViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *context;
    AppDelegate *appDelegate;
    UIView *tableviewFooter;
    UISwitch *switchAuto;
}
- (void)updateTableView:(NSManagedObject *)job;
- (void)sync;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
