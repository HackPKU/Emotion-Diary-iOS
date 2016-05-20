//
//  UserTableViewCell.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"

@interface UserTableViewCell : UITableViewCell <BEMSimpleLineGraphDelegate, BEMSimpleLineGraphDataSource> {
    NSArray<NSNumber *> *chartData;
}

// Chart cell
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentScope;
@property (strong, nonatomic) IBOutlet BEMSimpleLineGraphView *lineChart;

// User cell
@property (strong, nonatomic) IBOutlet UIImageView *imageIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelName;

// Auto upload cell
@property (strong, nonatomic) IBOutlet UISwitch *switchAutoUpload;

// Unlock cell
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentUnlockType;

- (void)reloadStatData;

@end
