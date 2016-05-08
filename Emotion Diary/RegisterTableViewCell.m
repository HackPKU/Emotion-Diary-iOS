//
//  RegisterTableViewCell.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/8.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "RegisterTableViewCell.h"

@implementation RegisterTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // The ClearColor property in interface builder doesn't work on iPad
    self.backgroundColor = [UIColor clearColor];
    _buttonRegister.layer.cornerRadius = 5.0;
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
