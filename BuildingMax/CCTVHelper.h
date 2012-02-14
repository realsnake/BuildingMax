//
//  CCTVHelper.h
//  BuildingMax
//
//  Created by snake on 12-2-13.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCTVHelper : NSObject

+ (void)openSharedManagedDocumentUsingBlock:(void (^)(UIManagedDocument *sharedManagedDocument))completionBlock;

@end
