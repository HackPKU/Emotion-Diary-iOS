//
//  RegisterViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/6.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "RegisterViewController.h"
#import "RegisterTableViewCell.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_tableRegister addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView:)]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapTableView:(UIGestureRecognizer *)sender {
    [super touchesBegan:[NSSet setWithObject:[UITouch new]] withEvent:nil];
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
    return 120.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4) {
        RegisterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"text" forIndexPath:indexPath];
        cell.textContent.delegate = self;
        if (indexPath.row == 0){
            cell.textContent.placeholder = @"用户名，中英文均可";
        }else if (indexPath.row == 1) {
            cell.textContent.placeholder = @"密码，至少6位";
        }else if (indexPath.row == 2) {
            cell.textContent.placeholder = @"重新输入密码";
        }else if (indexPath.row == 3) {
            cell.textContent.placeholder = @"邮箱，选填";
        }
        return cell;
    }else if (indexPath.row == 4) {
        return [tableView dequeueReusableCellWithIdentifier:@"sex" forIndexPath:indexPath];
    }else {
        return [tableView dequeueReusableCellWithIdentifier:@"register" forIndexPath:indexPath];
    }
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
