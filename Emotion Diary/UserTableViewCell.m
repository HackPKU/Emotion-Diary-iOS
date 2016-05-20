//
//  UserTableViewCell.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "UserTableViewCell.h"

@implementation UserTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    if (_lineChart) {
        _lineChart.delegate = self;
        _lineChart.dataSource = self;
        [self reloadStatData];
    }
    
    if (_imageIcon) {
        _imageIcon.layer.cornerRadius = _imageIcon.frame.size.width / 2;
    }
    
    if (_switchAutoUpload) {
        [_switchAutoUpload setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:AUTO_UPLOAD] boolValue]];
    }
    
    if (_segmentUnlockType) {
        _segmentUnlockType.selectedSegmentIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:UNLOCK_TYPE] integerValue] == EmotionDiaryUnlockTypeSelfie ? 0 : 1;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)reloadStatData {
    [self changeScope:_segmentScope];
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

- (IBAction)autoUploadChanged:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:sender.isOn] forKey:AUTO_UPLOAD];
}

- (IBAction)unlockTypeChanged:(UISegmentedControl *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:sender.selectedSegmentIndex == 0 ? EmotionDiaryUnlockTypeSelfie : EmotionDiaryUnlockTypeTouchID] forKey:UNLOCK_TYPE];
}

@end
