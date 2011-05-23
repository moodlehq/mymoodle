//
//  ParticipantsViewController.m
//  Moodle
//
//  Created by jerome Mouneyrac on 11/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "ParticipantsViewController.h"
#import "Config.h"
#import "WSClient.h"
#import "ParticipantListViewController.h"
#import "AppDelegate.h"

@implementation ParticipantsViewController
@synthesize managedObjectContext;
@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize participantListViewController;
@synthesize site;

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
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    participantListViewController = [[ParticipantListViewController alloc] initWithStyle:UITableViewStyleGrouped];
    participantListViewController.managedObjectContext = self.managedObjectContext;
    
    //look for the site
    NSEntityDescription *siteEntityDescription = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *siteRequest = [[[NSFetchRequest alloc] init] autorelease];
    [siteRequest setEntity:siteEntityDescription];
    NSPredicate *sitePredicate = [NSPredicate predicateWithFormat:@"(url = %@ AND token = %@)", [[NSUserDefaults standardUserDefaults] stringForKey:kSelectedSiteUrlKey], [[NSUserDefaults standardUserDefaults] stringForKey:kSelectedSiteTokenKey]];
    [siteRequest setPredicate:sitePredicate];
    NSError *error = nil;
    NSArray *sites = [self.managedObjectContext executeFetchRequest:siteRequest error:&error];
    self.site = [sites lastObject];
    
    
    //TEST FOR USER DEFAULT
    //    NSString *defaultSiteUrl = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteUrlKey];
    //    NSLog(@"BEFORE GET COURSE WS - the default site url is: %@", defaultSiteUrl);
    //    NSString *defaultSiteToken = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteTokenKey];
    //    NSLog(@"BEFORE GET COURSE WS - the default site token is: %@", defaultSiteToken);
    //    NSString *defaultSiteUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedUserIdKey];
    //    NSLog(@"BEFORE GET COURSE WS - the default site user id is: %@", defaultSiteUserId);
    
    
    self.title = NSLocalizedString(@"mycourses", @"My courses title");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //retrieve the course by webservice
    BOOL offlineMode = [defaults boolForKey:kSelectedOfflineModeKey];
    if (!offlineMode) {
        WSClient *client = [[WSClient alloc] init];
        NSNumber *userid         = [defaults objectForKey:kSelectedUserIdKey];
        NSArray *userparamvalue  = [[NSArray alloc] initWithObjects:userid, nil];
        NSArray *userparamkey    = [[NSArray alloc] initWithObjects:@"userid", nil];
        NSDictionary *userparams = [[NSDictionary alloc] initWithObjects:userparamvalue forKeys:userparamkey];
        NSArray *subarray        = [[NSArray alloc]initWithObjects:userparams, nil];
        NSArray *wsparams        = [[NSArray alloc] initWithObjects:subarray, nil];
        NSArray *result;
        @try {
            result = [client invoke: @"moodle_enrol_get_courses_by_enrolled_users" withParams: wsparams];  
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        
        [client release];
        
        //TEST FOR USER DEFAULT
        //        NSString *defaultSiteUrl2 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteUrlKey];
        //        NSLog(@"AFTER GET COURSE WS - the default site url is: %@", defaultSiteUrl2);
        //        NSString *defaultSiteToken2 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteTokenKey];
        //        NSLog(@"AFTER GET COURSE WS - the default site token is: %@", defaultSiteToken2);
        //        NSString *defaultSiteUserId2 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedUserIdKey];
        //        NSLog(@"AFTER GET COURSE WS - the default site user id is: %@", defaultSiteUserId2);

        NSError *error;

        //retrieve all courses that will need to be deleted from core data if they are not returned by the web service call
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entityDescription];
        NSPredicate *coursePredicate = [NSPredicate predicateWithFormat:@"(site = %@)", self.site];
        [request setPredicate:coursePredicate];
        NSArray *coursesToDelete = [self.managedObjectContext executeFetchRequest:request error:&error];
        NSMutableDictionary *coursesToNotDelete = [[NSMutableDictionary alloc] init];
        NSLog(@"Courses in core data: %@", coursesToDelete);
        NSLog(@"Number of course in core data before web service call: %d", [coursesToDelete count]);
        
        //TEST FOR USER DEFAULT
        //        NSString *defaultSiteUrl21 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteUrlKey];
        //        NSLog(@"AFTER GET COURSE WS - 2 the default site url is: %@", defaultSiteUrl21);
        //        NSString *defaultSiteToken21 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteTokenKey];
        //        NSLog(@"AFTER GET COURSE WS - 2 the default site token is: %@", defaultSiteToken21);
        //        NSString *defaultSiteUserId21 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedUserIdKey];
        //        NSLog(@"AFTER GET COURSE WS - 2 the default site user id is: %@", defaultSiteUserId21);
        
        
        //update core data courses with course from web service call
        if (result != nil) {
            NSLog(@"Result: %@", result);
            for ( NSDictionary *item in result) {
                
                NSArray *mycourses = [item objectForKey:@"courses"];
                for (NSDictionary *wscourse in mycourses ) {
                    
                    NSManagedObject *course;
                    
                    //check if the course id is already in core data
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                              @"(id = %@ AND site = %@)", [wscourse objectForKey:@"id"], self.site];
                    [request setPredicate:predicate];
                    NSArray *existingCourses = [managedObjectContext executeFetchRequest:request error:&error];
                    if ([existingCourses count] == 1) {
                        //retrieve the course to update
                        course = [existingCourses lastObject];
                        
                    } else if ([existingCourses count] ==0) {
                        //the course is not in core data, we add it
                        course = [NSEntityDescription insertNewObjectForEntityForName:[entityDescription name] inManagedObjectContext:managedObjectContext];
                        
                    } else {
                        NSLog(@"Error !!!!!! There is more than one course with id == %@", [wscourse objectForKey:@"id"]);
                    }
                    
                    //set the course values
                    [course setValue:[wscourse objectForKey:@"fullname"] forKey:@"fullname"];
                    [course setValue:[wscourse objectForKey:@"id"] forKey:@"id"];
                    [course setValue:[wscourse objectForKey:@"shortname"] forKey:@"shortname"];
                    [course setValue:self.site forKey:@"site"];
                    
                    //save the modification
                    
                    //                    //TEST FOR USER DEFAULT
                    //                    NSString *defaultSiteUrl214 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteUrlKey];
                    //                    NSLog(@"AFTER GET COURSE WS - 4 the default site url is: %@", defaultSiteUrl214);
                    //                    NSString *defaultSiteToken214 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteTokenKey];
                    //                    NSLog(@"AFTER GET COURSE WS - 4 the default site token is: %@", defaultSiteToken214);
                    //                    NSString *defaultSiteUserId214 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedUserIdKey];
                    //                    NSLog(@"AFTER GET COURSE WS - 4 the default site user id is: %@", defaultSiteUserId214);
                    //                    //TEST FOR USER DEFAULT
                    //                    NSString *defaultSiteUrl2145 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteUrlKey];
                    //                    NSLog(@"AFTER GET COURSE WS - 5 the default site url is: %@", defaultSiteUrl2145);
                    //                    NSString *defaultSiteToken2145 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteTokenKey];
                    //                    NSLog(@"AFTER GET COURSE WS - 5 the default site token is: %@", defaultSiteToken2145);
                    //                    NSString *defaultSiteUserId2145 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedUserIdKey];
                    //                    NSLog(@"AFTER GET COURSE WS - 5 the default site user id is: %@", defaultSiteUserId2145);
                    
                    NSNumber *courseexist = [[NSNumber alloc] initWithBool:YES];
                    [coursesToNotDelete setObject:courseexist forKey:[wscourse objectForKey:@"id"]];
                    [courseexist release];
                    
                }
            }
            
            
        }
        
        
        //delete the obsolete courses from core data
        NSLog(@" the course to no detele are %@", coursesToNotDelete);
        NSLog(@" the course to detele are %@", coursesToDelete);
        for (NSManagedObject *courseToDelete in coursesToDelete) {
            NSNumber *thecourseexist = [coursesToNotDelete objectForKey:[courseToDelete valueForKey:@"id"]];
            if ([thecourseexist intValue] == 0) {
                NSLog(@"I'm deleting the course %@", courseToDelete);
                
                [managedObjectContext deleteObject:courseToDelete];
            }
        }
        
        //        //TEST FOR USER DEFAULT
        //        NSString *defaultSiteUrl22 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteUrlKey];
        //        NSLog(@"AFTER GET COURSE WS - 3 the default site url is: %@", defaultSiteUrl22);
        //        NSString *defaultSiteToken22 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedSiteTokenKey];
        //        NSLog(@"AFTER GET COURSE WS - 3 the default site token is: %@", defaultSiteToken22);
        //        NSString *defaultSiteUserId22 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedUserIdKey];
        //        NSLog(@"AFTER GET COURSE WS - 3 the default site user id is: %@", defaultSiteUserId22);
  
        NSString *defaultSiteUserId22 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedUserIdKey];
        NSLog(@"AFTER GET COURSE WS - 3 the default site user id is: %@", defaultSiteUserId22);
        NSLog(@"%@", defaults);
        
        //save the modifications
        @try {
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"Error saving entity: %@", [error localizedDescription]);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        defaultSiteUserId22 = [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedUserIdKey];
        NSLog(@"AFTER GET COURSE WS - 3 the default site user id is: %@", defaultSiteUserId22);
        NSLog(@"%@", defaults);

        
        [coursesToNotDelete release];
    }

    
    
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSManagedObject *oneCourse = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Configure the cell...
     cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
