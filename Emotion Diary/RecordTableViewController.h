//
//  RecordTableViewController.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIImageView *selfieImage;
@property (strong, nonatomic) IBOutlet UIImageView *blurredSelfieImage;

@property UIImage *selfie;

@end