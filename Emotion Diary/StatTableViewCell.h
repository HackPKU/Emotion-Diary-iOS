//
//  StatTableViewCell.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"

@interface StatTableViewCell : UITableViewCell <BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource> {
    NSArray<NSNumber *> *chartData;
}

@property (strong, nonatomic) IBOutlet BEMSimpleLineGraphView *lineChart;

- (void)setData:(NSArray<NSNumber *> *)data;

@end
