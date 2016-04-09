//
//  MainViewController.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/8.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSCalendar.h"

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet FSCalendar *calendar;
@property (strong, nonatomic) IBOutlet UITableView *detailTableView;

@property UIImage *currentImage;

@end

