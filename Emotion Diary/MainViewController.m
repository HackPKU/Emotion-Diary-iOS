//
//  MainViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/8.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "MainViewController.h"
#import "MainViewTableViewCell.h"
#import "AssessmentHelper.h"
#import "Emotion_Diary-Swift.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentDate = [NSDate date];
    diaryArray = [EmotionDiary getDiaryOfDay:currentDate];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        [_calendar setScope:FSCalendarScopeMonth animated:YES];
    }else {
        [_calendar setScope:FSCalendarScopeWeek animated:YES];
    }
}

#pragma mark - Calendar methods

- (void)calendar:(FSCalendar *)calendar boundingRectWillChange:(CGRect)bounds animated:(BOOL)animated {
    _calendarHeightConstraint.constant = CGRectGetHeight(bounds);
    [self.view layoutIfNeeded];
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    currentDate = date;
    diaryArray = [EmotionDiary getDiaryOfDay:currentDate];
    [_detailTableView reloadData];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    return [EmotionDiary getDiaryOfDay:date].count;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [EmotionDiary getDiaryOfDay:currentDate].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellDetail" forIndexPath:indexPath];
    cell.labelDate.hidden = (indexPath.row != 0);
    EmotionDiary *diary = diaryArray[indexPath.row];
    cell.imageSelfie.image = [UIImage imageWithContentsOfFile:diary.imageURL];
    NSString *imageName = [AssessmentHelper getFaceNameBySmile:(int)diary.smile];
    cell.imageFace.image = [UIImage imageNamed:[imageName stringByAppendingString:@"-白圈"]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    cell.labelTime.text = [formatter stringFromDate:diary.date];
    [formatter setDateFormat:@"MM-dd"];
    cell.labelDate.text = [formatter stringFromDate:diary.date];
    cell.textDetail.text = diary.content;
    
    // Configure the cell...
    
    return cell;
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
