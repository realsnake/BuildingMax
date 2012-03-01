
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

@interface CCTVAddTableViewController()

@property (nonatomic, strong) NSString *addDeviceInfo;
@property (nonatomic, strong) NSString *addDeviceIP;
@property (nonatomic, strong) NSNumber *addDevicePort;

@end

@implementation CCTVAddTableViewController

@synthesize delegate = _delegate;
@synthesize addDeviceInfo = _addDeviceInfo;
@synthesize addDeviceIP = _addDeviceIP;
@synthesize addDevicePort = _addDevicePort;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return SECTION_NUMBER;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ROWS_IN_SECTION;
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
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
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
        default:
            break;
    }

    return cell;
}

#pragma mark - dissmiss modal view by button actions
- (BOOL)isRepeatDevice:(UIManagedDocument *)doc
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:ENTITYNAME];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:DEVICEINFO
                                                                                          ascending:YES]];
    NSArray *deviceArray = [doc.managedObjectContext executeFetchRequest:fetchRequest error:nil]; 
    
    for (Device * newDevice in deviceArray) {
        if (([newDevice.info isEqualToString: self.addDeviceInfo]) && 
            ([newDevice.ip isEqualToString: self.addDeviceIP]) &&
            ([newDevice.port intValue] == [self.addDevicePort intValue])) 
        {
            return YES;
        }
    }
    
    return NO;
}

- (void)saveToDatabaseWithDoc:(UIManagedDocument *)doc
{
    Device *deviceToSave = [NSEntityDescription insertNewObjectForEntityForName:ENTITYNAME inManagedObjectContext:doc.
                            managedObjectContext];
    
    deviceToSave.info = self.addDeviceInfo;
    deviceToSave.ip = self.addDeviceIP;
    deviceToSave.port = self.addDevicePort;
    
    // should probably saveToURL:forSaveOperation:(UIDocumentSaveForOverwriting)completionHandler: here!
    // we could decide to rely on UIManagedDocument's autosaving, but explicit saving would be better
    // because if we quit the app before autosave happens, then it'll come up blank next time we run
    // this is what it would look like ...
    [doc saveToURL:doc.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
}

- (BOOL)isTextFieldBlank
{
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
        // Blank field is not allowed.
        if (0 == [textField.text length]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)presentAlertView:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
    
}

- (IBAction)save:(id)sender
{
    if ([self isTextFieldBlank])
    {
        NSString *localizedDescription = NSLocalizedString(@"请填写完整", @"信息不完整描述");
        NSDictionary *errorDictionary = [NSDictionary dictionaryWithObjectsAndKeys:localizedDescription, NSLocalizedDescriptionKey, nil];
        NSError *blankError = [NSError errorWithDomain:@"BuildingMax" code:0 userInfo:errorDictionary];
        [self presentAlertView:blankError];    }
    else
    {
        
        [CCTVHelper openSharedManagedDocumentUsingBlock:^(UIManagedDocument *sharedManagedDocument) {
            if (sharedManagedDocument) {
                [sharedManagedDocument.managedObjectContext performBlock:^{
                    if (![self isRepeatDevice:sharedManagedDocument]) {
                        [self saveToDatabaseWithDoc:sharedManagedDocument];
                    }
                }];
            }
        }];
        
        // Not used for now.
        //[self.delegate AddNewEntity:self];
        
        [self dismissModalViewControllerAnimated:YES];
    }
    
}

- (IBAction)cancel:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextField delegate

- (BOOL)validateIP:(NSString *)IPString
{
    // valid IP address contains only characters in "0123456789."
    NSCharacterSet *invalidIPSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSRange range = [IPString rangeOfCharacterFromSet:invalidIPSet];
    if (range.location != NSNotFound) {
        return FALSE;
    }

    // string separated by "." should has 4 segments for an valid IP address
    if ([[IPString componentsSeparatedByString:@"."] count] != 4) {
        return FALSE;
    }

    // validate IP address value
    unsigned int ipQuads[4] = {256,256,256,256};    // invalid default value
    const char *ipAddress = [IPString cStringUsingEncoding:NSUTF8StringEncoding];    
    sscanf(ipAddress, "%u.%u.%u.%u", &ipQuads[0], &ipQuads[1], &ipQuads[2], &ipQuads[3]);
    
    for (int quad = 0; quad < 4; quad++) {
        if ( ipQuads[quad] > 255) {
            return FALSE;
        }
    }
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;

    switch (textField.tag)
    {
        case SECTION_INFO:
        {
            UIResponder *nextResponder = [self.view viewWithTag:nextTag];
            // Notice: if don't call resiganFirstResponder here, the keyboard will overlap the textfield.
            [textField resignFirstResponder];
            [nextResponder becomeFirstResponder];

            break;
        }
            
        case SECTION_IP:
        {
            if (FALSE == [self validateIP:textField.text])
            {
                NSString *localizedDescription = NSLocalizedString(@"无效IP地址", @"无效IP地址");
                NSDictionary *errorDictionary = [NSDictionary dictionaryWithObjectsAndKeys:localizedDescription, NSLocalizedDescriptionKey, nil];
                NSError *portError = [NSError errorWithDomain:@"BuildingMax" code:0 userInfo:errorDictionary];
                [self presentAlertView:portError];
                
                textField.text = nil;
            }
            else {
                UIResponder *nextResponder = [self.view viewWithTag:nextTag];
                // Notice: if don't call resiganFirstResponder here, the keyboard will overlap the textfield.
                [textField resignFirstResponder];
                [nextResponder becomeFirstResponder];
            }
            break;
        }
            
        case SECTION_PORT:
        {
            NSCharacterSet *setWithoutNumbers = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
            NSRange range = [textField.text rangeOfCharacterFromSet:setWithoutNumbers];
            int portNumber = [textField.text intValue];
            
            // Port valid value is between 0 and 65535
            // Only digital number is allowed.
            if ((portNumber > 65535 || portNumber <= 0) || (range.location != NSNotFound))
            {
                NSString *localizedDescription = NSLocalizedString(@"端口号无效", @"端口号无效描述");
                NSDictionary *errorDictionary = [NSDictionary dictionaryWithObjectsAndKeys:localizedDescription, NSLocalizedDescriptionKey, nil];
                NSError *portError = [NSError errorWithDomain:@"BuildingMax" code:0 userInfo:errorDictionary];
                [self presentAlertView:portError];
                
                textField.text = nil;
            }
            else {
                [textField resignFirstResponder];
            }
            break;
        }
            
        default:
            break;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case SECTION_INFO:
        {
            self.addDeviceInfo = textField.text;
            break;
        }
            
        case SECTION_IP:
        {
            self.addDeviceIP = textField.text;
            break;
        }
            
        case SECTION_PORT:
        {
            self.addDevicePort = [NSNumber numberWithInt:[textField.text intValue]];
            break;
        }
            
        default:
            break;
    }
}
@end
