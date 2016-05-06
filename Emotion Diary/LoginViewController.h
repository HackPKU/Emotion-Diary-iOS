//
//  LoginViewController.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/5.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textUsername;
@property (strong, nonatomic) IBOutlet UITextField *textPassword;
@property (strong, nonatomic) IBOutlet UIButton *buttonLogin;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;

@end
