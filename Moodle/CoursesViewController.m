//
//  ParticipantsViewController.m
//  Moodle
//
//  Created by jerome Mouneyrac on 11/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "CoursesViewController.h"
#import "Constants.h"
#import "WSClient.h"
#import "ParticipantListViewController.h"
#import "ContentsViewController.h"
#import "Course.h"

@implementation CoursesViewController
@synthesize fetchedResultsController = __fetchedResultsController;

#pragma mark - private methods
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *oneCourse = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [oneCourse valueForKey:@"fullname"];
    cell.detailTextLabel.text = [oneCourse valueForKey:@"shortname"];
}

#pragma mark - Update courses

- (void)updateCourses
{
    _reloading = YES;

    WSClient *client = [[[WSClient alloc] init] autorelease];
    NSNumber *userid = [appDelegate.site valueForKeyPath:@"mainuser.userid"];
    NSArray *wsparams = [[NSArray alloc] initWithObjects:userid, nil];
    NSArray *result;
    @try {
        result = [client invoke:@"moodle_enrol_get_users_courses" withParams:wsparams];

        NSError *error;

        // retrieve all courses that will need to be deleted from core data if they are not returned by the web service call
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:managedObjectContext];
        [request setEntity:entityDescription];
        NSPredicate *coursePredicate = [NSPredicate predicateWithFormat:@"(site = %@)", appDelegate.site];
        [request setPredicate:coursePredicate];
        NSArray *allCourses = [managedObjectContext executeFetchRequest:request error:&error];

        NSLog(@"Number of course in core data before web service call: %d", [allCourses count]);

        NSMutableDictionary *retainedCourses = [[NSMutableDictionary alloc] init];

        // update core data courses with course from web service call
        if ([result isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *wscourse in result)
            {
                NSManagedObject *course;

                // check if the course id is already in core data
                NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                          @"(id = %@ AND site = %@)", [wscourse objectForKey:@"id"], appDelegate.site];
                [request setPredicate:predicate];
                NSArray *existingCourses = [managedObjectContext executeFetchRequest:request error:&error];

                if ([existingCourses count] == 1)
                {
                    NSLog(@"Found existing course: %@", [existingCourses valueForKey:@"fullname"]);
                    course = [existingCourses lastObject];
                }
                else if ([existingCourses count] == 0)
                {
                    course = [NSEntityDescription insertNewObjectForEntityForName:[entityDescription name] inManagedObjectContext:managedObjectContext];
                }
                else
                {
                    NSLog(@"Error !!!!!! There is more than one course with id == %@", [wscourse objectForKey:@"id"]);
                }

                // set the course values
                [course setValue:appDelegate.site forKey:@"site"];
                [course setValue:[wscourse objectForKey:@"id"] forKey:@"id"];
                [course setValue:[wscourse objectForKey:@"fullname"]  forKey:@"fullname"];
                [course setValue:[wscourse objectForKey:@"shortname"] forKey:@"shortname"];
                NSLog(@"Nubmer of participants: %@", [wscourse objectForKey:@"enrolledusercount"]);
                if ([wscourse objectForKey:@"enrolledusercount"])
                {
                    [course setValue:[wscourse objectForKey:@"enrolledusercount"] forKey:@"enrolledusercount"];
                }

                NSNumber *courseexist = [[NSNumber alloc] initWithBool:YES];
                [retainedCourses setObject:courseexist forKey:[wscourse objectForKey:@"id"]];
                [courseexist release];
            }
        }

        for (NSManagedObject *c in allCourses)
        {
            NSNumber *thecourseexist = [retainedCourses objectForKey:[c valueForKey:@"id"]];
            if ([thecourseexist intValue] == 0)
            {
                NSLog(@"Deleting the course %@", c);
                [managedObjectContext deleteObject:c];
            }
        }

        // save the modifications
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:nil])
        {
            // NSLog(@"Error saving entity: %@", [error localizedDescription]);
        }

        [retainedCourses release];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }

}

#pragma mark - View lifecycle

- (void)loadView
{
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    [super loadView];
}

- (id)initWithType:(NSString *)type
{
    if ((self = [self init]))
    {
        viewControllerType = type;
        // cliam ownership
        [viewControllerType retain];
    }

    return self;
}

- (void)dealloc
{
    [__fetchedResultsController release];
    [viewControllerType release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    viewControllerType = nil;
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([Course countWithContext:managedObjectContext site:appDelegate.site] == 0)
    {
        if (appDelegate.netStatus == NotReachable)
        {
            NSLog(@"Network not reachable");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"networkerror", @"Network not reachable") message:NSLocalizedString(@"networkerrormsg", @"Network not reachable") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else
        {
            // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
            HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
            [self.view.window addSubview:HUD];
            HUD.delegate = self;
            HUD.labelText = NSLocalizedString(@"loading", @"Loading");
            [HUD showWhileExecuting:@selector(updateCourses) onTarget:self withObject:nil animated:YES];
        }
    }
}

- (void)viewDidLoad
{
    if (_refreshHeaderView == nil)
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
        [view release];
    }

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = appDelegate.managedObjectContext;

    self.title = NSLocalizedString(@"mycourses", @"My courses title");

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CourseCellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    NSManagedObject *oneCourse = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    cell.imageView.image = [UIImage imageNamed: @"course.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [oneCourse valueForKey:@"fullname"];
    cell.detailTextLabel.text = [oneCourse valueForKey:@"shortname"];

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *selectedCourse = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if ([viewControllerType isEqualToString:@"participants"])
    {
        ParticipantListViewController *participantListViewController = [[ParticipantListViewController alloc] initWithStyle:UITableViewStylePlain];
        participantListViewController.course = selectedCourse;
        participantListViewController.title  = [selectedCourse valueForKey:@"shortname"];
        [self.navigationController pushViewController:participantListViewController animated:YES];
        [participantListViewController release];
    }
    else if ([viewControllerType isEqualToString:@"contents"])
    {
        ContentsViewController *contentsViewController;
        contentsViewController = [[ContentsViewController alloc] init];
        contentsViewController.course = selectedCourse;
        [self.navigationController pushViewController:contentsViewController animated:YES];
        [contentsViewController release];
    }
}

#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil)
    {
        return __fetchedResultsController;
    }

    /*
     * Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    // Set the predicate for only current site
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(site = %@)", appDelegate.site];
    [fetchRequest setPredicate:predicate];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullname" ascending:NO];
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

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
        /*
         * Replace this implementation with code to handle the error appropriately.
         *
         * abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
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
   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)changeType
{
    switch (changeType)
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
   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)changeType
   newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;

    switch (changeType)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods


- (void)doneLoadingTableViewData
{
    [self updateCourses];
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.5];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
#pragma mark -
#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden
{
    _reloading = NO;
    // reset loading flag
    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}

@end
