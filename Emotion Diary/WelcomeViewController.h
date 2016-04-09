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
    FaceConnector *verificationer;
    BOOL shouldRetakePicture;
    UIImage *selfie;
    NSString *userFaceID;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageSuccess;
@property (strong, nonatomic) IBOutlet UIButton *buttonCamera;
@property (strong, nonatomic) IBOutlet UIButton *buttonProceed;

@end
