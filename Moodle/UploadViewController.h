//
//  UploadViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 17/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UploadViewController : UIViewController 
    <UINavigationControllerDelegate,
    UIImagePickerControllerDelegate> {
    IBOutlet UIImageView *imageView;
    UIImagePickerController *imagePicker;
    
}

@property (nonatomic, retain) UIImageView *imageView;

@end
