//
//  PieChartViewController.m
//  CorePlotDemo
//
//  Created by snake on 12-2-22.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import "PieChartViewController.h"

@implementation PieChartViewController

@synthesize pieChart = _pieChart;
@synthesize dataForChart = _dataForChart;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat margin = self.pieChart.plotAreaFrame.borderLineStyle.lineWidth + 5.0;
    
    CPTPieChart *piePlot = (CPTPieChart *)[self.pieChart plotWithIdentifier:@"Pie Chart 1"];
    CGRect plotBounds = self.pieChart.plotAreaFrame.bounds;
    CGFloat newRadius = MIN(plotBounds.size.width, plotBounds.size.height) / 2.0 - margin;
    
    [CATransaction begin];
    {
        [CATransaction setAnimationDuration:1.0];
        [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"pieRadius"];
        animation.toValue = [NSNumber numberWithFloat:newRadius];
        animation.fillMode = kCAFillModeForwards;
        animation.delegate = self;
        [piePlot addAnimation:animation forKey:@"pieRadius"];
    }
    [CATransaction commit];
}

- (void)setupPieChart
{
    // Create pie chart from theme
    self.pieChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [self.pieChart applyTheme:theme];
    
    CPTGraphHostingView *hostView = (CPTGraphHostingView *)self.view;
    hostView.hostedGraph = self.pieChart;
    
    self.pieChart.paddingLeft = 20.0;
	self.pieChart.paddingTop = 20.0;
	self.pieChart.paddingRight = 20.0;
	self.pieChart.paddingBottom = 20.0;
    
    self.pieChart.axisSet = nil;
    
    CPTMutableTextStyle *whiteStyle = [CPTMutableTextStyle textStyle];
    whiteStyle.color = [CPTColor whiteColor];
    
    self.pieChart.titleTextStyle = whiteStyle;
    self.pieChart.title = @"Graph Title";
    
    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius = 125.0f;
    piePlot.identifier = @"Pie Chart 1";
    piePlot.startAngle = M_PI_2;
    piePlot.sliceDirection = CPTPieDirectionClockwise;
    piePlot.centerAnchor = CGPointMake(0.5, 0.5);
    piePlot.borderLineStyle = [CPTLineStyle lineStyle];
    piePlot.delegate = self;
    
    [self.pieChart addPlot:piePlot];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:[NSNumber numberWithDouble:20.0], [NSNumber numberWithDouble:30.0], [NSNumber numberWithDouble:60.0], [NSNumber numberWithDouble:80.0], [NSNumber numberWithDouble:50.0], nil];
    self.dataForChart = contentArray;
    
    [self setupPieChart];
}

#pragma mark - Pie chart datasource methods
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [self.dataForChart count];
}

- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if (index >= [self.dataForChart count]) {
        return nil;
    }
    
    if (fieldEnum == CPTPieChartFieldSliceWidth) {
        return [self.dataForChart objectAtIndex:index];
    }
    else
    {
        return [NSNumber numberWithUnsignedInteger:index];
    }
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%lu",index]];
    CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
    
    textStyle.color = [CPTColor lightGrayColor];
    label.textStyle = textStyle;
    
    return label;
}

- (CGFloat)radialOffsetForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    CGFloat offset = 0.0f;
    if (index == 0) {
        //offset = pieChart.pieRadius / 18.0;
    }
    
    return offset;
}

#pragma mark - Pie chard delegate methods

- (void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    self.pieChart.title = [NSString stringWithFormat:@"selected index %lu",index];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    CPTPieChart *piePlot = (CPTPieChart *)[self.pieChart plotWithIdentifier:@"Pie Chart 1"];
    CABasicAnimation *basicAnimation = (CABasicAnimation *)anim;
    
    [piePlot removeAnimationForKey:basicAnimation.keyPath];
    [piePlot setValue:basicAnimation.toValue forKey:basicAnimation.keyPath];
    [piePlot repositionAllLabelAnnotations];
}
@end
