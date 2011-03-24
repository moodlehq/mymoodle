//
//  SettingsSite.h
//  Moodle
//
//  Created by jerome Mouneyrac on 21/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNumberOfEditableRows 4
#define kNameRowIndex 0
#define kFromYearRowIndex 1
#define kToYearRowIndex 2
#define kPartyIndex 3

#define kLabelTag 4096


@interface SettingsSiteViewController : UITableViewController <UITextFieldDelegate>{
    NSArray *fieldLabels;
    NSMutableDictionary *tempValues;
    UITextField *textFieldBeingEdited;
}
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;

@end