//    UIImage *image = [UIImage imageNamed:@"profilpicture.jpg"];
//    cell.imageView.image = image;
    
    CGRect siteNameRect = CGRectMake(15, 5, 290, 30);
    UILabel *siteName = [[UILabel alloc] initWithFrame:siteNameRect];
    siteName.text = [oneCourse valueForKey:@"fullname"];
    siteName.font = [UIFont boldSystemFontOfSize:15];
    [cell.contentView addSubview:siteName];
    [siteName release];
    
//    CGRect userNameRect = CGRectMake(15, 26, 200, 12);
//    UILabel *userName = [[UILabel alloc] initWithFrame:userNameRect];
//    userName.text = @"Some course information ???";
//    userName.font = [UIFont italicSystemFontOfSize:12];
//    [cell.contentView addSubview:userName];
//    [userName release];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    NSManagedObject *selectedCourse = [self.fetchedResultsController objectAtIndexPath:indexPath]; 
    participantListViewController.course = selectedCourse;
    NSString *participantListViewTitle = NSLocalizedString(@"participants", @"Participants");
    participantListViewController.title = participantListViewTitle;
    
    [self.navigationController pushViewController:participantListViewController animated:YES];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //Set the predicate for only current site
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(site = %@)", self.site];
    [fetchRequest setPredicate:predicate];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fullname" ascending:NO];
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

@end
