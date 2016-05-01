//
//  RecordCollectionViewCell.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/30.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "RecordCollectionViewCell.h"

@implementation RecordCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _buttonDelete.layer.cornerRadius = _buttonDelete.bounds.size.width / 2;
}

@end
