//
//  CalendarTableViewCell.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "CalendarTableViewCell.h"

@implementation CalendarTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _imageSelfie.layer.cornerRadius = _imageSelfie.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDiary:(EmotionDiary *)diary {
    _savedDiary = diary;
    UIImage *image = [UIImage imageWithData:[Utilities getFileAtPath:SELFIE_PATH withName:diary.selfie]];
    _imageSelfie.image = image ? image : PLACEHOLDER_IMAGE;
    _imageFace.image = [ActionPerformer getFaceImageByEmotion:diary.emotion];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    _labelTime.text = [formatter stringFromDate:diary.createTime];
    [formatter setDateFormat:@"M月d日"];
    _labelDate.text = [formatter stringFromDate:diary.createTime];
    _textDetail.text = diary.shortText;
    _buttonHasImage.hidden = !diary.hasImage;
    _buttonHasTag.hidden = !diary.hasTag;
}

@end
