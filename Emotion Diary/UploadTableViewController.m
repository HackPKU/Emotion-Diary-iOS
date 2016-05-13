//
//  UploadTableViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/11.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "UploadTableViewController.h"
#import "UploadTableViewCell.h"

@interface UploadTableViewController ()

@end

@implementation UploadTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX([[EmotionDiaryManager sharedManager] totalUploadNumber], 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[EmotionDiaryManager sharedManager] totalUploadNumber] == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"noUpload" forIndexPath:indexPath];
    }
    UploadTableViewCell *cell;
    NSDictionary *dict = [[EmotionDiaryManager sharedManager] getUploadDataOfIndex:indexPath.row];
    if ([dict[@"state"] isKindOfClass:[NSString class]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"error" forIndexPath:indexPath];
        cell.labelError.text = dict[@"state"];
    }else {
        if ([dict[@"state"] isEqual:UPLOAD_STATE_SYNCING]) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"uploading" forIndexPath:indexPath];
        }else if ([dict[@"state"] isEqual:UPLOAD_STATE_WAITING]){
            cell = [tableView dequeueReusableCellWithIdentifier:@"waiting" forIndexPath:indexPath];
        }
    }
    [cell setDiary:dict[@"diary"]];
    
    // Configure the cell...
    
    return cell;
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

- (IBAction)stop:(id)sender {
    [[EmotionDiaryManager sharedManager] stopUploading];
}

- (IBAction)upload:(id)sender {
    [[EmotionDiaryManager sharedManager] startUploading];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
