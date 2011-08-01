//
//  RootViewController.h
//  Moodle
//
//  Created by Jerome Mouneyrac on 17/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>
#import <Three20/Three20.h>

#import "SitesViewController.h"
#import "UploadViewController.h"
#import "CoursesViewController.h"
#import "Reachability.h"

@interface RootViewController : TTViewController <TTLauncherViewDelegate, UIActionSheetDelegate> {
    AppDelegate *appDelegate;
    /** view controllers*/
    SitesViewController *settingsViewController;
    /** modules */
    TTLauncherView *launcherView;
    TTLauncherItem *webLauncherItem;
    UITextView *connectedSite;
    UIBarButtonItem *btnSync;
    NSManagedObjectContext *managedObjectContext;
    UITextView *header;
}

- (TTLauncherItem *)launcherItemWithTitle:(NSString *)pTitle image:(NSString *)image URL:(NSString *)url;
@end