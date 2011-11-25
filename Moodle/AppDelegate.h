//
//  AppDelegate.h
//  Moodle
//
//  Created by Dongsheng Cai on 20/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "Reachability.h"
#import "Site.h"

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    NetworkStatus netStatus;
    Site *site;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
// network status
@property (nonatomic, assign) NetworkStatus netStatus;
@property (nonatomic, retain) NSManagedObject *site;


- (void)saveContext;

+ (AppDelegate *)sharedMoodleApp;

- (void)reachabilityChanged:(NSNotification *)note;

- (NSURL *)applicationDocumentsDirectory;

@end
