//
//  LoginViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/5.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _buttonLogin.layer.cornerRadius = 5.0;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancel:) name:REGISTER_COMPLETED_NOTIFOCATION object:nil];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)didEndOnExit:(id)sender {
    if (sender == _textUsername) {
        [_textPassword becomeFirstResponder];
    }else if (sender == _textPassword) {
        [self login:nil];
    }
}

- (IBAction)login:(id)sender {
    NSString *username = _textUsername.text;
    NSString *password = _textPassword.text;
    if (username.length == 0) {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:@"错误" message:@"没有填写用户名" preferredStyle:UIAlertControllerStyleAlert];
        [action addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [_textUsername becomeFirstResponder];
        }]];
        [self presentViewController:action animated:YES completion:nil];
        return;
    }
    if (password.length == 0) {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:@"错误" message:@"没有填写密码" preferredStyle:UIAlertControllerStyleAlert];
        [action addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [_textPassword becomeFirstResponder];
        }]];
        [self presentViewController:action animated:YES completion:nil];
        return;
    }
    [self.view endEditing:YES];
    [KVNProgress showWithStatus:@"登录中"];
    [ActionPerformer loginWithName:username password:password andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable dataLogin) {
        if (!success) {
            [KVNProgress showErrorWithStatus:message];
            return;
        }
        [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:@{USER_ID : dataLogin[@"userid"], TOKEN: dataLogin[@"token"]}];
        [ActionPerformer viewUserWithName:dataLogin[@"name"] andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable dataUserInfo) {
            if (!success) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_ID];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:TOKEN];
                [KVNProgress showErrorWithStatus:message];
                return;
            }
            [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:@{USER_ID : dataLogin[@"userid"], TOKEN: dataLogin[@"token"], USER_NAME: dataLogin[@"name"], USER_INFO: dataUserInfo}];
            NSString *personID = [[NSUserDefaults standardUserDefaults] objectForKey:PERSON_ID];
            if (personID.length == 0) {
                [[NSUserDefaults standardUserDefaults] setObject:dataUserInfo[@"person_id"] forKey:PERSON_ID];
            }
            // TODO: PersonID 与本地不一致时的处理
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED_NOTIFICATION object:nil];
            [KVNProgress showSuccessWithStatus:@"登陆成功" completion:^{
                 // TODO: iPad 上卡死
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:SYNC_INFO];
                [[NSNotificationCenter defaultCenter] postNotificationName:SHOULD_SYNC_NOTIFOCATION object:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
    }];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)unwindToLoginView:(UIStoryboardSegue *)segue {
    
}

@end
