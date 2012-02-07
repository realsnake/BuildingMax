//
//  CCTVPlayerLayerView.m
//  BuildingMax
//
//  Created by snake on 12-2-3.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import "CCTVPlayerLayerView.h"

@implementation CCTVPlayerLayerView


+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

// set player for this AVPlayerLayer
- (void)setPlayer:(AVPlayer *)player
{
    [(AVPlayerLayer*)[self layer] setPlayer:player];
}
@end
