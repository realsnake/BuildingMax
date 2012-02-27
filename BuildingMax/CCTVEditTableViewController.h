//
//  CCTVEditTableViewController.h
//  BuildingMax
//
//  Created by snake on 12-2-15.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCTVAddTableViewController.h"
#import "Device.h"

@protocol CCTVEditDelegate;

@interface CCTVEditTableViewController : CCTVAddTableViewController

@property (nonatomic, weak) Device *editDevice; // Use weak pointer to refer to device passed by detail view controller.
@property (nonatomic, weak) id <CCTVEditDelegate> editDelegate;

@end

@protocol CCTVEditDelegate <NSObject>

- (void)saveForEditDevice : (CCTVEditTableViewController *)sender;

@end