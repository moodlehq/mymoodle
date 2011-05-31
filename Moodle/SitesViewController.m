//
//  Settings.m
//  Moodle
//
//  Created by Jerome Mouneyrac on 21/03/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "SitesViewController.h"
#import "Constants.h"
#import "MoodleSite.h"

#define kSiteNameTag 1;

@implementation SitesViewController
@synthesize lastIndexPath;
@synthesize fetchedResultsController=__fetchedResultsController;

#pragma mark - Button actions
- (void)addSite {
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath: @"tt://settings/yes"] applyAnimated:YES]];
}

#pragma mark - View lifecycle
- (void)dealloc {
    //[self.lastIndexPath release];
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"selectsite", "Select a site");
    MLog(@"SiteViewController did load");
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = [appDelegate managedObjectContext];

    // Set up the edit and add buttons.
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSite)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)viewWillAppear:(BOOL)animated {
//    settingsSiteViewController = [[SettingsSiteViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    settingsSiteViewController.fetchedResultsController = self.fetchedResultsController;
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    //if there is no site available go to the add a site view
    if ([MoodleSite countWithContext: managedObjectContext] == 0) {
        MLog(@"None site found");
        [self addSite];
    }
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    static NSString * SettingsCellIdentifier = @"SettingsCellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingsCellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingsCellIdentifier] autorelease];
    }

    // Cache current site
    appDelegate.site = [self.fetchedResultsController objectAtIndexPath:indexPath];

    NSUInteger row = [indexPath row];
    NSUInteger oldRow = [lastIndexPath row]; //for the checkmark image

    NSString *defaultSiteUrl = [defaults objectForKey: kSelectedSiteUrlKey];
    NSNumber *defaultUserId  = [defaults objectForKey: kSelectedUserIdKey];
    NSLog(@"CellForRow - the default site url is: %@", defaultSiteUrl);
    UIImage *image = [UIImage imageWithData: [appDelegate.site valueForKey:@"logo"]];
    cell.imageView.image = image;

    CGRect siteNameRect = CGRectMake(100, 5, 200, 18);
    UILabel *siteName = [[UILabel alloc] initWithFrame:siteNameRect];
    siteName.tag = kSiteNameTag;
    siteName.text = [appDelegate.site valueForKey:@"name"];
    siteName.font = [UIFont boldSystemFontOfSize:15];
    [cell.contentView addSubview:siteName];
    [siteName release];

    CGRect userNameRect = CGRectMake(100, 26, 200, 12);
    UILabel *userName = [[UILabel alloc] initWithFrame:userNameRect];
    NSString *fullname = [NSString stringWithFormat:@"%@ %@", [appDelegate.site valueForKeyPath:@"mainuser.firstname"], [appDelegate.site valueForKeyPath:@"mainuser.lastname"]];
    userName.text = fullname;
    userName.font = [UIFont italicSystemFontOfSize:12];
    [cell.contentView addSubview:userName];
    [userName release];

    if ((row == oldRow && lastIndexPath != nil)
        || ([[appDelegate.site valueForKey:@"url"] isEqualToString:defaultSiteUrl] && [[appDelegate.site valueForKeyPath:@"mainuser.userid"] isEqualToNumber:defaultUserId])) {

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
    appDelegate.site = [self.fetchedResultsController objectAtIndexPath:indexPath];
    MLog(@"To settings view");
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath: @"tt://settings/no"] applyAnimated:YES]];
//    settingsSiteViewController.title = [settingsSiteViewController.site valueForKey:@"name"];
//    [self.navigationController pushViewController:settingsSiteViewController animated:YES];
//    [settingsSiteViewController release];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    appDelegate.site = [self.fetchedResultsController objectAtIndexPath:indexPath];

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
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //save the current site into user preference
        [defaults setObject:[appDelegate.site valueForKey:@"url"] forKey:kSelectedSiteUrlKey];
        [defaults setObject:[appDelegate.site valueForKey:@"name"] forKey:kSelectedSiteNameKey];
        [defaults setObject:[appDelegate.site valueForKey:@"token"] forKey:kSelectedSiteTokenKey];
        [defaults setObject:[appDelegate.site valueForKeyPath:@"mainuser.userid"] forKey:kSelectedUserIdKey];
        [defaults synchronize];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        MLog(@"NSFetchedResultsController reused");
        return __fetchedResultsController;
    }
    MLog(@"Set up NSFetchedResultsController");
    @try {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity: entity];
        // Set the batch size to a suitable number.
        [fetchRequest setFetchBatchSize: 20];
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Site"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;

        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptor release];
        [sortDescriptors release];

    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            MoodleSite *site = [self.fetchedResultsController objectAtIndexPath:newIndexPath];
            //save the current site into user preference
            NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [site valueForKey:@"url"], kSelectedSiteUrlKey,
                                         [site valueForKey:@"name"], kSelectedSiteNameKey,
                                         [site valueForKey:@"token"], kSelectedSiteTokenKey,
                                         [site valueForKeyPath:@"mainuser.userid"], kSelectedUserIdKey,
                                         nil];

            [defaults registerDefaults: appDefaults];
            //TEST FOR USER DEFAULT
            NSLog(@"AFTER INSERT - the default site url is: %@", [defaults objectForKey:kSelectedSiteUrlKey]);
            NSLog(@"AFTER INSERT - the default site token is: %@", [defaults objectForKey:kSelectedSiteTokenKey]);
            NSLog(@"AFTER INSERT - the default site user id is: %@", [defaults objectForKey:kSelectedUserIdKey]);

            //remove the previous checkmark
            if (lastCheckMark != nil) {
                [lastCheckMark removeFromSuperview];
            }

            break;

        case NSFetchedResultsChangeDelete:
            //TODO: unset the default selected if ever the selected site is deleted
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
//            [defaults setObject:[settingsSiteViewController.site valueForKey:@"url"] forKey:kSelectedSiteUrlKey];
//            [defaults setObject:[settingsSiteViewController.site valueForKey:@"name"] forKey:kSelectedSiteNameKey];
//            [defaults setObject:[settingsSiteViewController.site valueForKey:@"token"] forKey:kSelectedSiteTokenKey];
//            [defaults setObject:[settingsSiteViewController.site valueForKeyPath:@"mainuser.userid"] forKey:kSelectedUserIdKey];
//            [defaults synchronize];
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
