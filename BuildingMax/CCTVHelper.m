//
//  CCTVHelper.m
//  BuildingMax
//
//  Created by snake on 12-2-13.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import "CCTVHelper.h"
#import "Device.h"

@implementation CCTVHelper

+ (void)openSharedManagedDocumentUsingBlock:(void (^)(UIManagedDocument *sharedManagedDocument))completionBlock
{
    // This is the shared globle UIManagedDocument through this app.
    static UIManagedDocument *sharedDoc;
    
    NSURL *documentURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *databaseURL = [documentURL URLByAppendingPathComponent:@"CCTV Database"];
    
    if (!sharedDoc) {
        sharedDoc = [[UIManagedDocument alloc] initWithFileURL:databaseURL];

    }
    // Create a new database if not exist
    if (![[NSFileManager defaultManager] fileExistsAtPath:[sharedDoc.fileURL path]]) {
        [sharedDoc saveToURL:sharedDoc.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
            if (success) {
                completionBlock(sharedDoc);
            }
            else
            {
                NSLog(@"Create database fail!");
            }
        }];
    }
    // If closed, open it.
    else if (UIDocumentStateClosed == sharedDoc.documentState)
    {
        [sharedDoc openWithCompletionHandler:^(BOOL success) {
            if (success) {
                completionBlock(sharedDoc);
            }
            else
            {
                NSLog(@"Open database fail!");
            }
        }]; 
    }
    // State OK, just use it
    else if (UIDocumentStateNormal == sharedDoc.documentState)
    {
        completionBlock(sharedDoc);
    }
}
@end
