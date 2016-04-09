//
//  WelcomeViewController.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Emotion_Diary-Swift.h"

@interface WelcomeViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    FaceConnector *connector;
    BOOL shouldClearSelfie;
    UIImage *selfie;
}

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet UIView *textContainerView;
@property (strong, nonatomic) IBOutlet UIButton *buttonCamera;

@end