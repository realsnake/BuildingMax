//
//  CCTVViewController.m
//  BuildingMax
//
//  Created by snake on 12-2-3.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import "CCTVViewController.h"

@implementation CCTVViewController
{
    BOOL _seekToZeroBeforePlay;
    float _restoredAfterScrubbingRate;
    id _timeObserver;
}

@synthesize URLTextField = _URLTextField;
@synthesize loadButton = _loadButton;
@synthesize toolbar = _toolbar;
@synthesize playButton = _playButton;
@synthesize pauseButton = _pauseButton;
@synthesize fullScreenButton = _fullScreenButton;
@synthesize timeSlider = _timeSlider;
@synthesize player = _player;
@synthesize playerItem = _playerItem;
@synthesize CCTVPlayerLayerView = _CCTVPlayerLayerView;

static void *playCurrentItemKeyObservationContext = &playCurrentItemKeyObservationContext;
static void *playerItemStatusKeyObservationContext = &playerItemStatusKeyObservationContext;
static void *playerRateKeyObservationContext = &playerRateKeyObservationContext;

NSString *kStatusKey	= @"status";
NSString *kCurrentItemKey	= @"currentItem";
NSString *kRateKey	= @"rate";

#pragma mark - playerItem
- (BOOL)isPlaying
{
    return [self.player rate] != 0.f || _restoredAfterScrubbingRate != 0.f;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    _seekToZeroBeforePlay = YES;
}

- (CMTime)playerItemDuration
{
    if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        /* 
         NOTE:
         Because of the dynamic nature of HTTP Live Streaming Media, the best practice 
         for obtaining the duration of an AVPlayerItem object has changed in iOS 4.3. 
         Prior to iOS 4.3, you would obtain the duration of a player item by fetching 
         the value of the duration property of its associated AVAsset object. However, 
         note that for HTTP Live Streaming Media the duration of a player item during 
         any particular playback session may differ from the duration of its asset. For 
         this reason a new key-value observable duration property has been defined on 
         AVPlayerItem.
         
         See the AV Foundation Release Notes for iOS 4.3 for more information.
         */		
        
        return ([self.playerItem duration]);
    }
    return kCMTimeInvalid;
}

#pragma mark - movie scrubber control
/* Set the scrubber base on the player current time */
- (void)syncScrubber
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        self.timeSlider.minimumValue = 0.0f;
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        double time = CMTimeGetSeconds([self.player currentTime]);
        float maxValue = self.timeSlider.maximumValue;
        float minValue = self.timeSlider.minimumValue;
        
        self.timeSlider.value =(maxValue - minValue) * time / duration + minValue;
    }
}

/* Request invocation of a given block during media playback to update the movie scrubber control */
- (void)initScrubberTimer
{
    double interval = 0.1f;
    CMTime playerItemDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerItemDuration)) {
        return;
    }
    double duration = CMTimeGetSeconds(playerItemDuration);
    if (isfinite(duration)) {
        CGFloat width = self.timeSlider.bounds.size.width;
        interval = 0.5f * duration/width;
    }
    
    __weak CCTVViewController *weakSelf = self;
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                              queue:NULL
                                                         usingBlock:^(CMTime time) {
                                                             [weakSelf syncScrubber];
                                                         }];
}

/* Cancel the time observer */
- (void)removePlayerTimeObserver
{
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

- (BOOL)isScrubbing
{
    return _restoredAfterScrubbingRate != 0.0f;
}

- (void)enableScrubber
{
    self.timeSlider.enabled = YES;
}

- (void)disableScrubber
{
    self.timeSlider.enabled = NO;
}

#pragma mark - UIToolbarItem
- (void)showPauseButton
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
    [toolbarItems replaceObjectAtIndex:0 withObject:self.pauseButton];
    self.toolbar.items = toolbarItems;
}

- (void)showPlayButton
{
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithArray:self.toolbar.items];
    [toolbarItems replaceObjectAtIndex:0 withObject:self.playButton];
    self.toolbar.items = toolbarItems;
}

- (void)enablePlayerButtons
{
    self.playButton.enabled = YES;
    self.pauseButton.enabled = YES;
}

