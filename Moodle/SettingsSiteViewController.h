//
//  SettingsSite.h
//  Moodle
//
//  Created by Jerome Mouneyrac on 21/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "Site.h"

#define kNumberOfEditableRows 3
#define kUrlIndex             0
#define kUsernameIndex        1
#define kPasswordIndex        2

#define kLabelTag             4096


@interface SettingsSiteViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, MBProgressHUDDelegate> {
    AppDelegate *appDelegate;
    NSManagedObject *editingSite;
    BOOL newEntry;
    NSString *hostURL;

    MBProgressHUD *HUD;

    UITextField *editingField;

    UITableViewCell *siteurlCell;
    UITextField *siteurlField;

    UITableViewCell *usernameCell;
    UITextField *usernameField;

    UITableViewCell *passwordCell;
    UITextField *passwordField;

    UILabel *topLabel;
}

- (IBAction)cancel:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (id)initWithNew:(NSString *)new;
- (void)setEditingSite:(Site *)site;
@end
