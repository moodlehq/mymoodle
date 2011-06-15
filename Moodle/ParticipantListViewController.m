//
//  ParticipantListViewController.m
//  Moodle
//
//  Created by jerome Mouneyrac on 14/04/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "ParticipantListViewController.h"
#import "WSClient.h"
#import "Constants.h"
#import "HashValue.h"
#import "Reachability.h"
#import "AppDelegate.h"

@implementation ParticipantListViewController
@synthesize fetchedResultsController=__fetchedResultsController;
@synthesize course;
@synthesize participantViewController;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    participantViewController = [[ParticipantViewController alloc] init];
    participantViewController.managedObjectContext = managedObjectContext;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //retrieve the participants by webservice
    BOOL offlineMode = [defaults boolForKey:kSelectedOfflineModeKey];
    if (!offlineMode) {
        WSClient *client   = [[WSClient alloc] init];
        NSNumber *courseid = [course valueForKey:@"id"];
        NSArray *paramvalues = [[NSArray alloc] initWithObjects: courseid, nil];
        NSArray *paramkeys   = [[NSArray alloc] initWithObjects:@"courseid", nil];
        NSDictionary *params = [[NSDictionary alloc] initWithObjects: paramvalues forKeys:paramkeys];
        NSArray *result;
        @try {
            result = [client invoke: @"moodle_enrol_get_enrolled_users" withParams: (NSArray *)params];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        
        [client release];
        
        //retrieve all course participants that will need to be deleted from core data
        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext:managedObjectContext];
        [request setEntity:entityDescription];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY courses = %@)", course];
        [request setPredicate:predicate];
        NSError *error = nil;
        NSArray *allParticipants = [managedObjectContext executeFetchRequest:request error:&error];
        
        
        NSMutableDictionary *retainedParticipants = [[NSMutableDictionary alloc] init];
        
        NSLog(@"Number of participants in core data before web service call: %d", [allParticipants count]);
        
        if (result != nil) {
            for ( NSDictionary *participant in result) {
                
                NSManagedObject *dbparticipant;
                
                //check if the user id is already in core data participants
                NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                          @"(userid = %@ AND (ANY site = %@))", [participant objectForKey: @"userid"], [course valueForKey:@"site"]];
                [request setPredicate:predicate];
                NSArray *existingParticipants = [managedObjectContext executeFetchRequest:request error:&error];
                if ([existingParticipants count] == 1) {
                    //retrieve the participant to update
                    dbparticipant = [existingParticipants lastObject];
                } else if ([existingParticipants count] ==0) {
                    //the participant is not in core data, we add it
                    dbparticipant = [NSEntityDescription insertNewObjectForEntityForName:[entityDescription name] inManagedObjectContext:managedObjectContext];
                    
                } else {
                    NSLog(@"Error !!!!!! There is more than one participant with id == %@", [participant objectForKey:@"userid"]);
                }
                
                //set the course values
                [dbparticipant setValue:[participant objectForKey: @"userid"]    forKey:@"userid"];
                [dbparticipant setValue:[participant objectForKey: @"firstname"] forKey:@"firstname"];
                [dbparticipant setValue:[participant objectForKey: @"lastname"]  forKey:@"lastname"];
                [dbparticipant setValue:[participant objectForKey: @"fullname"]  forKey:@"fullname"];
                [dbparticipant setValue:[participant objectForKey: @"username"]  forKey:@"username"];
                [dbparticipant setValue:[participant objectForKey: @"profileimgurl"] forKey:@"profileimgurl"];
                [dbparticipant setValue:[participant objectForKey: @"profileimgurlsmall"] forKey:@"profileimgurlsmall"];
                [dbparticipant setValue:[course valueForKey:@"site"] forKey:@"site"];

                NSMutableSet *participantcourses;
                if ([existingParticipants count] == 1) {
                    // existing user
                    participantcourses = [[NSMutableSet alloc] initWithObjects: course, nil];
                } else {
                    participantcourses = [[NSMutableSet alloc] init];
                }
                [participantcourses addObject: course];
                [dbparticipant setValue: participantcourses forKey: @"courses"];
                [participantcourses release];
                
                //save the modification
                if (![[dbparticipant managedObjectContext] save:&error]) {
                    NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
                    NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
                    if(detailedErrors != nil && [detailedErrors count] > 0) {
                        for(NSError* detailedError in detailedErrors) {
                            NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                        }
                    }
                    else {
                        NSLog(@"  %@", [error userInfo]);
                    }
                }
                
                NSNumber *participantexist = [[NSNumber alloc] initWithBool:YES];
                [retainedParticipants setObject:participantexist forKey: [participant objectForKey:@"userid"]];
                [participantexist release];
            }
        }
        
        for (NSManagedObject *participantToDelete in allParticipants) {
            //if the participant is in the list to not delete
            NSNumber *theparticipantexist = [retainedParticipants objectForKey:[participantToDelete valueForKey:@"userid"]];
            if ([theparticipantexist intValue] == 0) {
                NSLog(@"Deleting participant %@", participantToDelete);
                
                [managedObjectContext deleteObject:participantToDelete];
            }
            //Remove the course from the participant list
            //If courses is empty then delete the participant
        }
        //save the modifications
        if (![managedObjectContext save:&error]) {
            NSLog(@"Error saving entity: %@", [error localizedDescription]);
        }
        [retainedParticipants release];
    }
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

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
    static NSString *CellIdentifier = @"ParticipantCellIdentifier";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    NSManagedObject *oneParticipant = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // Configure the cell...
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    //create file path (Documents/md5(profileimgurl))
    NSString *md5ProfileUrl = [HashValue getMD5FromString:[oneParticipant valueForKey: @"profileimgurl"]];
    NSString *filePath = [NSString stringWithFormat: @"%@/Cache/ProfileImage/%@", DOCUMENTS_FOLDER, md5ProfileUrl];

    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
    NSData *imageData;
    if (fileExists) {
        imageData = [[NSData alloc] initWithContentsOfFile:filePath];
    } else {
        imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[oneParticipant valueForKey:@"profileimgurl"]]];
    }
    [imageData writeToFile:filePath atomically:YES];
    cell.imageView.image = [UIImage imageWithData: imageData];
    [imageData release];
    cell.textLabel.text = [oneParticipant valueForKey:@"fullname"];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *selectedParticipant = [self.fetchedResultsController objectAtIndexPath:indexPath];
    participantViewController.participant = selectedParticipant;
    NSString *participantViewTitle = [NSString stringWithFormat:@"%@ %@", [selectedParticipant valueForKey:@"firstname"], [selectedParticipant valueForKey:@"lastname"]];
    participantViewController.title = participantViewTitle;
    participantViewController.course = course;

    [self.navigationController pushViewController:participantViewController animated:YES];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Participant" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];

    // Only retrieve the participant for the current course
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(ANY courses = %@)", course];
    [fetchRequest setPredicate:predicate];

    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastname" ascending:NO];
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