- (void)disablePlayerButtons
{
    self.playButton.enabled = NO;
    self.pauseButton.enabled = NO;
}

- (void)showPlayOrPauseButton
{
    if ([self isPlaying]) {
        [self showPauseButton];
    }
    else
    {
        [self showPlayButton];
    }
}

#pragma mark - time slider scrubber control
- (IBAction)beginScrubbing:(UISlider *)sender
{
    _restoredAfterScrubbingRate = self.player.rate;
    self.player.rate = 0.0f;
    
    // remove previous timer
    [self removePlayerTimeObserver];
}

- (IBAction)endScrubbing:(UISlider *)sender
{
    if (_restoredAfterScrubbingRate) {
        self.player.rate = _restoredAfterScrubbingRate;
        _restoredAfterScrubbingRate = 0.0f;
    }
    
    // restore the time observer
    if (_timeObserver) {
        CMTime playerDuration = [self playerItemDuration];
        if (CMTIME_IS_INVALID(playerDuration)) {
            return;
        }
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration)) {
            CGFloat width = self.timeSlider.bounds.size.width;
            double tolerance = 0.5 * duration /width;
            
            // fix memory cycle
            __weak CCTVViewController *weakSelf = self;
            _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(tolerance, NSEC_PER_SEC)
                                                                              queue:NULL
                                                                         usingBlock:^(CMTime time) {
                                                                                         [weakSelf syncScrubber];
                                                                                 }];
        } 
    }
}
- (IBAction)scub:(UISlider *)sender 
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        float maxValue = sender.maximumValue;
        float minValue = sender.minimumValue;
        float value = sender.value;
        
        double time = (value - minValue) * duration / (maxValue - minValue);
        [self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
    }
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - asset prepration

- (void)assetFailedToPrepareForPlayback:(NSError *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                        message:[error localizedFailureReason]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

/*  Called by the completion handler to check the request key status (tracks and playable).
    Set up AVPlayerItem and AVPlayer to play the asset. */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestKeys
{
    for (NSString * key in requestKeys) {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
        if (keyStatus == AVKeyValueStatusFailed) {
            [self assetFailedToPrepareForPlayback:error];
            
            return;
        } else if (keyStatus == AVKeyValueStatusCancelled){
            // handle cancel here
            return;
        }
    }
    
    // verify playable status
    if (!asset.playable) {
        // Generate error description for the failure 
		NSString *localizedDescription = NSLocalizedString(@"Item cannot be played", @"Item cannot be played description");
		NSString *localizedFailureReason = NSLocalizedString(@"The assets tracks were loaded, but could not be made playable.", @"Item cannot be played failure reason");
        NSDictionary *errorDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                         localizedDescription, NSLocalizedDescriptionKey,
                                         localizedFailureReason, NSLocalizedFailureReasonErrorKey,
                                         nil];
        NSError *assertCannotBePlayedError = [NSError errorWithDomain:@"BuildingMax" code:0 userInfo:errorDictionary];
        
        // Display the error to user
        [self assetFailedToPrepareForPlayback:assertCannotBePlayedError];
        
        return;
    }
    
    if (self.playerItem) {
        /* remove existing playeritme status observer */
        [self.playerItem removeObserver:self forKeyPath:kStatusKey];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:self.playerItem];
    }
    
    /* Create a new instance of AVPlayerItem from the now successfully loaded AVAsset. */
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    /* Observe the player item status to determine when it's ready to play */
    [self.playerItem addObserver:self
                      forKeyPath:kStatusKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:playerItemStatusKeyObservationContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    _seekToZeroBeforePlay = NO;
    
    /* Create a new AVPlayer if we don't already have one */
    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        
        // Add an observe to find out when the replacement will/did occur
        [self.player addObserver:self
                      forKeyPath:kCurrentItemKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:playCurrentItemKeyObservationContext];
        
        /* Observe the AVPlayer's rate to update the scrubber control */
        [self.player addObserver:self
                      forKeyPath:kRateKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:playerRateKeyObservationContext];

    }
    
    // set our new playerItem
    if (self.playerItem != self.player.currentItem) {
        /* Replace the player item with a new player item. The item replacement occurs 
         asynchronously; observe the currentItem property to find out when the 
         replacement will/did occur*/
        [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        
        [self showPlayOrPauseButton];
    }
    
    [self.timeSlider setValue:0.0];
}

