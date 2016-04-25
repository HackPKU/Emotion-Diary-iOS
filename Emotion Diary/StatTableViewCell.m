//
//  StatTableViewCell.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "StatTableViewCell.h"
#import "AppDelegate.h"

@implementation StatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(NSArray *)data {
    // Setting up the line chart
    
    _lineChart.verticalGridStep = 4;
    _lineChart.horizontalGridStep = 1;
    _lineChart.lineWidth = 1;
    _lineChart.color = APP_COLOR;
    _lineChart.valueLabelBackgroundColor = [UIColor clearColor];
    _lineChart.fillColor = [APP_COLOR colorWithAlphaComponent:0.3];
    _lineChart.valueLabelPosition = ValueLabelLeftMirrored;
    _lineChart.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%d", (int)value];
    };
    [_lineChart setChartData:data];
}

@end
