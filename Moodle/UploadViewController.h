//
//  UploadViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 17/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "MBProgressHUD.h"
#import "MoodleMedia.h"
#import "AppDelegate.h"

@interface UploadViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate, MoodleUploadDelegate> {
    AppDelegate *appDelegate;
    NSString *fileName;
    NSString *filePath;
    MBProgressHUD *HUD;
}
- (void)uploadAction;
@end