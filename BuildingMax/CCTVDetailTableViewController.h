//
//  CCTVDetailTableViewController.h
//  BuildingMax
//
//  Created by snake on 12-2-10.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTVAddTableViewController.h"
#import "CCTVEditTableViewController.h"
#import "Device.h"

@interface CCTVDetailTableViewController : CCTVAddTableViewController <CCTVEditDelegate>
@property (nonatomic, strong) Device *selectedDevice;
@end
