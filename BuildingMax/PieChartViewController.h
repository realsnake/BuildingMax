//
//  PieChartViewController.h
//  CorePlotDemo
//
//  Created by snake on 12-2-22.
//  Copyright (c) 2012年 深圳市新基点智能技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "./CorePlotHeaders/CorePlot-CocoaTouch.h"

@interface PieChartViewController : UIViewController <CPTPieChartDelegate, CPTPieChartDataSource>

@property (nonatomic, strong) CPTXYGraph *pieChart;
@property (nonatomic, strong) NSMutableArray *dataForChart;
@end
