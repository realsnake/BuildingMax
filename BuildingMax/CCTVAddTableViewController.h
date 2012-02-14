//
//  CCTVAddTableViewController.h
//  BuildingMax
//
//  Created by snake on 12-2-10.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

@protocol CCTVAddDelegate;

@interface CCTVAddTableViewController : CoreDataTableViewController <UITextFieldDelegate>
@property (nonatomic, weak) id <CCTVAddDelegate> delegate;
@end

@protocol CCTVAddDelegate <NSObject>

- (void)AddNewEntity:(CCTVAddTableViewController *)CCTVAddTableViewController;

@end