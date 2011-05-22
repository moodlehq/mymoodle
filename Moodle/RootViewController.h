//
//  RootViewController.h
//  Moodle
//
//  Created by jerome Mouneyrac on 17/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import <Three20/Three20.h>
#import <Three20UI/Three20UI.h>

#import "SettingsViewController.h"
#import "UploadViewController.h"
#import "ParticipantsViewController.h"

@interface RootViewController : TTViewController <TTLauncherViewDelegate> {
    /** view controllers*/
    SettingsViewController     *settingsViewController;
    /** modules */
    NSArray *modules;
    TTLauncherView *launcherView;
}
- (TTLauncherItem *)launcherItemWithTitle:(NSString *)pTitle image:(NSString *)image URL:(NSString *)url;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end
