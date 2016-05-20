//
//  MFMailComposeViewController+LightContent.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/20.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "MFMailComposeViewController+LightContent.h"

@implementation MFMailComposeViewController (LightContent)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return nil;
}

@end
