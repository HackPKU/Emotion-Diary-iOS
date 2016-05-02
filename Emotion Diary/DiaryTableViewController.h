//
//  DiaryTableViewController.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/2.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiaryTableViewController : UITableViewController

@property EmotionDiary *diary;

@property (strong, nonatomic) IBOutlet UIImageView *imageSelfie;
@property (strong, nonatomic) IBOutlet UILabel *labelDateAndTime;
@property (strong, nonatomic) IBOutlet UILabel *labelEmotion;
@property (strong, nonatomic) IBOutlet UIImageView *imageFace;
@property (strong, nonatomic) IBOutlet UITextView *textDetail;

@end
