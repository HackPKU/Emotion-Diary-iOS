//
//  CalendarViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/8.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "CalendarViewController.h"
#import "DiaryDetailedTableViewCell.h"
#import "DiaryTableViewController.h"

@interface CalendarViewController ()

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCalendarScope:[NSNumber numberWithFloat:self.view.frame.size.height]];
    diariesOfToday = [[EmotionDiaryManager sharedManager] getDiaryOfDate:[NSDate date]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:UPLOAD_PROGRESS_CHANGED_NOTIFOCATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:SYNC_PROGRESS_CHANGED_NOTIFOCATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncCurrentDate) name:SHOULD_SYNC_NOTIFOCATION object:nil];
    [self syncCurrentDate];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self performSelector:@selector(setCalendarScope:) withObject:[NSNumber numberWithFloat:size.height] afterDelay:[coordinator transitionDuration]];
}

- (void)setCalendarScope:(NSNumber *)height {
    if ([height floatValue] >= 500) {
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

- (void)calendarCurrentPageDidChange:(FSCalendar *)calendar {
    [self sync:[calendar.currentPage dateByAddingTimeInterval:24 * 3600]];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    return [[EmotionDiaryManager sharedManager] getDiaryOfDate:date].count;
}

#pragma mark - Sync functions

- (void)refresh:(NSNotification *)noti {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL shouldRefreshDiaryOfToday = NO;
        int diaryID = [noti.userInfo[DIARY_ID] intValue];
        if (diaryID != NO_DIARY_ID) {
            for (EmotionDiary *diary in diariesOfToday) {
                if (diary.diaryID == diaryID || diary.diaryID == NO_DIARY_ID) {
                    shouldRefreshDiaryOfToday = YES;
                    break;
                }
            }
        }else {
            shouldRefreshDiaryOfToday = YES;
        }
        if (shouldRefreshDiaryOfToday) {
            diariesOfToday = [[EmotionDiaryManager sharedManager] getDiaryOfDate:_calendar.selectedDate ? _calendar.selectedDate : [NSDate date]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [_detailTableView reloadData];
                if ([noti.name isEqualToString:SYNC_PROGRESS_CHANGED_NOTIFOCATION]) {
                    [_calendar reloadData];
                }
            });
        }
    });
}

- (void)syncCurrentDate {
    [self sync:[NSDate date]];
}

- (void)sync:(NSDate *)date {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![ActionPerformer hasLoggedIn]) {
            return;
        }
        NSInteger year, month;
        [[NSCalendar currentCalendar] getEra:nil year:&year month:&month day:nil fromDate:date];
        [[EmotionDiaryManager sharedManager] syncDiaryOfYear:year month:month forced:NO fromServerWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
            if (success) {
                NSLog(@"Synced diary of %ld.%ld", (long)year, (long)month);
            }
        }];
    });
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
        DiaryDetailedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"diary" forIndexPath:indexPath];
        cell.labelDate.hidden = (indexPath.row != 0);
        cell.diary = diariesOfToday[indexPath.row];
        return cell;
    }else {
        return [tableView dequeueReusableCellWithIdentifier:@"noDiary" forIndexPath:indexPath];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (diariesOfToday.count > 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [UIView animateWithDuration:0.1 animations:^{
            cell.alpha = 0.6;
        }];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (diariesOfToday.count > 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [UIView animateWithDuration:0.1 animations:^{
            cell.alpha = 1.0;
        }];
    }
}

# pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"viewDiary"]) {
        DiaryTableViewController *dest = [[[segue destinationViewController] viewControllers] firstObject];
        dest.diary = ((DiaryDetailedTableViewCell *)sender).diary;
    }
}

- (IBAction)unwindToCalendarView:(UIStoryboardSegue *)segue {

}

@end
