//
//  ParticipantListViewController.h
//  Moodle
//
//  Created by jerome Mouneyrac on 14/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ParticipantListViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSManagedObject *course;
    
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObject *course;

@end
