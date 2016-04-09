//
//  StatTableViewCell.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "StatTableViewCell.h"

@implementation StatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData {
    // Generating some dummy data
    NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:7];
    for(int i=0;i<7;i++) {
        chartData[i] = [NSNumber numberWithFloat: (float)i / 30.0f + (float)(rand() % 100) / 500.0f];
    }
    
    NSArray* months = @[@"January", @"February", @"March", @"April", @"May", @"June", @"July"];
    
    // Setting up the line chart
    _lineChart.verticalGridStep = 6;
    _lineChart.horizontalGridStep = 3;
    _lineChart.displayDataPoint = YES;
    _lineChart.dataPointColor = [UIColor orangeColor];
    _lineChart.dataPointBackgroundColor = [UIColor orangeColor];
    _lineChart.dataPointRadius = 2;
    _lineChart.color = [_lineChart.dataPointColor colorWithAlphaComponent:0.3];
    _lineChart.valueLabelPosition = ValueLabelLeftMirrored;
    
    _lineChart.labelForIndex = ^(NSUInteger item) {
        return months[item];
    };
    
    _lineChart.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%.02f €", value];
    };
    
    [_lineChart setChartData:chartData];
}

@end
