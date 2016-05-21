//
//  RegisterViewController.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/6.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TranslucentViewController.h"

@interface RegisterViewController : TranslucentViewController <UITableViewDelegate, UITableViewDataSource>

@property BOOL isEdit;
@property (strong, nonatomic) IBOutlet UITableView *tableRegister;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintBottom;

@end
