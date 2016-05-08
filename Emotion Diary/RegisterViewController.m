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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
        }else if (indexPath.row == PASSWORD_INDEX) {
            cell.textContent.placeholder = @"密码，至少6位";
        }else if (indexPath.row == PASSWORD_SURE_INDEX) {
            cell.textContent.placeholder = @"重新输入密码";
        }else if (indexPath.row == EMAIL_INDEX) {
            cell.textContent.placeholder = @"邮箱，选填";
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

- (IBAction)register:(id)sender {
    
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
