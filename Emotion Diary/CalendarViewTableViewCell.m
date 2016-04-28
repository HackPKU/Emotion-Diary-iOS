//
//  CalendarViewTableViewCell.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "CalendarViewTableViewCell.h"

@implementation CalendarViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _imageSelfie.layer.cornerRadius = _imageSelfie.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDiary:(EmotionDiarySwift *)diary {
    _imageSelfie.image = [UIImage imageWithContentsOfFile:diary.imageURL];
    NSString *imageName = [Utilities getFaceNameBySmile:(int)diary.smile];
    _imageFace.image = [UIImage imageNamed:[imageName stringByAppendingString:@"-白圈"]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    _labelTime.text = [formatter stringFromDate:diary.date];
    [formatter setDateFormat:@"MM-dd"];
    _labelDate.text = [formatter stringFromDate:diary.date];
    _textDetail.text = diary.content;
}

@end
