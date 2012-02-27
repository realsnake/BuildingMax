//
//  CCTVDetailTableViewController.m
//  BuildingMax
//
//  Created by snake on 12-2-10.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import "CCTVDetailTableViewController.h"
#import "CCTVEditTableViewController.h"
#import "CCTVHelper.h"

@implementation CCTVDetailTableViewController

@synthesize selectedDevice = _selectedDevice;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - delete button handler
- (void)deleteDevice
{
    [CCTVHelper openSharedManagedDocumentUsingBlock:^(UIManagedDocument *sharedManagedDocument) {
        if (sharedManagedDocument) {
            // Run on document context thread, possibly the main thread.
            [sharedManagedDocument.managedObjectContext performBlock:^{
                [sharedManagedDocument.managedObjectContext deleteObject:self.selectedDevice];
            }];
            
            // Run on the caller thread, should be the main thread.
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    deleteButton.userInteractionEnabled = YES;
    deleteButton.frame = CGRectMake(10, 0, 300, 40);
    deleteButton.backgroundColor = [UIColor redColor];
    [deleteButton setTitle:@"删 除" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteDevice) forControlEvents:UIControlEventTouchUpInside];

    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)];
    [footView addSubview:deleteButton];
    
    self.tableView.tableFooterView = footView;
    self.tableView.tableFooterView.userInteractionEnabled = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DetailInfo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case SECTION_INFO:
        {
            cell.textLabel.text = self.selectedDevice.info;
            break;
        }
        case SECTION_IP:
        {
            cell.textLabel.text = self.selectedDevice.ip;
            break;
        }
        case SECTION_PORT:
        {
            cell.textLabel.text = [self.selectedDevice.port stringValue];
            break;
        }
        default:
            break;
    }

    return cell;
}

#pragma mark - prepare segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowEditView"]) {
        if ([segue.destinationViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *destinationNavController = segue.destinationViewController;
            
            // top view controller should be CCTVEditViewController
            if ([destinationNavController.topViewController respondsToSelector:@selector(setEditDevice:)]) {
                CCTVEditTableViewController *editTVC = (CCTVEditTableViewController *)destinationNavController.topViewController;
                [editTVC setEditDevice:self.selectedDevice];
                editTVC.editDelegate = self;
            }

        }
    }
}

#pragma mark - CCTVEditDelegte
- (void)saveForEditDevice:(CCTVEditTableViewController *)sender
{
    self.selectedDevice = sender.editDevice;
    [self.tableView reloadData];
}
@end
