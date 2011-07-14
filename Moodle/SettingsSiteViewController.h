//
//  SettingsSite.h
//  Moodle
//
//  Created by Jerome Mouneyrac on 21/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoodleSite.h"
#import "AppDelegate.h"

#define kNumberOfEditableRows 3
#define kUrlIndex 0
#define kUsernameIndex 1
#define kPasswordIndex 2

#define kLabelTag 4096


@interface SettingsSiteViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate> {
    AppDelegate *appDelegate;

    BOOL newEntry;

    UITableViewCell *siteurlCell;
    UITextField     *siteurlField;
   
    UITableViewCell *usernameCell;
    UITextField     *usernameField;
    
    UITableViewCell *passwordCell;
    UITextField     *passwordField;

    UILabel *topLabel;
}
- (IBAction)cancel:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (void)deleteSite;
@end
