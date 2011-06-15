//
//  PreviewViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 16/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "MoodleMedia.h"


@interface PreviewViewController : UIViewController <UINavigationControllerDelegate, MBProgressHUDDelegate, UIAlertViewDelegate, MoodleUploadDelegate> {
    UIImageView *imageView;
    NSString *fileName;
    NSString *filePath;
    AppDelegate *_appDelegate;
    // will be released by delegate method
    MBProgressHUD *HUD;
    
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *filePath;
- (IBAction)uploadPressed: (id)sender;
- (IBAction)cancelPressed: (id)sender;
- (void)uploadCallback: (id)data;
@end
