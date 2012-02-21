//
//  CCTVMPViewController.m
//  BuildingMax
//
//  Created by snake on 12-2-21.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import "CCTVMPViewController.h"

@implementation CCTVMPViewController

@synthesize textField = _textField;
@synthesize CCTVMoviePlayerController = _CCTVMoviePlayerController;
@synthesize embeddedPlayerView = _embeddedPlayerView;



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)createAndConfigurePlayerWithURL:(NSURL *)URL
{
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:URL];
    
    if (player) {
        self.CCTVMoviePlayerController = player;
        
        player.view.frame = self.embeddedPlayerView.frame;
        player.movieSourceType = MPMovieSourceTypeStreaming;
        
        /* To present a movie in your application, incorporate the view contained 
         in a movie player’s view property into your application’s view hierarchy. 
         Be sure to size the frame correctly. */
        [self.view addSubview:player.view];
        
        [self.CCTVMoviePlayerController play];
        
    }
    
}

- (IBAction)loadButtonPressed:(id)sender
{
    [self createAndConfigurePlayerWithURL:[NSURL URLWithString:self.textField.text]];
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTextField:nil];
    [self setEmbeddedPlayerView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
