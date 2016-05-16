//
//  ShareTableViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/15.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "ShareTableViewController.h"
#import "DiaryTableViewCell.h"
#import "DiaryTableViewController.h"

@interface ShareTableViewController ()

@end

@implementation ShareTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    showNoDiary = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(_shareData.count, showNoDiary);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _shareData.count > 0 ? @"左划以删除或取消分享" : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return _shareData.count > 0 ? @"取消分享后原链接将失效" : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_shareData.count > 0) {
        DiaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        cell.diary = _shareData[indexPath.row];
        return cell;
    }else {
        return [tableView dequeueReusableCellWithIdentifier:@"noShare"];
    }
    
    // Configure the cell...
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *unshareAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"取消分享" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        EmotionDiary *diary = _shareData[indexPath.row];
        [KVNProgress showWithStatus:@"取消分享中"];
        [diary unshareWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
            if (!success) {
                [KVNProgress showErrorWithStatus:message completion:^{
                    tableView.editing = NO;
                }];
                return;
            }
            [KVNProgress showSuccessWithStatus:@"取消分享成功" completion:^{
                [_shareData removeObjectAtIndex:indexPath.row];
                showNoDiary = NO;
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                showNoDiary = YES;
                [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
                [[NSNotificationCenter defaultCenter] postNotificationName:SHARE_STATE_CHANGED_NOTIFOCATION object:nil];
            }];
        }];
    }];
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        EmotionDiary *diary = _shareData[indexPath.row];
        [KVNProgress showWithStatus:@"删除中"];
        [diary deleteWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
            if (!success) {
                [KVNProgress showErrorWithStatus:message completion:^{
                    tableView.editing = NO;
                }];
                return;
            }
            [KVNProgress showSuccessWithStatus:@"删除成功" completion:^{
                [_shareData removeObjectAtIndex:indexPath.row];
                showNoDiary = NO;
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                showNoDiary = YES;
                [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
                [[NSNotificationCenter defaultCenter] postNotificationName:SHARE_STATE_CHANGED_NOTIFOCATION object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNC_PROGRESS_CHANGED_NOTIFOCATION object:nil userInfo:@{DIARY_ID: [NSNumber numberWithInt:NO_DIARY_ID]}];
            }];
        }];
    }];
    return @[unshareAction, deleteAction];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"diary"]) {
        DiaryTableViewController *dest = [segue destinationViewController];
        dest.navigationItem.rightBarButtonItems = nil;
        dest.navigationItem.leftBarButtonItems = nil; // 变为滑动返回
        dest.diary = ((DiaryTableViewCell *)sender).diary;
    }
}

@end
