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
#import "UIImageView+WebCache.h"
#import "SettingsSiteViewController.h"

#define kSiteNameTag 1;

@implementation SitesViewController
@synthesize fetchedResultsController = __fetchedResultsController;

#pragma mark - Button actions
- (void)addSite
{
    [[TTNavigator navigator] openURLAction:[[TTURLAction actionWithURLPath:@"tt://settings/yes"] applyAnimated:YES]];
}

#pragma mark - View lifecycle
- (void)dealloc
{
    [self.fetchedResultsController release];
    [super dealloc];
}

- (void)viewDidUnload
{
    self.fetchedResultsController = nil;
    [super viewDidUnload];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"selectsite", "Select a site");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = [appDelegate managedObjectContext];
    [NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *defaultSiteUrl = [defaults objectForKey:kSelectedSiteUrlKey];
    NSLog(@"SitesViewController %@", defaultSiteUrl);
    if ([MoodleSite countWithContext:managedObjectContext] == 0)
    {
        self.navigationItem.hidesBackButton = YES;

    } else if ([MoodleSite countWithContext:managedObjectContext] == 1) {
        // restore active site info
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:managedObjectContext];
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        [request setEntity:entity];
        NSError *error = nil;
        NSArray *sites = [managedObjectContext executeFetchRequest:request error:&error];
        MoodleSite *onesite = [sites lastObject];
        // save the current site into user preference
        [defaults setObject:[onesite valueForKey:@"url"] forKey:kSelectedSiteUrlKey];
        [defaults setObject:[onesite valueForKey:@"name"] forKey:kSelectedSiteNameKey];
        [defaults setObject:[onesite valueForKey:@"token"] forKey:kSelectedSiteTokenKey];
        [defaults setObject:[onesite valueForKeyPath:@"mainuser.userid"] forKey:kSelectedUserIdKey];
        [defaults synchronize];
        appDelegate.site = onesite;
    }

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
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // if there is no site available go to the add a site view
    if ([MoodleSite countWithContext:managedObjectContext] == 0)
    {
        [self addSite];
    }
}


#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    static NSString *SettingsCellIdentifier = @"SettingsCellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingsCellIdentifier];

    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingsCellIdentifier] autorelease];
    }

    NSManagedObject *account = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [cell.imageView setImageWithURL:[NSURL URLWithString:[account valueForKey:@"userpictureurl"]] placeholderImage:[UIImage imageNamed:@"course.png"]];

    CGRect siteNameRect = CGRectMake(100, 5, 200, 18);
    UILabel *siteName = [[UILabel alloc] initWithFrame:siteNameRect];
    siteName.tag = kSiteNameTag;
    siteName.text = [account valueForKey:@"name"];
    siteName.font = [UIFont boldSystemFontOfSize:15];
    [cell.contentView addSubview:siteName];
    [siteName release];

    CGRect userNameRect = CGRectMake(100, 26, 200, 12);
    UILabel *userName = [[UILabel alloc] initWithFrame:userNameRect];
    NSString *fullname = [account valueForKeyPath:@"mainuser.fullname"];
    userName.text = fullname;
    userName.font = [UIFont italicSystemFontOfSize:12];
    [cell.contentView addSubview:userName];
    [userName release];
    // current site info
    NSString *defaultSiteUrl = [defaults objectForKey:kSelectedSiteUrlKey];
    NSNumber *defaultUserId = [defaults objectForKey:kSelectedUserIdKey];
    if (([[account valueForKey:@"url"] isEqualToString:defaultSiteUrl] && [[account valueForKeyPath:@"mainuser.userid"] isEqualToNumber:defaultUserId]))
    {
        UIImage *checkMarkImage = [UIImage imageNamed:@"checkmark.png"];
        CGRect checkMarkRect = CGRectMake(57, 0, 43, 45);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:checkMarkRect];
        [imageView setImage:checkMarkImage];
        [cell.contentView addSubview:imageView];
        lastCheckMark = imageView;
        [imageView release];
    }

    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;

    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    SettingsSiteViewController *settingsSiteController = [[SettingsSiteViewController alloc] initWithNew:@"no"];

    settingsSiteController.editingSite = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.navigationController pushViewController:settingsSiteController animated:YES];
    [settingsSiteController release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MoodleSite *account = [self.fetchedResultsController objectAtIndexPath:indexPath];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *defaultSiteUrl = [defaults objectForKey:kSelectedSiteUrlKey];
    NSNumber *defaultUserId = [defaults objectForKey:kSelectedUserIdKey];

    if (([[account valueForKey:@"url"] isEqualToString:defaultSiteUrl] && [[account valueForKeyPath:@"mainuser.userid"] isEqualToNumber:defaultUserId]))
    {
        if (lastCheckMark != nil)
        {
            [lastCheckMark removeFromSuperview];
        }

        UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
        UIImage *checkMarkImage = [UIImage imageNamed:@"checkmark.png"];
        CGRect checkMarkRect = CGRectMake(57, 0, 43, 45);
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:checkMarkRect];
        [imageView setImage:checkMarkImage];
        [newCell.contentView addSubview:imageView];
        lastCheckMark = imageView;
        [imageView release];
    }


    // save the current site into user preference
    [defaults setObject:[account valueForKey:@"url"] forKey:kSelectedSiteUrlKey];
    [defaults setObject:[account valueForKey:@"name"] forKey:kSelectedSiteNameKey];
    [defaults setObject:[account valueForKey:@"token"] forKey:kSelectedSiteTokenKey];
    [defaults setObject:[account valueForKeyPath:@"mainuser.userid"] forKey:kSelectedUserIdKey];
    NSLog(@"saving userdefaults");
    [defaults synchronize];
    appDelegate.site = account;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }
    MLog(@"Set up NSFetchedResultsController");
    @try {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        // Set the batch size to a suitable number.
        [fetchRequest setFetchBatchSize:20];
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];

        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
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
    NSLog(@"Begin update SiteViewController");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type)
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

    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            // new added site
            MoodleSite *site = [self.fetchedResultsController objectAtIndexPath:newIndexPath];
            NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [site valueForKey:@"url"], kSelectedSiteUrlKey,
                                         [site valueForKey:@"name"], kSelectedSiteNameKey,
                                         [site valueForKey:@"token"], kSelectedSiteTokenKey,
                                         [site valueForKeyPath:@"mainuser.userid"], kSelectedUserIdKey,
                                         nil];

            [defaults registerDefaults:appDefaults];

            // remove the previous checkmark
            if (lastCheckMark != nil)
            {
                [lastCheckMark removeFromSuperview];
            }

            break;

        case NSFetchedResultsChangeDelete:
            // TODO: unset the default selected if ever the selected site is deleted
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
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
 * // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 *
 * - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 * {
 * // In the simplest, most efficient, case, reload the table view.
 * [self.tableView reloadData];
 * }
 */

@end
