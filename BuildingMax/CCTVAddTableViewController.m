//
//  CCTVAddTableViewController.m
//  BuildingMax
//
//  Created by snake on 12-2-10.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import "CCTVAddTableViewController.h"
#import "Device.h"
#import "CCTVHelper.h"

#define SECTION_INFO    0
#define SECTION_IP      1
#define SECTION_PORT    2
#define SECTION_NUMBER  3

@implementation CCTVAddTableViewController

@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
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

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag +1;

    if (nextTag <= SECTION_NUMBER)
    {
        UIResponder *nextResponder = [self.view viewWithTag:nextTag];
        // Notice: if don't call resiganFirstResponder here, the keyboard will overlap the textfield.
        [textField resignFirstResponder];
        [nextResponder becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    // Do not insert line-breaks.
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return SECTION_NUMBER;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionHeader;
    switch (section) {
        case SECTION_INFO:
        {
            sectionHeader = @"描述";
            break;
        }
        case SECTION_IP:
        {
            sectionHeader = @"IP地址";
            break;
        }
        case SECTION_PORT:
        {
            sectionHeader = @"端口号";
            break;
        }
        default:
            break;
    }
    
    return sectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddViewID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 50)];
    [cell.contentView addSubview:textField];

    textField.delegate = self;
    textField.tag = indexPath.section;
    
    if ((SECTION_NUMBER - 1) == indexPath.section) {
        textField.returnKeyType = UIReturnKeyDone;
    }
    else
    {
        textField.returnKeyType = UIReturnKeyNext;
 
    }
    switch (indexPath.section) {
        case SECTION_INFO:
        {
            textField.keyboardType = UIKeyboardTypeDefault;
            break;
        }
        case SECTION_IP:
        {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        }
        case SECTION_PORT:
        {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            break;
        }
        case 3:
        {
            NSLog(@"text3 tag is %d",textField.tag);
            break;
        }
            
        default:
            break;
    }
    if (3 == indexPath.section) {
        cell.textLabel.text = nil;
        UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteButton.frame = cell.contentView.frame;
        [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [cell.contentView addSubview:deleteButton];
    }
    return cell;
}

#pragma mark - dissmiss modal view by button actions

- (void)saveToDatabaseWithDoc:(UIManagedDocument *)doc
{
    Device *deviceToSave = [NSEntityDescription insertNewObjectForEntityForName:@"Device" inManagedObjectContext:doc.managedObjectContext];
    
    // Find all the UITextField in the subviews
    NSMutableArray *textFieldArray = [[NSMutableArray alloc] init];
    for (UITableViewCell *tableViewCell in self.view.subviews ) {
        if ([tableViewCell isKindOfClass:[UITableViewCell class]]) {
            for (UITextField *textFieldInCell in tableViewCell.contentView.subviews) {
                if ([textFieldInCell isKindOfClass:[UITextField class]]) {
                    [textFieldArray addObject:textFieldInCell];
                }
            }
        }
    }
    
    for (UITextField *textField in textFieldArray) {
        switch (textField.tag) {
            case SECTION_INFO:
            {
                deviceToSave.info = textField.text;
                break;
            }
            case SECTION_IP:
            {      
                deviceToSave.ip = textField.text;
                break;
            }
            case SECTION_PORT:
            {
                deviceToSave.port = [NSNumber numberWithInt:[textField.text intValue]];
                break;
            }
            default:
                break;
        }
    }
    // should probably saveToURL:forSaveOperation:(UIDocumentSaveForOverwriting)completionHandler: here!
    // we could decide to rely on UIManagedDocument's autosaving, but explicit saving would be better
    // because if we quit the app before autosave happens, then it'll come up blank next time we run
    // this is what it would look like ...
    [doc saveToURL:doc.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
}

- (IBAction)save:(id)sender
{
    [CCTVHelper openSharedManagedDocumentUsingBlock:^(UIManagedDocument *sharedManagedDocument) {
        [sharedManagedDocument.managedObjectContext performBlock:^{
            [self saveToDatabaseWithDoc:sharedManagedDocument];
        }];
    }];
    [self.delegate AddNewEntity:self];
}

- (IBAction)cancel:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
