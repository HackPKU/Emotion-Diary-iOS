//
//  RegisterViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/6.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegisterTableViewCell.h"

#define USER_NAME_INDEX 0
#define PASSWORD_INDEX 1
#define PASSWORD_SURE_INDEX 2
#define EMAIL_INDEX 3
#define SEX_INDEX 4

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableRegister addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView:)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapTableView:(UIGestureRecognizer *)sender {
    [super touchesBegan:[NSSet setWithObject:[UITouch new]] withEvent:nil];
}

- (void)keyboardChange:(NSNotification *)noti {
    CGRect keyboardBounds = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect viewFrame = [self.navigationController.view convertRect:self.navigationController.view.frame toView:[UIApplication sharedApplication].keyWindow]; // 获取在整个软件窗口的绝对坐标
    CGFloat constant = (viewFrame.size.height + viewFrame.origin.y) - keyboardBounds.origin.y;
    if (constant > 0 && viewFrame.origin.y < keyboardBounds.origin.y) {
        _constraintBottom.constant = constant;
    }else {
        _constraintBottom.constant = 0;
    }
    NSValue *animationDurationValue = [[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 100.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == USER_NAME_INDEX || indexPath.row == PASSWORD_INDEX || indexPath.row == PASSWORD_SURE_INDEX || indexPath.row == EMAIL_INDEX) {
        RegisterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
        cell.textContent.delegate = self;
        if (indexPath.row == USER_NAME_INDEX){
            cell.textContent.placeholder = @"用户名，中英文均可";
            cell.textContent.secureTextEntry = NO;
            cell.textContent.keyboardType = UIKeyboardTypeDefault;
        }else if (indexPath.row == PASSWORD_INDEX) {
            cell.textContent.placeholder = @"密码，至少6位";
            cell.textContent.secureTextEntry = YES;
            cell.textContent.keyboardType = UIKeyboardTypeASCIICapable;
        }else if (indexPath.row == PASSWORD_SURE_INDEX) {
            cell.textContent.placeholder = @"重新输入密码";
            cell.textContent.secureTextEntry = YES;
            cell.textContent.keyboardType = UIKeyboardTypeASCIICapable;
        }else if (indexPath.row == EMAIL_INDEX) {
            cell.textContent.placeholder = @"邮箱，选填，找回密码时使用";
            cell.textContent.secureTextEntry = NO;
            cell.textContent.keyboardType = UIKeyboardTypeEmailAddress;
        }
        return cell;
    }else if (indexPath.row == SEX_INDEX) {
        return [tableView dequeueReusableCellWithIdentifier:@"sex" forIndexPath:indexPath];
    }else {
        return [tableView dequeueReusableCellWithIdentifier:@"register" forIndexPath:indexPath];
    }
}

- (id _Nullable)getContentAtIndex:(NSInteger)index {
    RegisterTableViewCell *cell = [_tableRegister cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if (cell.textContent != nil) {
        return cell.textContent;
    }
    if (cell.segmentSex != nil) {
        return cell.segmentSex;
    }
    return nil;
}

- (IBAction)didEndOnExit:(id)sender {
    if (sender == [self getContentAtIndex:USER_NAME_INDEX]) {
        [[self getContentAtIndex:PASSWORD_INDEX] becomeFirstResponder];
    }else if (sender == [self getContentAtIndex:PASSWORD_INDEX]) {
        [[self getContentAtIndex:PASSWORD_SURE_INDEX] becomeFirstResponder];
    }else if (sender == [self getContentAtIndex:PASSWORD_SURE_INDEX]) {
        [[self getContentAtIndex:EMAIL_INDEX] becomeFirstResponder];
    }
}

- (IBAction)register:(id)sender {
    NSString *name = ((UITextField *)[self getContentAtIndex:USER_NAME_INDEX]).text;
    NSString *password = ((UITextField *)[self getContentAtIndex:PASSWORD_INDEX]).text;
    NSString *passwordSure = ((UITextField *)[self getContentAtIndex:PASSWORD_SURE_INDEX]).text;
    NSString *email = ((UITextField *)[self getContentAtIndex:EMAIL_INDEX]).text;
    NSString *sex = ((UISegmentedControl *)[self getContentAtIndex:SEX_INDEX]).selectedSegmentIndex == 0 ? nil : ((UISegmentedControl *)[self getContentAtIndex:SEX_INDEX]).selectedSegmentIndex == 1 ? @"male" : @"female";
    
    NSString *errorMessage = nil;
    UIView *firstResponder = nil;
    if (name.length == 0) {
        errorMessage = @"没有填写用户名";
        firstResponder = [self getContentAtIndex:USER_NAME_INDEX];
    }else if (password.length == 0) {
        errorMessage = @"没有填写密码";
        firstResponder = [self getContentAtIndex:PASSWORD_INDEX];
    }else if (password.length < 6) {
        errorMessage = @"密码长度过短";
        firstResponder = [self getContentAtIndex:PASSWORD_INDEX];
    }else if (![passwordSure isEqualToString:password]) {
        errorMessage = @"两次密码填写不一致";
        firstResponder = [self getContentAtIndex:PASSWORD_SURE_INDEX];
    }else if (email.length > 0 && ![Utilities isValidateEmail:email]) {
        errorMessage = @"邮箱格式不正确";
        firstResponder = [self getContentAtIndex:EMAIL_INDEX];
    }
    if (errorMessage) {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:@"错误" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        [action addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [firstResponder becomeFirstResponder];
        }]];
        [self presentViewController:action animated:YES completion:nil];
        return;
    }
    [KVNProgress showWithStatus:@"注册中"];
    [ActionPerformer registerWithName:name password:password sex:sex email:email icon:nil andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
        if (!success) {
            [KVNProgress showErrorWithStatus:message];
            return;
        }
        [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:@{USER_ID: data[@"userid"], TOKEN: data[@"token"], USER_NAME: name, USER_INFO:@{@"sex": sex, @"email": email}}];
        [KVNProgress showSuccessWithStatus:@"注册成功" completion:^{
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:REGISTER_COMPLETED_NOTIFOCATION object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOGIN_COMPLETED_NOTIFICATION object:nil];
            }];
        }];
    }];
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
