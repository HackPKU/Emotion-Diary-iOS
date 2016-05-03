//
//  StatTableViewCell.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/3.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "StatTableViewCell.h"

@implementation StatTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _lineChart.delegate = self;
    _lineChart.dataSource = self;
    [self changeScope:_segmentScope];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return chartData.count;
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    return [chartData[index] doubleValue];
}

- (IBAction)changeScope:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            chartData = [[EmotionDiaryManager sharedManager] getStatOfLastDays:7];
            break;
        case 1:
            chartData = [[EmotionDiaryManager sharedManager] getStatOfLastDays:30];
            break;
        default:
            break;
    }
    [_lineChart reloadGraph];
}

@end
