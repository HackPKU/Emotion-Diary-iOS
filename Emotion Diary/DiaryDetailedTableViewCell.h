//
//  DiaryDetailedTableViewCell.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiaryDetailedTableViewCell : UITableViewCell {
    EmotionDiary *diary;
    NSDateFormatter *formatter;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageSelfie;
@property (strong, nonatomic) IBOutlet UIImageView *imageFace;
@property (strong, nonatomic) IBOutlet UIView *viewContainer;
@property (strong, nonatomic) IBOutlet UITextView *textDetail;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UIButton *buttonHasImage;
@property (strong, nonatomic) IBOutlet UIButton *buttonHasTag;

- (void)setDiary:(EmotionDiary *)newDiary;

- (EmotionDiary *)diary;

@end
