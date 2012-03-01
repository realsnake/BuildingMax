//
//  CCTVEditTableViewController.m
//  BuildingMax
//
//  Created by snake on 12-2-15.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import "CCTVEditTableViewController.h"
#import "CCTVHelper.h"


@implementation CCTVEditTableViewController

@synthesize editDevice = _editDevice;
@synthesize editDelegate = _editDelegate;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - button action
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

- (IBAction)save:(id)sender
{
    if ([self isTextFieldBlank]) {
        NSString *localizedDescription = NSLocalizedString(@"请填写完整", @"信息不完整描述");
        NSDictionary *errorDictionary = [NSDictionary dictionaryWithObjectsAndKeys:localizedDescription, NSLocalizedDescriptionKey, nil];
        NSError *blankError = [NSError errorWithDomain:@"BuildingMax" code:0 userInfo:errorDictionary];
        [self presentAlertView:blankError];
    }
    else {
        // Just save to modify the same device.
        [self.editDelegate saveForEditDevice:self];
        
        [self dismissModalViewControllerAnimated:YES];
    }

    
}

#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EditViewID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 50)];
    [cell.contentView addSubview:textField];
    
    textField.delegate = self;
    textField.tag = indexPath.section;
    
    // TODO set font here
    
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
            textField.text = self.editDevice.info;
            break;
        }
        case SECTION_IP:
        {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.text = self.editDevice.ip;
            break;
        }
        case SECTION_PORT:
        {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            textField.text = [self.editDevice.port stringValue];
            break;
        }            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITextField delegate
- (void)presentAlertView:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (textField.tag)
    {
        case SECTION_INFO:
        {
            self.editDevice.info = textField.text;
            break;
        }
            
        case SECTION_IP:
        {
            self.editDevice.ip = textField.text;
            break;
        }
            
        case SECTION_PORT:
        {
            self.editDevice.port = [NSNumber numberWithInt:[textField.text intValue]];
            break;
        }
            
        default:
            break;
    }
}
@end
