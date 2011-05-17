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
#import "UploadViewController.h"
#import "ParticipantsViewController.h"

@interface RootViewController : UIViewController {
    /** view controllers*/
    SettingsViewController     *settingsViewController;
    UploadViewController       *uploadViewController;
    ParticipantsViewController *participantsViewController;
    /** modules */
    NSArray *modules;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end
