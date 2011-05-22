//
//  UploadViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 17/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>
#import "PreviewViewController.h"
#import "RecorderViewController.h"
#import "Config.h"

@interface UploadViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    NSData *fileData;
    NSString *fileName;
}
- (IBAction)loadGallery: (id)sender;
- (IBAction)loadCamera: (id)sender;
- (IBAction)loadRecorder: (id)sender;
@end
