//
//  AppDelegate.h
//  Moodle
//
//  Created by Dongsheng Cai on 20/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "MoodleSite.h"
#import "Reachability.h"

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    MoodleSite *site;
    NetworkStatus netStatus;
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) MoodleSite *site;
@property (nonatomic, assign) NetworkStatus netStatus;

- (void)saveContext;

+ (AppDelegate *)sharedMoodleApp;

- (void) reachabilityChanged: (NSNotification* )note;

- (NSURL *)applicationDocumentsDirectory;

@end
