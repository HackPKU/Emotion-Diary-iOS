//
//  UserTableViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/3.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "UserTableViewController.h"
#import "UserTableViewCell.h"
#import "ShareTableViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "sys/utsname.h"

@interface UserTableViewController ()

@end

@implementation UserTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserView) name:USER_CHANGED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUploadData) name:UPLOAD_PROGRESS_CHANGED_NOTIFOCATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSyncData) name:SYNC_PROGRESS_CHANGED_NOTIFOCATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshShareData) name:SHARE_STATE_CHANGED_NOTIFOCATION object:nil];
    shareData = [NSMutableArray new];
    [self reloadUserInfo];
    [self refreshShareData];
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return ([ActionPerformer hasLoggedIn] ? 4 : 1) + [[LAContext new] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
            break;
        case 2:
            return 4;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"心情统计";
            break;
        case 1:
            return @"用户设置";
            break;
        case 2:
            return @"软件信息";
            break;
        default:
            return nil;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 200.0;
    }else {
        if ([ActionPerformer hasLoggedIn] && indexPath.section == 1 && indexPath.row == 0) {
            return 80.0;
        }
        return 44.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"stat"];
    }else if (indexPath.section == 1) {
        if ([ActionPerformer hasLoggedIn]) {
            if (indexPath.row == 0) {
                UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"user"];
                cell.labelName.text = [[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME];
                NSString *iconName = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO] objectForKey:@"icon"];
                [cell.imageIcon sd_setImageWithURL:[ActionPerformer getImageURLWithName:iconName type:EmotionDiaryImageTypeIcon] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageProgressiveDownload];
                return cell;
            }else if (indexPath.row == 1) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"share"];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)shareData.count];
                return cell;
            }else if (indexPath.row == 2) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"upload"];
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (long)[[EmotionDiaryManager sharedManager] totalUploadNumber]];
                return cell;
            }else if (indexPath.row == 3) {
                return [tableView dequeueReusableCellWithIdentifier:@"autoUpload"];
            }else if (indexPath.row == 4) {
                return [tableView dequeueReusableCellWithIdentifier:@"unlock"];
            }
        }else {
            if (indexPath.row == 0) {
                return [tableView dequeueReusableCellWithIdentifier:@"noUser"];
            }else if (indexPath.row == 1) {
                return [tableView dequeueReusableCellWithIdentifier:@"unlock"];
            }
        }
    }else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            return [tableView dequeueReusableCellWithIdentifier:@"rate"];
        }else if (indexPath.row == 1) {
            return [tableView dequeueReusableCellWithIdentifier:@"feedback"];
        }else if (indexPath.row == 2) {
            return [tableView dequeueReusableCellWithIdentifier:@"donate"];
        }else if (indexPath.row == 3) {
            return [tableView dequeueReusableCellWithIdentifier:@"about"];
        }
    }
    return [UITableViewCell new];
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

- (void)reloadUserInfo {
    if ([ActionPerformer hasLoggedIn]) {
        [ActionPerformer viewUserWithName:[[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME] andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable dataUserInfo) {
            if (!success) {
                return;
            }
            [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:@{USER_INFO: dataUserInfo}];
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED_NOTIFICATION object:nil];
        }];
    }
}

- (void)refreshUserView {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self refreshSyncData];
}

- (void)refreshUploadData {
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)refreshSyncData {
    UserTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell reloadStatData];
}

- (void)refreshShareData {
    [[EmotionDiaryManager sharedManager] viewShareListWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
        if (!success) {
            return;
        }
        shareData = (NSMutableArray *)data;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        });
    }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", APP_STORE_ID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }else if (indexPath.row == 1) {
            struct utsname systemInfo;
            uname(&systemInfo);
            NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
            MFMailComposeViewController *mail = [MFMailComposeViewController new];
            mail.mailComposeDelegate = self;
            [mail.navigationBar setBarStyle:[UINavigationBar appearance].barStyle];
            [mail.navigationBar setTintColor:[UINavigationBar appearance].tintColor];
            [mail setSubject:@"情绪日记 iOS客户端反馈"];
            [mail setToRecipients:FEEDBACK_EMAIL];
            [mail setMessageBody:[NSString stringWithFormat:@"设备：%@\n系统：iOS %@\n客户端版本：%@", platform, [[UIDevice currentDevice] systemVersion], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] isHTML:NO];
            // TODO: Status Bar 颜色不对
            [self presentViewController:mail animated:YES completion:nil];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"share"]) {
        ShareTableViewController *dest = [segue destinationViewController];
        dest.shareData = shareData;
    }
}

@end
