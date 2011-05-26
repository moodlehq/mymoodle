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

#import "SitesViewController.h"
#import "UploadViewController.h"
#import "CoursesViewController.h"
#import "Reachability.h"

@interface RootViewController : TTViewController <TTLauncherViewDelegate> {
    /** view controllers*/
    SitesViewController *settingsViewController;
    /** modules */
    NSArray *modules;
    TTLauncherView *launcherView;
    TTLauncherItem *webLauncherItem;
    NSManagedObjectContext *managedObjectContext;
    Reachability *reachability;
}
- (TTLauncherItem *)launcherItemWithTitle:(NSString *)pTitle image:(NSString *)image URL:(NSString *)url;
@end