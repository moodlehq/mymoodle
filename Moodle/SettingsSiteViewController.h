//
//  SettingsSite.h
//  Moodle
//
//  Created by jerome Mouneyrac on 21/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNumberOfEditableRows 3
#define kUrlIndex 0
#define kUsernameIndex 1
#define kPasswordIndex 2

#define kLabelTag 4096


@interface SettingsSiteViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate>{
    NSArray *fieldLabels;
    NSMutableDictionary *tempValues;
    UITextField *textFieldBeingEdited;
    NSManagedObject *site;
}
@property (nonatomic, retain) NSArray *fieldLabels;
@property (nonatomic, retain) NSMutableDictionary *tempValues;
@property (nonatomic, retain) UITextField *textFieldBeingEdited;
@property (nonatomic, retain) NSManagedObject *site;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)textFieldDone:(id)sender;
- (void)deleteSite;

@end
