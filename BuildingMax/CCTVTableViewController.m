//
//  CCTVTableViewController.m
//  BuildingMax
//
//  Created by snake on 12-2-8.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import "CCTVTableViewController.h"
#import "Device.h"
#import "CCTVHelper.h"
#import "CCTVDetailTableViewController.h"

@interface CCTVTableViewController ()
@property (nonatomic,strong) Device *deviceToPush;
@end

@implementation CCTVTableViewController

@synthesize CCTVDatabase = _CCTVDatabase;
@synthesize deviceToPush = _deviceToPush;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - hook up NSFetchedResultsController with Core Data
/* Create a fetch request and hook it up with NSFetchedResultsController from CoreDataTableViewController */
- (void)setupFetchedResultsControllerWithDoc:(UIManagedDocument *)doc
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:ENTITYNAME];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:DEVICEINFO
                                                                                          ascending:YES]];
    
    // no predicate because we want all the data
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:doc.managedObjectContext 
                                                                          sectionNameKeyPath:nil 
                                                                                   cacheName:nil];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [CCTVHelper openSharedManagedDocumentUsingBlock:^(UIManagedDocument *sharedManagedDocument){
        [self setupFetchedResultsControllerWithDoc:sharedManagedDocument];
    }];

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - CCTVAddDelegate
- (void)AddNewEntity:(CCTVAddTableViewController *)CCTVAddTableViewController
{
    // Reload don't actually load the data. We reley on reload by viewWillAppear.
    //[self.tableView reloadData];
}

#pragma mark - prepare for segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Show add view by modal style.
    if ([segue.identifier isEqualToString: @"ShowAddView"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *modalNavigationController = (UINavigationController *)segue.destinationViewController;
            
            // The root view Controller is CCTVAddTableViewController.
            if([[modalNavigationController.viewControllers objectAtIndex:0] isKindOfClass:[CCTVDetailTableViewController class]])
            {
                CCTVAddTableViewController *modalAddTVC = (CCTVAddTableViewController *)[modalNavigationController.viewControllers objectAtIndex:0];
                // Set self to be CCTVAddDelegate.
                modalAddTVC.delegate = self;
            }
        }
    }
    // Show detail view by push style.
    else if ([segue.identifier isEqualToString:@"ShowDetailView"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setSelectedDevice:)]) {
            [segue.destinationViewController setSelectedDevice:self.deviceToPush];
        }
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MainViewID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Device *device = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = device.info;
    cell.detailTextLabel.text = device.ip;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        // Run on document context thread, possibly the main thread.
        [self.fetchedResultsController.managedObjectContext performBlock:^{
            [self.fetchedResultsController.managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }];
        
        [CCTVHelper openSharedManagedDocumentUsingBlock:^(UIManagedDocument *sharedManagedDocument){
            [sharedManagedDocument saveToURL:sharedManagedDocument.fileURL
                            forSaveOperation:UIDocumentSaveForOverwriting
                           completionHandler:NULL];
        }];
    }   
}

#pragma mark - Table view delegate
// Called before prepareToSegue to setup device to push.
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.deviceToPush = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return indexPath;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //[self performSegueWithIdentifier:@"ShowAVPlayerView" sender:self];
    [self performSegueWithIdentifier:@"ShowMPMoviePlayerView" sender:self];
}

@end
