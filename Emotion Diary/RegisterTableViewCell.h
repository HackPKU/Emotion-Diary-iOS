//
//  RegisterTableViewCell.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/8.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextField *textContent;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentSex;
@property (strong, nonatomic) IBOutlet UIButton *buttonRegister;

@end
