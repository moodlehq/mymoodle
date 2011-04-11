//
//  ParticipantsViewController.h
//  Moodle
//
//  Created by jerome Mouneyrac on 11/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ParticipantsViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
}
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end
