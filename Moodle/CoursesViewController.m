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

@implementation CoursesViewController
@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize participantListViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [__fetchedResultsController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)updateCourses {
    
	_reloading = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    WSClient *client = [[[WSClient alloc] init] autorelease];
    NSNumber *userid  = [defaults objectForKey:kSelectedUserIdKey];
    NSLog(@"User ID: %@", userid);
    NSArray *wsparams = [[NSArray alloc] initWithObjects: userid, nil];
    NSArray *result;
    @try {
        result = [client invoke: @"moodle_enrol_get_users_courses" withParams: wsparams];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[exception name] message:[exception reason] delegate: nil cancelButtonTitle:@"Continue" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
    
    NSError *error;
    
    //retrieve all courses that will need to be deleted from core data if they are not returned by the web service call
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:managedObjectContext];
    [request setEntity:entityDescription];
    NSPredicate *coursePredicate = [NSPredicate predicateWithFormat:@"(site = %@)", appDelegate.site];
    [request setPredicate:coursePredicate];
    NSArray *allCourses = [managedObjectContext executeFetchRequest: request error:&error];
    
    NSLog(@"Number of course in core data before web service call: %d", [allCourses count]);
    
    NSMutableDictionary *retainedCourses = [[NSMutableDictionary alloc] init];
    
    //update core data courses with course from web service call
    if ([result isKindOfClass: [NSArray class]]) {
        for (NSDictionary *wscourse in result) {
            NSManagedObject *course;
            
            //check if the course id is already in core data
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"(id = %@ AND site = %@)", [wscourse objectForKey:@"id"], appDelegate.site];
            [request setPredicate:predicate];
            NSArray *existingCourses = [managedObjectContext executeFetchRequest:request error:&error];
            NSLog(@"Found %d course", [existingCourses count]);
            
            if ([existingCourses count] == 1) {
                NSLog(@"Update a existing course %@", [wscourse objectForKey:@"shortname"]);
                course = [existingCourses lastObject];
                
            } else if ([existingCourses count] == 0) {
                NSLog(@"Add a new course %@", [wscourse objectForKey:@"shortname"]);
                course = [NSEntityDescription insertNewObjectForEntityForName:[entityDescription name] inManagedObjectContext:managedObjectContext];
            } else {
                NSLog(@"Error !!!!!! There is more than one course with id == %@", [wscourse objectForKey:@"id"]);
            }
            
            //set the course values
            [course setValue: appDelegate.site forKey:@"site"];
            [course setValue: [wscourse objectForKey:@"id"] forKey:@"id"];
            [course setValue: [wscourse objectForKey:@"fullname"]  forKey:@"fullname"];
            [course setValue: [wscourse objectForKey:@"shortname"] forKey:@"shortname"];
            
            NSNumber *courseexist = [[NSNumber alloc] initWithBool:YES];
            NSLog(@"Course exist BOOL %@", courseexist);
            [retainedCourses setObject: courseexist forKey: [wscourse objectForKey:@"id"]];
            [courseexist release];
        }
    }
    for (NSManagedObject *c in allCourses) {
        NSNumber *thecourseexist = [retainedCourses objectForKey:[c valueForKey:@"id"]];
        if ([thecourseexist intValue] == 0) {
            NSLog(@"Deleting the course %@", c);
            [managedObjectContext deleteObject: c];
        }
    }
    //save the modifications
    if ([managedObjectContext hasChanges] && ![managedObjectContext save: nil]) {
        //NSLog(@"Error saving entity: %@", [error localizedDescription]);
    }
    [retainedCourses release];
    allCourses = [managedObjectContext executeFetchRequest: request error:&error];
    
    NSLog(@"Number of course in core data after web service call: %d", [allCourses count]);
}

- (void)viewDidAppear:(BOOL)animated {

    [super viewDidAppear: animated];
}
- (void)viewDidLoad
{
    managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    participantListViewController = [[ParticipantListViewController alloc] initWithStyle:UITableViewStylePlain];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    NSManagedObject *oneCourse = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed: @"course.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [oneCourse valueForKey:@"fullname"];
    cell.detailTextLabel.text = [oneCourse valueForKey:@"shortname"];

//    CGRect siteNameRect = CGRectMake(15, 5, 290, 30);
//    UILabel *siteName = [[UILabel alloc] initWithFrame:siteNameRect];
//    siteName.text = [oneCourse valueForKey:@"fullname"];
//    siteName.font = [UIFont boldSystemFontOfSize:15];
//    [cell.contentView addSubview:siteName];
//    [siteName release];

//    CGRect userNameRect = CGRectMake(15, 26, 200, 12);
//    UILabel *userName = [[UILabel alloc] initWithFrame:userNameRect];
//    userName.text = @"Some course information ???";
//    userName.font = [UIFont italicSystemFontOfSize:12];
//    [cell.contentView addSubview:userName];
//    [userName release];

    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *selectedCourse = [self.fetchedResultsController objectAtIndexPath:indexPath];
    participantListViewController.course = selectedCourse;
    NSString *participantListViewTitle = NSLocalizedString(@"participants", @"Participants");
    participantListViewController.title = participantListViewTitle;
    [self.navigationController pushViewController: participantListViewController animated:YES];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    //Set the predicate for only current site
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(site = %@)", appDelegate.site];
    [fetchRequest setPredicate:predicate];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"fullname" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName: nil];
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


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods


- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{

    NSLog(@"loading ");
	[self updateCourses];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}
@end
