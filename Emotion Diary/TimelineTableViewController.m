//
//  TimelineTableViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/2.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "TimelineTableViewController.h"
#import "CalendarTableViewCell.h"
#import "DiaryTableViewController.h"

@interface TimelineTableViewController ()

@end

@implementation TimelineTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    totalNumber = [[EmotionDiaryManager sharedManager] totalDiaryNumber];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:UPLOAD_PROGRESS_CHANGED_NOTIFOCATION object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
    totalNumber = [[EmotionDiaryManager sharedManager] totalDiaryNumber];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(totalNumber, 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (totalNumber > 0) {
        return 150.0;
    }else {
        return 100.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (totalNumber > 0) {
        CalendarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"diary" forIndexPath:indexPath];
        cell.diary = [[EmotionDiaryManager sharedManager] getDiaryOfIndex:indexPath.row];
        return cell;
    }else {
        return [tableView dequeueReusableCellWithIdentifier:@"noDiary" forIndexPath:indexPath];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (totalNumber > 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [UIView animateWithDuration:0.1 animations:^{
            cell.alpha = 0.6;
        }];
    }
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (totalNumber > 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [UIView animateWithDuration:0.1 animations:^{
            cell.alpha = 1.0;
        }];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (IBAction)search:(id)sender {
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"viewDiary"]) {
        DiaryTableViewController *dest = [[[segue destinationViewController] viewControllers] firstObject];
        dest.diary = ((CalendarTableViewCell *)sender).diary;
    }
}

@end
