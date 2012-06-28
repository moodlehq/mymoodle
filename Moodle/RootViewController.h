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
