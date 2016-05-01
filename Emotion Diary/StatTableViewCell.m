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
    _lineChart.delegate = self;
    _lineChart.dataSource = self;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(NSArray *)data {
    _data = data;
    [_lineChart reloadGraph];
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return _data.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [_data[index] intValue];
}

@end
