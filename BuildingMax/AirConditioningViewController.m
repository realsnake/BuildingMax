//
//  AirConditioningViewController.m
//  BuildingMax
//
//  Created by snake on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AirConditioningViewController.h"

@implementation AirConditioningViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


- (void)playVideo:(NSString *)urlString frame:(CGRect)frame
{
    NSString *embedHTML = @"\
    <html><head>\
    <style type=\"text/css\">\
    body {\
    background-color: transparent;\
    color: white;\
    }\
    </style>\
    <script>\
    function load(){document.getElementById(\"yt\").play();}\
    </script>\
    </head><body onload=\"load()\"style=\"margin:0\">\
    <video id=\"yt\" src=\"%@\" \
    width=\"%0.0f\" height=\"%0.0f\" autoplay controls></video>\
    <video id=\"yt2\" src=\"%@\" \
    width=\"%0.0f\" height=\"%0.0f\" autoplay controls></video>\
    </body></html>";
    NSString *html = [NSString stringWithFormat:embedHTML, urlString, frame.size.width, frame.size.height/2,
                      urlString, frame.size.width, frame.size.height/2];
    UIWebView *videoView = [[UIWebView alloc] initWithFrame:frame];
    [videoView loadHTMLString:html baseURL:nil];
    //NSURLRequest * URLRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.200/mjpg/video.mjpg"]];
    //[videoView loadRequest:URLRequest];
    [self.view addSubview:videoView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Hide the navigationbar.
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self playVideo:@"http://movies.apple.com/media/us/mac/ilife/imovie/2009/tutorials/apple-ilife-imovie-intro_imovie_09-us-20090122_r640-10cie.mov?width=640&amp;height=400" frame:self.view.frame];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Back to main page.
    [self.navigationController popToRootViewControllerAnimated:YES];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
