//
//  BuildingMaxFirstViewController.m
//  BuildingMax
//
//  Created by snake on 11-12-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "BuildingMaxFirstViewController.h"

@implementation BuildingMaxFirstViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set a image as my custom title view. LOGO
    UIImageView *myImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"segmentedBackground.png"]] ;
    self.navigationItem.titleView = myImageView;
    
    self.view.autoresizesSubviews = YES;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Bring on the navigationbar if it has hidden
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - prepare segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowFireAlarm"]) {
        // do some preparation
    }
}

@end
