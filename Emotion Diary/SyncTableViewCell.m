//
//  SyncTableViewCell.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/11.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "SyncTableViewCell.h"

@implementation SyncTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    formatter = [NSDateFormatter new];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDiary:(EmotionDiary *)newDiary {
    diary = newDiary;
    _labelText.text = [diary.shortText stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    _labelTime.text = [formatter stringFromDate:diary.createTime];
    if (_indicatorSyncing) {
        [_indicatorSyncing startAnimating];
    }
}

@end
