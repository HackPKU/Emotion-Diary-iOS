//
//  InfoTableViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/10.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "InfoTableViewController.h"
#import "WelcomeViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface InfoTableViewController ()

@end

@implementation InfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageIcon.layer.cornerRadius = _imageIcon.frame.size.width / 2;
    for (UIButton *button in @[_buttonResetFace, _buttonLogout]) {
        button.layer.cornerRadius = 5.0;
    }
    
    // TODO: Edit icon and userinfo function
    
    NSString *iconName = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO] objectForKey:@"icon"];
    NSURL *iconURL = [ActionPerformer getImageURLWithName:iconName type:EmotionDiaryImageTypeIcon];
    for (UIImageView *imageView in @[_imageIcon, _imageIconBlurred]) {
        [imageView sd_setImageWithURL:iconURL placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageProgressiveDownload];
    }
    _labelUserName.text = [[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME];
    
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

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}
*/

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}
*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

- (IBAction)resetFace:(id)sender {
    UIAlertController *action = [UIAlertController alertControllerWithTitle:@"提示" message:@"您将会重拍照片作为面部识别的依据" preferredStyle:UIAlertControllerStyleAlert];
    [action addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入账号密码以验证身份";
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
    }];
    [action addAction:[UIAlertAction actionWithTitle:@"重置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull act) {
        password = action.textFields[0].text;
        if (password.length == 0) {
            [KVNProgress showErrorWithStatus:@"您未输入账号密码" completion:^{
                [self resetFace:nil];
            }];
            return;
        }
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }else {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }]];
    [action addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:action animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selfie = [Utilities normalizedImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [picker dismissViewControllerAnimated:YES completion:^{
        [self resetPersonIDWithSelfie:selfie];
    }];
}

- (void)resetPersonIDWithSelfie:(UIImage *)selfie {
    [KVNProgress showWithStatus:@"面部识别中"];
    NSString *personIDBackup = [[NSUserDefaults standardUserDefaults] objectForKey:PERSON_ID];
    [ActionPerformer registerFaceWithImage:selfie andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
        if (!success) {
            [KVNProgress showErrorWithStatus:message];
            return;
        }
        [ActionPerformer editPersonIDWithPassword:password personID:[[NSUserDefaults standardUserDefaults] objectForKey:PERSON_ID] andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
            if (!success) {
                [[NSUserDefaults standardUserDefaults] setObject:personIDBackup forKey:PERSON_ID];
                [KVNProgress showErrorWithStatus:message];
                return;
            }
            [KVNProgress showSuccessWithStatus:@"面部识别重置成功" completion:^{
                [WelcomeViewController showRookieWarningInViewController:self];
            }];
            [ActionPerformer deletePersonID:personIDBackup WithBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                NSLog(@"Deleted original face in Face++");
            }];
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [KVNProgress showErrorWithStatus:@"您取消了该操作"];
    }];
}

- (IBAction)logout:(id)sender {
    UIAlertController *action = [UIAlertController alertControllerWithTitle:@"提示" message:@"您确定要退出登录吗" preferredStyle:UIAlertControllerStyleAlert];
    [action addAction:[UIAlertAction actionWithTitle:@"登出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [KVNProgress showWithStatus:@"正在退出登录"];
        [ActionPerformer logoutWithBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_ID];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:TOKEN];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_NAME];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_INFO];
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED_NOTIFICATION object:nil];
            // TODO: 本地日记的存留处理
            if (!success) {
                [KVNProgress showErrorWithStatus:message completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else {
                [KVNProgress showSuccessWithStatus:@"退出登陆成功" completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        }];
    }]];
    [action addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:action animated:YES completion:nil];
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
