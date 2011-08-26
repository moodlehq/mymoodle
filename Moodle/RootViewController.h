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


#define HEADER_HEIGHT 65
#define BG_WIDTH      276
#define BG_HEIGHT     280

@interface RootViewController : TTViewController <TTLauncherViewDelegate, UIActionSheetDelegate> {
    AppDelegate *appDelegate;
    /** modules */
    TTLauncherView *launcherView;
    UITextView *connectedSite;
    UIBarButtonItem *btnSync;
    UIImageView *rootBackground;
    NSManagedObjectContext *managedObjectContext;
    UITextView *header;
    
    /** available web service names */
    NSMutableArray *features;
}
@end
