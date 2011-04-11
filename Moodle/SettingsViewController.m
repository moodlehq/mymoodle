//
//  Settings.m
//  Moodle
//
//  Created by jerome Mouneyrac on 21/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsSiteViewController.h"

#define kSiteNameTag 1;

@implementation SettingsViewController
@synthesize lastIndexPath;
@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize settingsSiteViewController;

- (void)addSite {
    settingsSiteViewController.site = nil; //if user did select a row, we don't try to edit it.
    [self.navigationController pushViewController:settingsSiteViewController animated:YES];
}


#pragma mark - View lifecycle

- (void)dealloc{
    [self.lastIndexPath release];
    [settingsSiteViewController release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    settingsSiteViewController = [[SettingsSiteViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settingsSiteViewController.fetchedResultsController = self.fetchedResultsController;
   // [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)switchOfflineMode {
    BOOL offlineMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSelectedOfflineModeKey];
    offlineMode = !offlineMode;
    [[NSUserDefaults standardUserDefaults] setBool:offlineMode forKey:kSelectedOfflineModeKey];
    [NSUserDefaults resetStandardUserDefaults];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
     
     self.title = NSLocalizedString(@"selectsite", "select a site");
     
     // Set up the edit and add buttons.
     UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSite)];
     self.navigationItem.rightBarButtonItem = addButton;
     [addButton release];
     
     UILabel *offlineSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, 110, 40)];
     offlineSwitchLabel.text = NSLocalizedString(@"offlinemode", "Offline mode");
     
     //create a footer view on the bottom of the tabeview with a Offline mode button
     UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 40)];
     //create the switch
     UISwitch *offlineSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(110, 20, 50, 40)];
     BOOL offlineMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSelectedOfflineModeKey];
     [offlineSwitch setOn:offlineMode];
     // [btnDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [offlineSwitch addTarget:self action:@selector(switchOfflineMode) forControlEvents:UIControlEventTouchUpInside];
     //add the switch to the footer
     [footerView addSubview:offlineSwitch];
     [footerView addSubview:offlineSwitchLabel];
     //add the footer to the tableView
     self.tableView.tableFooterView = footerView; 
     [footerView release];
     [offlineSwitch release];
     [offlineSwitchLabel release];
     [super viewDidLoad];
 }

-(void)viewDidUnload {
    self.lastIndexPath = nil;
    [super viewDidUnload];
}


#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * SettingsCellIdentifier = @"SettingsCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingsCellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingsCellIdentifier] autorelease];
    }
    
    NSManagedObject *oneSite = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSUInteger row = [indexPath row];
    NSUInteger oldRow = [lastIndexPath row]; //for the checkmark image
        
    NSString *defaultSiteUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteUrlKey];
    
    UIImage *image = [UIImage imageNamed:@"profilpicture.jpg"];
    cell.imageView.image = image;
    
    CGRect siteNameRect = CGRectMake(100, 5, 200, 18);
    UILabel *siteName = [[UILabel alloc] initWithFrame:siteNameRect];
    siteName.tag = kSiteNameTag;
    siteName.text = [oneSite valueForKey:@"sitename"];
    siteName.font = [UIFont boldSystemFontOfSize:15];
    [cell.contentView addSubview:siteName];
    [siteName release];
    
    CGRect userNameRect = CGRectMake(100, 26, 200, 12);
    UILabel *userName = [[UILabel alloc] initWithFrame:userNameRect];
    userName.tag = kSiteNameTag;
    userName.text = @"Jerome Mouneyrac";
    userName.font = [UIFont italicSystemFontOfSize:12];
    [cell.contentView addSubview:userName];
    [userName release];
    
    if ((row == oldRow && lastIndexPath != nil) 
        || [[oneSite valueForKey:@"siteurl"] isEqualToString:defaultSiteUrl]) {
        
        UIImage *checkMarkImage = [UIImage imageNamed:@"checkmark.png"];
        CGRect checkMarkRect = CGRectMake(57, 0, 43, 45);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:checkMarkRect];
        [imageView setImage:checkMarkImage];
        [cell.contentView addSubview:imageView];
        lastCheckMark = imageView;
        lastIndexPath = indexPath;
        [imageView release];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    settingsSiteViewController.site = [self.fetchedResultsController objectAtIndexPath:indexPath];  
    settingsSiteViewController.title = [settingsSiteViewController.site valueForKey:@"sitename"];
    
    [self.navigationController pushViewController:settingsSiteViewController animated:YES];
    [settingsSiteViewController release];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    settingsSiteViewController.site = [self.fetchedResultsController objectAtIndexPath:indexPath];  
    
    int newRow = [indexPath row];
    int oldRow = (lastIndexPath != nil) ? [lastIndexPath row] : -1;
    
    if (newRow != oldRow) {
        
        if (lastCheckMark != nil) {
            [lastCheckMark removeFromSuperview];
        }
                       
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        UIImage *checkMarkImage = [UIImage imageNamed:@"checkmark.png"];
        CGRect checkMarkRect = CGRectMake(57, 0, 43, 45);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:checkMarkRect];
        [imageView setImage:checkMarkImage];
        [newCell.contentView addSubview:imageView];
        lastCheckMark = imageView;
        [imageView release];
        
        [self.tableView cellForRowAtIndexPath:lastIndexPath];
        
        lastIndexPath = indexPath;
        
        //save the current site into user preference
        [[NSUserDefaults standardUserDefaults] setObject:[settingsSiteViewController.site valueForKey:@"siteurl"] forKey:kSelectedSiteUrlKey];
        [[NSUserDefaults standardUserDefaults] setObject:[settingsSiteViewController.site valueForKey:@"sitename"] forKey:kSelectedSiteNameKey];
        [NSUserDefaults resetStandardUserDefaults]; //needed to synchronize the user preference
        


    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Connection" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sitename" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error])
        {
	    /*
	     Replace this implementation with code to handle the error appropriately.

	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}   

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type)
    {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];       
             settingsSiteViewController.site = [self.fetchedResultsController objectAtIndexPath:newIndexPath];  
            //save the current site into user preference
            [[NSUserDefaults standardUserDefaults] setObject:[settingsSiteViewController.site valueForKey:@"siteurl"] forKey:kSelectedSiteUrlKey];
            [[NSUserDefaults standardUserDefaults] setObject:[settingsSiteViewController.site valueForKey:@"sitename"] forKey:kSelectedSiteNameKey];
            [NSUserDefaults resetStandardUserDefaults];
            //remove the previous checkmark
            if (lastCheckMark != nil) {
                [lastCheckMark removeFromSuperview];
            }
            
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

@end
