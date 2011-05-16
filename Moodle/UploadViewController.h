//
//  UploadViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 17/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreviewViewController.h"
#import "Config.h"

@interface UploadViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    UIImagePickerController *imagePicker;
    PreviewViewController *previewViewController;
    NSData *fileData;
    NSString *fileName;
}
- (IBAction)loadGallery: (id)sender;
- (IBAction)loadCamera: (id)sender;
- (IBAction)loadRecorder: (id)sender;
- (IBAction)loadFileBrowser: (id)sender;
@end
