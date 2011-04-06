//
//  RootViewController.m
//  Moodle
//
//  Created by jerome Mouneyrac on 17/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

@synthesize managedObjectContext=__managedObjectContext;

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *sitesButton = [[UIBarButtonItem alloc] initWithTitle:@"Sites" style:UIBarButtonItemStylePlain target:self action:@selector(displaySettingsView)];
    self.navigationItem.rightBarButtonItem = sitesButton;
    [sitesButton release];
    
    self.title = @"Moodle.org";
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
