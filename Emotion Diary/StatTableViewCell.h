//
//  StatTableViewCell.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"

@interface StatTableViewCell : UITableViewCell <BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource>

@property (strong, nonatomic) IBOutlet BEMSimpleLineGraphView *lineChart;
@property (readonly) NSArray *data;

- (void)setData:(NSArray *)data;

@end
