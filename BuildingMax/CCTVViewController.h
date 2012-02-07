//
//  CCTVViewController.h
//  BuildingMax
//
//  Created by snake on 12-2-3.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CCTVPlayerLayerView.h"

@interface CCTVViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (weak, nonatomic) IBOutlet CCTVPlayerLayerView *CCTVPlayerLayerView;
@property (weak, nonatomic) IBOutlet UITextField *URLTextField;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pauseButton;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;

@end
