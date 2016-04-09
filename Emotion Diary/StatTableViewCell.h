//
//  StatTableViewCell.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSLineChart.h"

@interface StatTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet FSLineChart *lineChart;

- (void)setData;

@end