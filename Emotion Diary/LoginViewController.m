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
    [self.navigationController setNavigationBarHidden:YES];
    // Translucent navigation bar
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[Utilities createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    
    for (UIView *view in @[_textUsername, _textPassword, _buttonLogin]) {
        view.layer.cornerRadius = 5.0;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardDidHideNotification object:nil];
    
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
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBar.isHidden animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextView *)textView {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
        return;
    }
    if (password.length == 0) {
        return;
    }
    [KVNProgress showWithStatus:@"登录中"];
    [ActionPerformer loginWithName:username password:password andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
        if (!success) {
            [KVNProgress showErrorWithStatus:message];
            return;
        }
        [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:@{USER_ID : data[@"userid"], TOKEN: data[@"token"], USER_NAME: data[@"name"]}];
        [ActionPerformer viewUserWithName:[[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME] andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
            if (!success) {
                [KVNProgress showErrorWithStatus:message];
                return;
            }
            [[NSUserDefaults standardUserDefaults] setValue:data forKey:USER_INFO];
            [[NSNotificationCenter defaultCenter] postNotificationName:USER_CHANGED_NOTIFICATION object:nil];
            [KVNProgress showSuccessWithStatus:@"登陆成功" completion:^{
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

@end
