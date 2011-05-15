//
//  UploadViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 17/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface UploadViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MBProgressHUDDelegate> {
    UIImagePickerController *imagePicker;
    MBProgressHUD *HUD;
    NSData *fileData;
    NSString *fileName;
}
- (void)uploadFile;
- (IBAction)loadGallery: (id)sender;
- (IBAction)loadCamera: (id)sender;
- (IBAction)loadRecorder: (id)sender;
- (IBAction)loadFileBrowser: (id)sender;
@end
