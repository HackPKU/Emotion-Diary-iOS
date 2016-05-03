//
//  CalendarViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/8.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "CalendarViewController.h"
#import "CalendarTableViewCell.h"
#import "DiaryTableViewController.h"

@interface CalendarViewController ()

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCalendarScope:self.view.frame.size.height];
    diariesOfToday = [[EmotionDiaryManager sharedManager] getDiaryOfDate:[NSDate date]];
    
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
    diariesOfToday = [[EmotionDiaryManager sharedManager] getDiaryOfDate:date];
    [_detailTableView reloadData];
    [_detailTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    return [[EmotionDiaryManager sharedManager] getDiaryOfDate:date].count;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(diariesOfToday.count, 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (diariesOfToday.count > 0) {
        return 160.0;
    }else {
        return 60.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (diariesOfToday.count > 0) {
        CalendarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"diary" forIndexPath:indexPath];
        cell.labelDate.hidden = (indexPath.row != 0);
        [cell setDiary:diariesOfToday[indexPath.row]];
        return cell;
    }else {
        return [tableView dequeueReusableCellWithIdentifier:@"noDiary" forIndexPath:indexPath];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"viewDiary"]) {
        DiaryTableViewController *dest = [[[segue destinationViewController] viewControllers] firstObject];
        dest.diary = [((CalendarTableViewCell *)sender).savedDiary fullVersion];
    }
}

- (IBAction)unwindToCalendarView:(UIStoryboardSegue *)segue {

}

@end
