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
    diaryArray = [[EmotionDiaryHelper sharedInstance] getDiaryOfDay:currentDate];
    
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
    currentDate = [self getLocalDate:date];
    diaryArray = [[EmotionDiaryHelper sharedInstance] getDiaryOfDay:currentDate];
    [_detailTableView reloadData];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    return [[EmotionDiaryHelper sharedInstance] getDiaryOfDay:[self getLocalDate:date]].count;
}

- (NSDate *)getLocalDate:(NSDate *)anyDate {
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[EmotionDiaryHelper sharedInstance] getDiaryOfDay:currentDate].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    EmotionDiary *diary = diaryArray[indexPath.row];
    //下句中(CELL_CONTENT_WIDTH - CELL_CONTENT_MARGIN 表示显示内容的label的长度 ，20000.0f 表示允许label的最大高度
    CGSize constraint = CGSizeMake(self.view.frame.size.width - 124 - 10, 20000.0f);
    CGSize size = [diary.content boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    return MAX(size.height, 56.0) + 94.0;
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
