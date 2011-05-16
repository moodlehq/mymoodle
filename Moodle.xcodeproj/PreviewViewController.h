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
#import "Config.h"

@interface PreviewViewController : UIViewController <UINavigationControllerDelegate, MBProgressHUDDelegate> {
    UIImageView *imageView;
    NSString *fileName;
    MBProgressHUD *HUD;
    
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) NSString *fileName;
- (IBAction)uploadPressed: (id)sender;
- (IBAction)cancelPressed: (id)sender;
@end
