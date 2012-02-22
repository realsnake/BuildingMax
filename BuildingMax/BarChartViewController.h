//
//  BarChartViewController.h
//  CorePlotDemo
//
//  Created by snake on 12-2-21.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "./CorePlotHeaders/CorePlot-CocoaTouch.h"

@interface BarChartViewController : UIViewController <CPTPlotDataSource>

@property (nonatomic,strong) CPTXYGraph *barChart;

@end
