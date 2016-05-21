//
//  DiaryDetailedTableViewCell.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "DiaryDetailedTableViewCell.h"

@implementation DiaryDetailedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _imageSelfie.layer.cornerRadius = _imageSelfie.frame.size.width / 2;
    if (_viewContainer) {
        _viewContainer.layer.cornerRadius = 10.0;
    }
    formatter = [NSDateFormatter new];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDiary:(EmotionDiary *)newDiary {
    if (diary == newDiary) {
        return;
    }
    diary = newDiary;
    if (diary.selfie.length > 0) {
        if (diary.hasOnlineVersion) {
            [_imageSelfie sd_setImageWithURL:[ActionPerformer getImageURLWithName:diary.selfie type:EmotionDiaryImageTypeSelfie] placeholderImage:PLACEHOLDER_IMAGE];
        }else {
            // 后台读取文件 否则 cell 滚动流畅度低下
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage imageWithData:[Utilities getFileAtPath:SELFIE_PATH withName:diary.selfie]];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    _imageSelfie.image = image;
                });
            });
        }
    }else {
        _imageSelfie.image = PLACEHOLDER_IMAGE;
    }
    _imageFace.image = [ActionPerformer getFaceImageByEmotion:diary.emotion];
    
    [formatter setDateFormat:@"HH:mm"];
    _labelTime.text = [formatter stringFromDate:diary.createTime];
    [formatter setDateFormat:@"M月d日"];
    _labelDate.text = [formatter stringFromDate:diary.createTime];
    _textDetail.text = diary.shortText;
    _buttonHasImage.hidden = !diary.hasImage;
    _buttonHasTag.hidden = !diary.hasTag;
}

- (EmotionDiary *)diary {
    return diary;
}

@end
