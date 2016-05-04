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

#define DEBUG_IMAGE [UIImage imageNamed:@"MyFace1"]

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterMain) name:@"enterMain" object:nil];
    for (UIButton *button in @[_buttonRecord, _buttonProceed]) {
        button.layer.cornerRadius = 5.0;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.hidden = _shouldDismissAfterUnlock;
    }
    shouldStopAnimate = NO;
    emotion = NO_EMOTION;
    
#ifdef DEBUG
    [self setUnlocked:YES];
    selfie = DEBUG_IMAGE;
#else
    [self setUnlocked:NO];
    if (_shouldDismissAfterUnlock) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(takePicture:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
#endif
    
    [self performSelector:@selector(animateButtonCamera) withObject:nil afterDelay:0.5];
    
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    shouldStopAnimate = YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)animateButtonCamera {
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _buttonCamera.alpha = 1.5 - _buttonCamera.alpha;
    } completion:^(BOOL finished) {
        if (shouldStopAnimate) {
            _buttonCamera.alpha = 1.0;
        }else {
            [self animateButtonCamera];
        }
    }];
}

- (void)setUnlocked:(BOOL)unlocked {
    hasUnkocked = unlocked;
    for (UIButton *button in @[_buttonRecord, _buttonProceed]) {
        button.enabled = unlocked;
        button.alpha = unlocked ? 1.0 : 0.6;
    }
    _buttonCamera.userInteractionEnabled = !unlocked;
    _labelHint.text = unlocked ? @"解锁成功" : @"自拍解锁";
    if (!unlocked && shouldStopAnimate) {
        shouldStopAnimate = NO;
        [self animateButtonCamera];
    }
    if (unlocked && _shouldDismissAfterUnlock) {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.5];
    }
}

- (IBAction)takePicture:(id)sender {
    if (![[Utilities getCurrentViewController] isKindOfClass:self.class] || hasUnkocked) {
        return;
    }
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
    shouldStopAnimate = YES;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    selfie = [info objectForKey:UIImagePickerControllerEditedImage];
    selfie = [Utilities normalizedImage:selfie];
#ifdef DEBUG
    selfie = DEBUG_IMAGE;
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
    NSString *successMessage;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"faceID"] length] == 0) {
        successMessage = @"人脸注册成功";
    }else {
        successMessage = @"人脸解锁成功";
    }
    ActionPerformerResultBlock block = ^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
        if (!success) {
            [KVNProgress showErrorWithStatus:message completion:^{
                [self showWarning];
            }];
            return;
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setUnlocked:YES];
        });
        emotion = [data[@"emotion"] intValue];
        [KVNProgress showSuccessWithStatus:successMessage];
    };
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"faceID"] length] == 0) {
        [ActionPerformer registerFaceWithImage:image andBlock:block];
    }else {
        [ActionPerformer verifyFaceWithImage:image andBlock:block];
    }
}

- (void)showWarning {
    UIAlertController *action = [UIAlertController alertControllerWithTitle:@"警告" message:@"您必须通过认证才能解锁日记" preferredStyle:UIAlertControllerStyleAlert];
    [action addAction:[UIAlertAction actionWithTitle:@"自拍解锁" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takePicture:nil];
    }]];
    LAContext *context = [LAContext new];
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        [action addAction:[UIAlertAction actionWithTitle:@"Touch ID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"使用 Touch ID 解锁心情日记" reply:^(BOOL success, NSError * _Nullable error) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (success) {
                        [self setUnlocked:YES];
                    }else {
                        [KVNProgress showErrorWithStatus:@"Touch ID 认证失败"];
                        [self setUnlocked:NO];
                    }
                });
            }];
        }]];
    }
    if ([ActionPerformer hasLoggedIn]) {
        [action addAction:[UIAlertAction actionWithTitle:@"使用密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入密码" message:@"使用您的账号密码解锁心情日记" preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"密码";
                textField.secureTextEntry = YES;
            }];
            [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([[Utilities MD5:alert.textFields[0].text] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]]) {
                    [self setUnlocked:YES];
                }else {
                    [KVNProgress showErrorWithStatus:@"密码错误"];
                    [self setUnlocked:NO];
                }
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self setUnlocked:NO];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }]];
    }
    [action addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self setUnlocked:NO];
    }]];
    [self presentViewController:action animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)enterMain {
    [self performSegueWithIdentifier:@"enterMain" sender:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"record"]) {
        RecordTableViewController *dest = [[[segue destinationViewController] viewControllers] firstObject];
        dest.selfie = selfie;
        dest.emotion = emotion;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)unwindToWelcomeView:(UIStoryboardSegue *)segue {
    if ([segue.sourceViewController isKindOfClass:[CalendarViewController class]]) {
        [self setUnlocked:NO];
        [self performSelector:@selector(takePicture:) withObject:nil afterDelay:0.5];
    }
}

@end
