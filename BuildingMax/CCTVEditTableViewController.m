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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - button action
- (IBAction)save:(id)sender
{
    // Just save to modify the same device.
    [self.editDelegate saveForEditDevice:self];
    
    [self dismissModalViewControllerAnimated:YES];
    
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
            
            // we should not alert if no input, say user canceled.
            if ([textField.text length]) {
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
            }
            break;
        }
            
        default:
            break;
    }
}
@end
