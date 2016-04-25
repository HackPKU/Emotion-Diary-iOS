//
//  CalendarViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/8.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "CalendarViewController.h"
#import "CalendarViewTableViewCell.h"
#import "Emotion_Diary-Swift.h"

@interface CalendarViewController ()

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCalendarScope:self.view.frame.size.height];
    currentDate = [NSDate date];
    diaryArray = [[EmotionDiaryHelper sharedInstance] getDiaryOfDay:currentDate];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self setCalendarScope:size.height];
}

- (void)setCalendarScope:(CGFloat)height {
    if (height >= 400) {
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
    CalendarViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellDetail" forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.labelDate.hidden = (indexPath.row != 0);
    [cell setDiary:diaryArray[indexPath.row]];
    return cell;
}

@end
