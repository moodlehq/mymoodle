//
//  RootViewController.m
//  Moodle
//
//  Created by jerome Mouneyrac on 17/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "RootViewController.h"
#import "Config.h"

@implementation RootViewController

@synthesize managedObjectContext=__managedObjectContext;
//@synthesize participantsButton;

-(IBAction)displayParticipantsView:(id)sender {
    if (participantsViewController == nil) {
        participantsViewController = [[ParticipantsViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    participantsViewController.managedObjectContext = self.managedObjectContext;
    //set the dashboard back button just before to push the settings view
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"dashboard", "dashboard") style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
    [self.navigationController pushViewController:participantsViewController animated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *sitesButton = [[UIBarButtonItem alloc] initWithTitle:@"Sites" style:UIBarButtonItemStylePlain target:self action:@selector(displaySettingsView)];
    self.navigationItem.rightBarButtonItem = sitesButton;
    [sitesButton release];
    NSArray* imageNames = [NSArray arrayWithObjects:
                           @"Contacts.png",
                           @"Text.png",
                           @"Calendar.png",
                           @"Settings.png",
                           @"Photos.png", nil];
    
    UIButton *Btn;
    for (int i=0; i<[imageNames count]; i++) {
        CGRect frame;
        Btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [Btn setImage:[UIImage imageNamed:[imageNames objectAtIndex: i]] forState:UIControlStateNormal];        
        Btn.tag = i;
        
        frame.size.width = 59;
        frame.size.height = 75;
        frame.origin.x = (i%3)*(59+32)+40;
        frame.origin.y = floor(i/3)*(75+24)+40;
        [Btn setFrame:frame];
        
        [Btn setBackgroundColor:[UIColor clearColor]];
        [Btn addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:Btn];
        [Btn release];
        
    }

    self.title = @"Moodle.org";
}

- (void)loadView {
    UIImageView *contentView = [[UIImageView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [contentView setImage:[UIImage imageNamed:@"view_bg.jpg"]];
    [contentView setUserInteractionEnabled:YES];
    self.view = contentView;
    [contentView release];
}



-(void)btnPressed:(id)sender{
    UIButton *Btn = (UIButton *)sender;
    int index = Btn.tag;
    switch (index) {
        case 0:
            [self displayParticipantsView:sender];
            break;
    }
}

-(void)displaySettingsView {
    if (settingsViewController == nil) {
        settingsViewController = [[SettingsViewController alloc] initWithStyle:UITableViewStylePlain];
    }
    settingsViewController.managedObjectContext = self.managedObjectContext;
    //set the dashboard back button just before to push the settings view
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"dashboard", "dashboard") style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    [newBackButton release];
    [self.navigationController pushViewController:settingsViewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteNameKey];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc
{
//    [__fetchedResultsController release];
    [__managedObjectContext release];
    [settingsViewController release];
    [super dealloc];
}

@end
