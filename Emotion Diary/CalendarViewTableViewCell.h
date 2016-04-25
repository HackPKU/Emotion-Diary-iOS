//
//  CalendarViewTableViewCell.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Emotion_Diary-Swift.h"

@interface CalendarViewTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageSelfie;
@property (strong, nonatomic) IBOutlet UIImageView *imageFace;
@property (strong, nonatomic) IBOutlet UITextView *textDetail;
@property (strong, nonatomic) IBOutlet UILabel *labelDate;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;

- (void)setDiary:(EmotionDiary *)diary;

@end
