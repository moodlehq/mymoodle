//
//  RootViewController.h
//  Moodle
//
//  Created by jerome Mouneyrac on 17/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

#import "SettingsViewController.h"
#import "ParticipantsViewController.h"

@interface RootViewController : UIViewController {
    SettingsViewController *settingsViewController;
    ParticipantsViewController *participantsViewController;
    //UIButton *participantsButton;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, retain) IBOutlet UIButton *participantsButton;

-(IBAction)displayParticipantsView:(id)sender;
-(void)btnPressed:(id)sender;
@end
