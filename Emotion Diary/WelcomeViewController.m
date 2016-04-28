//
//  WelcomeViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "WelcomeViewController.h"
#import "CalendarViewController.h"
#import "RecordTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    connector = [[FaceConnector alloc] init];
    verificationer = [[FaceConnector alloc] init];
    shouldRetakePicture = YES;
    _labelSuccess.hidden = YES;
    _buttonCamera.layer.cornerRadius = 5.0;
    _buttonCamera.layer.borderWidth = 1.0;
    _buttonCamera.layer.borderColor = [UIColor whiteColor].CGColor;
    _buttonProceed.layer.cornerRadius = 5.0;
    _buttonProceed.layer.borderWidth = 1.0;
    _buttonProceed.layer.borderColor = [UIColor whiteColor].CGColor;
    // Do any additional setup after loading the view.

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self takePicture];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)takePicture {
    if (shouldRetakePicture) {
        _labelSuccess.hidden = YES;
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }else {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        [self presentViewController:imagePicker animated:YES completion:nil];
        shouldRetakePicture = NO;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [KVNProgress showWithStatus:@"分析中"];
    selfie = [info objectForKey:UIImagePickerControllerEditedImage];
    selfie = [Utilities normalizedImage:selfie];
    selfie = [Utilities resizeImage:selfie toSize:CGSizeMake(800, 800 / selfie.size.width * selfie.size.height)];
//    [KVNProgress showSuccess];
    [connector postImage:selfie block:^(enum FaceConnectorRequestResult result, NSString * _Nonnull message, NSString * _Nullable faceID) {
        if (result == FaceConnectorRequestResultError) {
            [KVNProgress showErrorWithStatus:message];
            shouldRetakePicture = YES;
        }else {
            if (verificationer.personID.length == 0) {
                [verificationer createPersonWithName:@"一个好名字" faceIDs:@[faceID] andBlock:^(enum FaceConnectorRequestResult result, NSString * _Nonnull message) {
                    if (result == FaceConnectorRequestResultError) {
                        [KVNProgress showErrorWithStatus:message];
                        shouldRetakePicture = YES;
                    }else {
                        [KVNProgress showSuccessWithStatus:@"创建成功"];
                        userFaceID = faceID;
                        _labelSuccess.hidden = NO;
                    }
                    [self takePicture];
                }];
            }else {
                [verificationer verificateFaceID:faceID andBlock:^(enum FaceConnectorRequestResult result, NSString * _Nonnull message, BOOL isOwner) {
                    if (result == FaceConnectorRequestResultError) {
                        [KVNProgress showErrorWithStatus:message];
                        shouldRetakePicture = YES;
                    }else {
                        if (!isOwner) {
                            [KVNProgress showErrorWithStatus:@"验证失败"];
                            shouldRetakePicture = YES;
                        }else {
                            [KVNProgress dismiss];
                            userFaceID = faceID;
                            _labelSuccess.hidden = NO;
                        }
                    }
                    [self takePicture];
                }];
            }
        }
        [self takePicture];
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        UIAlertController *action = [UIAlertController alertControllerWithTitle:@"警告" message:@"您必须通过人脸识别才能使用日记功能" preferredStyle:UIAlertControllerStyleAlert];
        [action addAction:[UIAlertAction actionWithTitle:@"重拍" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            shouldRetakePicture = YES;
            [self takePicture];
        }]];
        [self presentViewController:action animated:YES completion:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"recordMood"]) {
        RecordTableViewController *dest = [[[segue destinationViewController] viewControllers] firstObject];
        dest.selfie = selfie;
        dest.faceID = userFaceID;
    }
    shouldRetakePicture = YES;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)unwindToWelcomeView:(UIStoryboardSegue *)segue {
    
}

@end
