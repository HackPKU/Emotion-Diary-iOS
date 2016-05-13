//
//  UploadTableViewCell.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/11.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadTableViewCell : UITableViewCell {
    EmotionDiary *diary;
    NSDateFormatter *formatter;
}

@property (strong, nonatomic) IBOutlet UILabel *labelText;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorUploading;
@property (strong, nonatomic) IBOutlet UILabel *labelError;

- (void)setDiary:(EmotionDiary *)newDiary;

@end
