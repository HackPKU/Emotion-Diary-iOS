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
#import <LocalAuthentication/LocalAuthentication.h>

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    connector = [[FaceConnector alloc] init];
    verificationer = [[FaceConnector alloc] init];
    for (UIButton *button in @[_buttonRecord, _buttonProceed]) {
        button.layer.cornerRadius = 5.0;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    [self setUnlocked:NO];
    hasShownCamera = NO;
    
    // Do any additional setup after loading the view.
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!hasShownCamera) {
        [self animateButtonCamera];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)animateButtonCamera {
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _buttonCamera.alpha = 1.5 - _buttonCamera.alpha;
    } completion:^(BOOL finished) {
        if (hasShownCamera) {
            _buttonCamera.alpha = 1.0;
        }else {
            [self animateButtonCamera];
        }
    }];
}

- (void)setUnlocked:(BOOL)unlocked {
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self updateUIWithUnlocked:unlocked];
        });
    }else {
        [self updateUIWithUnlocked:unlocked];
    }
}

- (void)updateUIWithUnlocked:(BOOL)unlocked {
    hasUnkocked = unlocked;
    for (UIButton *button in @[_buttonRecord, _buttonProceed]) {
        button.enabled = unlocked;
        button.alpha = unlocked ? 1.0 : 0.5;
    }
    _buttonCamera.userInteractionEnabled = !unlocked;
    _labelHint.text = unlocked ? @"解锁成功" : @"自拍解锁";
}

- (IBAction)takePicture:(id)sender {
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
    hasShownCamera = YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    selfie = [info objectForKey:UIImagePickerControllerEditedImage];
    selfie = [Utilities normalizedImage:selfie];
#ifdef DEBUG
    selfie = [UIImage imageNamed:@"MyFace1"];
#endif
    [picker dismissViewControllerAnimated:YES completion:^{
        [self analyzeSelfie:selfie];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        [self showWarning];
    }];
}

- (void)analyzeSelfie:(UIImage *)image {
    [KVNProgress showWithStatus:@"分析中"];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"faceID"] length] == 0) {
        [ActionPerformer registerFaceWithImage:image andBlock:^(ActionPerformerResult result, NSString * _Nullable message, NSObject * _Nullable data) {
            if (result == ActionPerformerResultFail) {
                [KVNProgress showErrorWithStatus:message completion:^{
                    [self showWarning];
                }];
                return;
            }
            [self setUnlocked:YES];
            [KVNProgress showSuccessWithStatus:@"解锁成功"];
        }];
    }else {
        [ActionPerformer verifyFaceWithImage:image andBlock:^(ActionPerformerResult result, NSString * _Nullable message, NSObject * _Nullable data) {
            if (result == ActionPerformerResultFail) {
                [KVNProgress showErrorWithStatus:message completion:^{
                    [self showWarning];
                }];
                return;
            }
            [self setUnlocked:YES];
            [KVNProgress showSuccessWithStatus:@"解锁成功"];
        }];
    }
}

- (void)showWarning {
    UIAlertController *action = [UIAlertController alertControllerWithTitle:@"警告" message:@"您必须通过认证才能使用日记功能" preferredStyle:UIAlertControllerStyleAlert];
    [action addAction:[UIAlertAction actionWithTitle:@"重拍" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePicture:nil];
    }]];
    LAContext *context = [LAContext new];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        [action addAction:[UIAlertAction actionWithTitle:@"Touch ID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"使用 Touch ID 解锁心情日记" reply:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    [self setUnlocked:YES];
                }else {
                    [self performSelectorOnMainThread:@selector(showWarning) withObject:nil waitUntilDone:NO];
                }
            }];
        }]];
    }
    if ([ActionPerformer checkHasLogin]) {
        [action addAction:[UIAlertAction actionWithTitle:@"使用密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // TODO: Unlock with password
        }]];
    }
    [self presentViewController:action animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"record"]) {
        RecordTableViewController *dest = [[[segue destinationViewController] viewControllers] firstObject];
        dest.selfie = selfie;
        dest.faceID = userFaceID;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)unwindToWelcomeView:(UIStoryboardSegue *)segue {
    
}

@end
