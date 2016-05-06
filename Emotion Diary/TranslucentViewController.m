//
//  TranslucentViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/6.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "TranslucentViewController.h"

@interface TranslucentViewController ()

@end

@implementation TranslucentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Hide navigation bar
    [self.navigationController setNavigationBarHidden:YES];
    // Translucent view and navigation bar
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.navigationController.navigationBar setBackgroundImage:[Utilities createImageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBar.isHidden animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextView *)textView {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
