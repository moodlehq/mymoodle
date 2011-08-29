//
//  ParticipantListViewController.m
//  Moodle
//
//  Created by Jerome Mouneyrac on 14/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "ParticipantListViewController.h"
#import "WSClient.h"
#import "Constants.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "Participant.h"
#import "UIImageView+WebCache.h"

@implementation ParticipantListViewController
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize course;
@synthesize detailViewController;



#pragma mark - web service
- (void)updateParticipants
{
    _reloading = YES;

    // retrieve all course participants that will need to be deleted from core data
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext:managedObjectContext];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY courses == %@", course];
    [request setPredicate:predicate];
    NSError *error = nil;
    NSArray *enrolledUsers = [managedObjectContext executeFetchRequest:request error:&error];

    NSMutableDictionary *retainedParticipants = [[NSMutableDictionary alloc] init];
    NSLog(@"Number of participants in core data before web service call: %d", [enrolledUsers count]);

    WSClient *client = [[WSClient alloc] init];

    NSNumber *courseid = [course valueForKey:@"id"];
    NSArray *options = [[NSArray alloc] init];
    NSArray *paramvalues = [[NSArray alloc] initWithObjects:courseid, options, nil];
    NSArray *paramkeys = [[NSArray alloc] initWithObjects:@"courseid", @"options", nil];
    NSDictionary *params = [[NSDictionary alloc] initWithObjects:paramvalues forKeys:paramkeys];
    NSArray *result;
    @try {
        result = [client invoke:@"moodle_user_get_users_by_courseid" withParams:(NSArray *)params];
        if (result)
        {
            for (NSDictionary *wsparticipant in result)
            {
                Participant *dbparticipant;

                // check if the user id is already in core data participants
                NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                          @"(site == %@ AND userid == %@)", [course valueForKey:@"site"], [wsparticipant objectForKey:@"id"]];
                [request setPredicate:predicate];
                NSArray *user = [managedObjectContext executeFetchRequest:request error:&error];
                if ([user count] == 1)
                {
                    // retrieve the participant to update
                    NSLog(@"found one ");
                    dbparticipant = [user lastObject];
                }
                else if ([user count] == 0)
                {
                    // the participant is not in core data, we add it
                    dbparticipant = [NSEntityDescription insertNewObjectForEntityForName:[entityDescription name] inManagedObjectContext:managedObjectContext];
                }
                else
                {
                    for (NSManagedObject *u in user)
                    {
                        [managedObjectContext deleteObject:u];
                    }
                    NSLog(@"Error !!!!!! There is more than one participant with id == %@", [wsparticipant objectForKey:@"id"]);
                }

                [Participant update:dbparticipant dict:wsparticipant course:course];

                NSNumber *participantexist = [[NSNumber alloc] initWithBool:YES];
                [retainedParticipants setObject:participantexist forKey:[wsparticipant objectForKey:@"id"]];
                [participantexist release];
            }
        }
        for (Participant *participant in enrolledUsers)
        {
            // if the participant is in the list to not delete
            NSNumber *theparticipantexist = [retainedParticipants objectForKey:[participant valueForKey:@"userid"]];
            if ([theparticipantexist intValue] == 0)
            {
                NSLog(@"Unenroll participant %@", participant);
                [participant removeCoursesObject:course];
            }
        }

        // save the modifications
        if (![managedObjectContext save:&error])
        {
            NSLog(@"Error saving entity: %@", [error localizedDescription]);
        }
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate:self cancelButtonTitle:NSLocalizedString(@"continue", @"Continue") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    // easy on memory
    [options release];
    [paramvalues release];
    [paramkeys release];
    [params release];
    [client release];
    [retainedParticipants release];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{
    [__fetchedResultsController release];
    [detailViewController release];
    [self.course release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    managedObjectContext = [appDelegate managedObjectContext];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (_refreshHeaderView == nil)
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
        [view release];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    detailViewController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([Participant countWithContext:managedObjectContext course:course] == 0)
    {
        if (appDelegate.netStatus == NotReachable)
        {
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
            [HUD showWhileExecuting:@selector(updateParticipants) onTarget:self withObject:nil animated:YES];
        }
    }
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

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ParticipantCellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    NSManagedObject *oneParticipant = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell.imageView setImageWithURL:[NSURL URLWithString:[oneParticipant valueForKey:@"profileimageurl"]] placeholderImage:[UIImage imageNamed:@"user.png"]];
    cell.textLabel.text = [oneParticipant valueForKey:@"fullname"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Participant *selectedParticipant = [self.fetchedResultsController objectAtIndexPath:indexPath];

    detailViewController = [[DetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
    detailViewController.participant = selectedParticipant;
    detailViewController.course = course;
    [self.navigationController pushViewController:detailViewController animated:YES];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    // Only retrieve the participant for the current course
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY courses = %@)", course];
    [fetchRequest setPredicate:predicate];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastname" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];

    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error])
    {
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

    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    //  model should call this when its done loading
    [self updateParticipants];
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
    return _reloading;             // should return if data source model is reloading
}

- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];          // should return date data source was last changed
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
    // reset loading flag
    _reloading = NO;

    [HUD removeFromSuperview];
    [HUD release];
    HUD = nil;
}
@end
