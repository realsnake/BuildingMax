//
//  CCTVTableViewController.h
//  BuildingMax
//
//  Created by snake on 12-2-8.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "CCTVAddTableViewController.h"

@interface CCTVTableViewController : CoreDataTableViewController <CCTVAddDelegate>

@property (nonatomic, strong) UIManagedDocument *CCTVDatabase;
@end