#pragma mark - Key value observer for currentItem
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == playerItemStatusKeyObservationContext)
    {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        switch (status) {
            case AVPlayerStatusUnknown:
            {
                NSLog(@"AVPlayerStatusUnknown!");
                [self removePlayerTimeObserver];
                [self syncScrubber];
                
                [self disableScrubber];
                [self disablePlayerButtons];
                break;
            }
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e. 
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 its duration can be fetched from the item. */
                [self initScrubberTimer];

                self.toolbar.hidden = NO;
                
                /* Show the movie slider control since the movie is now ready to play. */
                self.timeSlider.hidden = NO;

                [self enableScrubber];
                [self enablePlayerButtons];
                
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

                                
                /* Set the AVPlayerLayer on the view to allow the AVPlayer to play its content. */
                [self.CCTVPlayerLayerView.playerLayer setPlayer:self.player];
                break;
            }
            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error];
                break;
            }
                
            default:
                break;
        }
    }
    else if (context == playCurrentItemKeyObservationContext)
    {
        AVPlayerItem *newPlayerItem = [change valueForKey:NSKeyValueChangeNewKey];
        if (newPlayerItem) {
            // Set the AVPlayer for which the player layer displays visual output. */
            [self.CCTVPlayerLayerView.playerLayer setPlayer:self.player];
            
            self.CCTVPlayerLayerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        }
        else
        {
            [self disablePlayerButtons];
            [self disableScrubber];
        }
    }
    else if (context == playerRateKeyObservationContext)
    {
        [self showPlayOrPauseButton];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma  mark - button actions
- (IBAction)loadButtonPressed:(UIButton *)sender
{
    // Is there a URL
    if (self.URLTextField.text.length > 0) {
        /* apply sample movie http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8 */
        NSURL *newURL = [NSURL URLWithString:self.URLTextField.text];
        // Sanity check on the newURL.
        if ([newURL scheme]) {
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:newURL options:nil];
            
            NSString *tracksKey = @"tracks";
            NSString *playableKey = @"playable";
            NSArray *requestKeys = [NSArray arrayWithObjects:tracksKey, playableKey, nil];
            
            /* Tells the asset to load the values of any of the specified keys that are not already loaded. */
            [asset loadValuesAsynchronouslyForKeys:requestKeys completionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    /* IMPORTANT: Must dispatch to main queue in order to operate on the AVPlayer and AVPlayerItem. */
                    [self prepareToPlayAsset:asset withKeys:requestKeys];
                });
            }];
        }
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (IBAction)playButtonPressed:(UIBarButtonItem *)sender 
{    
    if (_seekToZeroBeforePlay == YES) {
        [self.player seekToTime:kCMTimeZero];
        _seekToZeroBeforePlay = NO;
    }
    [self.player play];
    [self showPauseButton];
}

- (IBAction)PauseButtonPressed:(UIBarButtonItem *)sender
{
    [self.player pause];
    [self showPlayButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.URLTextField resignFirstResponder];
    return YES;
}
#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *scrubberItem = [[UIBarButtonItem alloc] initWithCustomView:self.timeSlider];
    UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbar.items = [NSArray arrayWithObjects:self.playButton, flexItem, scrubberItem, flexItem, self.fullScreenButton, nil];
}


- (void)viewDidUnload
{
    [self setURLTextField:nil];
    [self setLoadButton:nil];
    [self setToolbar:nil];
    [self setPlayButton:nil];
    [self setPauseButton:nil];
    [self setCCTVPlayerLayerView:nil];
    [self setTimeSlider:nil];
    [self setFullScreenButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



- (IBAction)fullScreenButtonPressed:(id)sender 
{
    
    self.CCTVPlayerLayerView.frame = self.view.frame;
    self.loadButton.hidden = YES;
    self.URLTextField.hidden = YES;

    [self.navigationController setNavigationBarHidden:YES animated:YES];

}

@end
