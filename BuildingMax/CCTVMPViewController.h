//
//  CCTVMPViewController.h
//  BuildingMax
//
//  Created by snake on 12-2-21.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CCTVMPViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic, strong) MPMoviePlayerController *CCTVMoviePlayerController;
@property (weak, nonatomic) IBOutlet UIView *embeddedPlayerView;
@end
