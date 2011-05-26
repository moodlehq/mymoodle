//
//  UploadViewController.h
//  Moodle
//
//  Created by Dongsheng Cai on 17/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Three20/Three20.h>

@interface UploadViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    NSData *fileData;
    NSString *fileName;
}
@end