//
//  SyncViewController.m
//  Moodle
//
//  Created by Dongsheng Cai on 23/05/11.
//  Copyright 2011 Moodle. All rights reserved.
//

#import "SyncViewController.h"
#import "Constants.h"
#import "AppDelegate.h"


@implementation SyncViewController
@synthesize fetchedResultsController=_fetchedResultsController;

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName: @"Job" inManagedObjectContext:context];
    [request setEntity:entity];
    [request setFetchBatchSize: 10];
    //Set the predicate for only current site
//    NSLog(@"Searching unsynced items of %@", appDelegate.site);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(site = %@)", appDelegate.site];
    [request setPredicate: predicate];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] 
                              initWithKey:@"created" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc] initWithFetchRequest: request managedObjectContext:context sectionNameKeyPath: nil cacheName: nil];
    self.fetchedResultsController = controller;
    _fetchedResultsController.delegate = self;
    [request release];
    [controller release];
    return _fetchedResultsController;
}


#pragma mark - delloc

- (void)dealloc
{
    [self.fetchedResultsController release];
    [super dealloc];
}


#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSError *error;
    if (![[self fetchedResultsController] performFetch: &error]) {
        NSLog(@"unresolved error %@, %@", error, [error userInfo]);
    }
    //
    // Create a header view. Wrap it in a container to allow us to position
    // it better.
    //
    UIView *containerView =
    [[[UIView alloc]
      initWithFrame:CGRectMake(0, 0, 300, 60)]
     autorelease];
    UILabel *headerLabel =
    [[[UILabel alloc]
      initWithFrame:CGRectMake(10, 20, 300, 40)]
     autorelease];
    headerLabel.text = NSLocalizedString(@"Sync", @"");
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [UIColor blackColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.font = [UIFont boldSystemFontOfSize:22];
    headerLabel.backgroundColor = [UIColor clearColor];
    [containerView addSubview:headerLabel];
    self.tableView.tableHeaderView = containerView;
//    self.navigationBarTintColor = UIColorFromRGB(ColorNavigationBar);
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                              initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered
                                              target:self action:@selector(dismiss)] autorelease];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                              initWithTitle:@"Send all" style:UIBarButtonItemStyleBordered
                                              target:self action:@selector(sync)] autorelease];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.fetchedResultsController = nil;
}

#pragma mark -
#pragma mark Table view data source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)fillCell: (UITableViewCell *)cell atIndexPath: (NSIndexPath *)indexPath {
    NSManagedObject *job = [_fetchedResultsController objectAtIndexPath: indexPath];
    cell.backgroundColor = [UIColor redColor];
    cell.textLabel.text = [job valueForKey:@"desc"];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%@:%@", [job valueForKey:@"target"], [job valueForKey: @"action"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: CellID] autorelease];
    }
    [self fillCell: cell atIndexPath: indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *job = [_fetchedResultsController objectAtIndexPath: indexPath];
    NSLog(@"selected: %@", [job valueForKey:@"site"]);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return YES;
}
-(void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete data
        [self.tableView beginUpdates];
        NSManagedObject *job = [_fetchedResultsController objectAtIndexPath: indexPath];
        [context deleteObject: job];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Error saving entity: %@", [error localizedDescription]);
        }
        [self.tableView endUpdates];
    }
    [self.tableView reloadData];
}
#pragma mark - fetchedresult controller delegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            NSLog(@"deletion detected");
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self fillCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


#pragma mark - actions
- (void)dismiss {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)sync {
    NSInteger numOfSections = [self.tableView numberOfSections];
    for (int j=0; j<numOfSections; j++) {
        NSInteger numOfRows = [self.tableView numberOfRowsInSection: j];
        for (int i=0; i<numOfRows; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow: i inSection:j];
            NSManagedObject *job = [_fetchedResultsController objectAtIndexPath: indexPath];
            id target = NSClassFromString([job valueForKey:@"target"]);
            SEL method = NSSelectorFromString([NSString stringWithFormat:@"%@:format:", [job valueForKey:@"action"]]);
            @try {
                [target performSelector: method withObject: [job valueForKey:@"data"] withObject:[job valueForKey:@"dataformat"]];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            NSLog(@"Deleting job");
            [context deleteObject:job];
        }
    }
    [context save:nil];
}

@end
