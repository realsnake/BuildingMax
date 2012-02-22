//
//  BarChartViewController.m
//  CorePlotDemo
//
//  Created by snake on 12-2-21.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import "BarChartViewController.h"

@implementation BarChartViewController

@synthesize barChart = _barChart;

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
    
    self.barChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    
    CPTTheme *theme = [CPTTheme themeNamed:kCPTSlateTheme];
    [self.barChart applyTheme:theme];
    
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
    hostingView.hostedGraph = self.barChart;
    
    // Border
    self.barChart.plotAreaFrame.borderLineStyle = nil;
    self.barChart.plotAreaFrame.cornerRadius = 1.0f;
    
    // Paddings
    self.barChart.paddingTop = 0.0f;
    self.barChart.paddingBottom = 0.0f;
    self.barChart.paddingLeft = 0.0f;
    self.barChart.paddingRight = 0.0f;
    
    self.barChart.plotAreaFrame.paddingTop = 20.0f;
    self.barChart.plotAreaFrame.paddingBottom = 80.0f;
    self.barChart.plotAreaFrame.paddingLeft = 70.0f;
    self.barChart.plotAreaFrame.paddingRight = 20.0f;
    
    // Graph title
    self.barChart.title = @"Graph Title\n Line 2";
    CPTMutableTextStyle *textStyle = [CPTTextStyle textStyle];
    textStyle.color = [CPTColor grayColor];
    textStyle.fontSize = 16.0f;
    textStyle.textAlignment = CPTTextAlignmentCenter;
    self.barChart.titleTextStyle = textStyle;
    self.barChart.titleDisplacement = CGPointMake(0.0f, -20.0f);
    self.barChart.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.barChart.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(300.0f)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(16.0f)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.barChart.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    x.axisLineStyle = nil;
    x.majorTickLineStyle = nil;
    x.minorTickLineStyle = nil;
    x.majorIntervalLength = CPTDecimalFromString(@"5");
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    x.title = @"X轴";
    x.titleLocation = CPTDecimalFromFloat(7.5f);
    x.titleOffset = 55.0f;
    
    // Define some custom labels for the data elements
    x.labelRotation = M_PI / 4;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    NSArray *customTickLocations = [NSArray arrayWithObjects:[NSDecimalNumber numberWithInt:1], [NSDecimalNumber numberWithInt:5], [NSDecimalNumber numberWithInt:10], [NSDecimalNumber numberWithInt:15], nil];
    NSArray *xAxisLabels = [NSArray arrayWithObjects:@"Label A", @"Label B", @"Label C", @"Label D", @"Label E", nil];
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:[xAxisLabels count]];
    NSUInteger labelLocation = 0;
    for (NSNumber *tickLocation in customTickLocations)
    {
        CPTAxisLabel *newLable = [[CPTAxisLabel alloc] initWithText:[xAxisLabels objectAtIndex:labelLocation++] textStyle:x.labelTextStyle];
        newLable.tickLocation = [tickLocation decimalValue];
        newLable.offset = x.labelOffset + x.majorTickLength;
        newLable.rotation = M_PI / 4;
        [customLabels addObject:newLable];
    }
    x.axisLabels = [NSSet setWithArray:customLabels];
    
    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle = nil;
    y.majorTickLineStyle = nil;
    y.minorTickLineStyle = nil;
    y.majorIntervalLength = CPTDecimalFromString(@"50");
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    y.title = @"Y轴";
    y.titleLocation = CPTDecimalFromFloat(150.0f);
    y.titleOffset = 40.0f;
    
    // First bar plot
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
    barPlot.baseValue = CPTDecimalFromFloat(0.0);
    barPlot.dataSource = self;
    barPlot.barOffset = CPTDecimalFromFloat(-0.25f);
    barPlot.identifier = @"Bar Plot 1";
    [self.barChart addPlot:barPlot toPlotSpace:plotSpace];
    
    // Second bar plot
    barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    barPlot.baseValue = CPTDecimalFromFloat(0.0);
    barPlot.dataSource = self;
    barPlot.barOffset = CPTDecimalFromFloat(0.25f);
    barPlot.cornerRadius = 2.0f;
    barPlot.identifier = @"Bar Plot 2";
    [self.barChart addPlot:barPlot toPlotSpace:plotSpace];    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    return YES;
}

#pragma mark - barplot datasource 
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 16;
}

- (NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = nil;
    if ([plot isKindOfClass:[CPTBarPlot class]]) {
        switch (fieldEnum) {
            case CPTBarPlotFieldBarLocation:
            {
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInt:index];
                break;

            }
            case CPTBarPlotFieldBarTip:
            {
                num = (NSDecimalNumber *)[NSDecimalNumber numberWithUnsignedInt:(index + 1) * (index + 1)];
                if ([plot.identifier isEqual:@"Bar Plot 2"]) {
                    num = [num decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:@"10"]];
                }
                break;
                
            }
                
            default:
                break;
        }
    }
    
    return num;
}

@end
