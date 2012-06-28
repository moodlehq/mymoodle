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

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
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
