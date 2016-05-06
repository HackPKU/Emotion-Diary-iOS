//
//  DonateViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/6.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "DonateViewController.h"

@interface DonateViewController ()

@end

@implementation DonateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _buttonDonate.layer.cornerRadius = 5.0;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donate:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PAY_URL]];
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
