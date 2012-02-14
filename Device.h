//
//  Device.h
//  BuildingMax
//
//  Created by snake on 12-2-10.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Device : NSManagedObject

@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSString * ip;
@property (nonatomic, retain) NSNumber * port;

@end
