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
#import "UserTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <LocalAuthentication/LocalAuthentication.h>

#ifdef DEBUG
#define DEBUG_IMAGE [UIImage imageNamed:@"MyFace1"]
#endif

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterMain) name:ENTER_MAIN_VIEW_NOTIFICATION object:nil];
    for (UIButton *button in @[_buttonRecord, _buttonProceed]) {
        button.layer.cornerRadius = 5.0;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.hidden = _shouldDismissAfterUnlock;
    }
    shouldStopAnimate = NO;
    emotion = NO_EMOTION;
        
#ifdef DEBUG_IMAGE
    [self setUnlocked:YES];
    selfie = DEBUG_IMAGE;
#else
    [self setUnlocked:NO];
    if (_shouldDismissAfterUnlock) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(directUnlock) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
#endif
    
    [self performSelector:@selector(animateButtonUnlock) withObject:nil afterDelay:0.5];
    
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:PERSON_ID] length] == 0 && ![ActionPerformer hasLoggedIn]) {
        // TODO: 引导界面
        
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    shouldStopAnimate = YES;
}

- (void)animateButtonUnlock {
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _buttonUnlock.alpha = 1.5 - _buttonUnlock.alpha;
    } completion:^(BOOL finished) {
        if (shouldStopAnimate) {
            _buttonUnlock.alpha = 1.0;
        }else {
            [self animateButtonUnlock];
        }
    }];
}

- (void)setUnlocked:(BOOL)unlocked {
    hasUnkocked = unlocked;
    for (UIButton *button in @[_buttonRecord, _buttonProceed]) {
        button.enabled = unlocked;
        button.alpha = unlocked ? 1.0 : 0.6;
    }
    _buttonUnlock.userInteractionEnabled = !unlocked;
    _labelHint.text = unlocked ? @"解锁成功" : @"自拍解锁";
    if (!unlocked && shouldStopAnimate) {
        shouldStopAnimate = NO;
        [self animateButtonUnlock];
    }
    if (unlocked && _shouldDismissAfterUnlock) {
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:0.5];
    }
}

- (void)directUnlock {
    if ([[Utilities getCurrentViewController] isKindOfClass:self.class] && !hasUnkocked) {
        [self unlock:nil];
    }
}

- (IBAction)unlock:(id)sender {
    switch ([[[NSUserDefaults standardUserDefaults] objectForKey:UNLOCK_TYPE] integerValue]) {
        case EmotionDiaryUnlockTypeSelfie:
            [self unlockWithSelfie];
            break;
        case EmotionDiaryUnlockTypeTouchID:
            [self unlockWithTouchID];
            break;
        default:
            [self unlockWithSelfie];
            break;
    }
    shouldStopAnimate = YES;
}

- (void)showWarning {
    UIAlertController *action = [UIAlertController alertControllerWithTitle:@"抱歉" message:@"您必须通过认证才能解锁日记" preferredStyle:UIAlertControllerStyleAlert];
    [action addAction:[UIAlertAction actionWithTitle:@"自拍解锁" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self unlockWithSelfie];
    }]];
    if ([[LAContext new] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
        [action addAction:[UIAlertAction actionWithTitle:@"Touch ID" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self unlockWithTouchID];
        }]];
    }
    if ([ActionPerformer hasLoggedIn]) {
        [action addAction:[UIAlertAction actionWithTitle:@"使用密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self unlockWithPassword];
        }]];
    }
    [action addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self setUnlocked:NO];
    }]];
    [self presentViewController:action animated:YES completion:nil];
}

- (void)unlockWithSelfie {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    selfie = [Utilities normalizedImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
#ifdef DEBUG_IMAGE
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
    [KVNProgress showWithStatus:@"面部识别中"];
    BOOL isRegister = ([[[NSUserDefaults standardUserDefaults] objectForKey:PERSON_ID] length] == 0);
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
        if (isRegister) {
            // TODO: 登录了但没有personID时提示
            [KVNProgress showSuccessWithStatus:@"人脸注册成功" completion:^{
                [WelcomeViewController showRookieWarningInViewController:self];
            }];
        }else {
            [KVNProgress showSuccessWithStatus:@"人脸解锁成功"];
        }
    };
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:PERSON_ID] length] == 0) {
        [ActionPerformer registerFaceWithImage:image andBlock:block];
    }else {
        [ActionPerformer verifyFaceWithImage:image andBlock:block];
    }
}

+ (void)showRookieWarningInViewController:(UIViewController *)vc {
    UIAlertController *action = [UIAlertController alertControllerWithTitle:@"提示" message:@"最初几次使用时，面部识别较为严格，请尽量使用清晰、明亮的照片" preferredStyle:UIAlertControllerStyleAlert];
    [action addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:nil]];
    [vc presentViewController:action animated:YES completion:nil];
}

- (void)unlockWithTouchID {
    [[LAContext new] evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"使用 Touch ID 解锁情绪日记" reply:^(BOOL success, NSError * _Nullable error) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (success) {
                [self setUnlocked:YES];
            }else {
                [KVNProgress showErrorWithStatus:@"Touch ID 认证失败" completion:^{
                    [self showWarning];
                }];
                [self setUnlocked:NO];
                hasUnkocked = YES; // 暂时设置此变量以防止自动自拍
            }
        });
    }];
}

- (void)unlockWithPassword {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"输入密码" message:@"使用您的账号密码解锁情绪日记" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"密码";
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeASCIICapable;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [KVNProgress showWithStatus:@"验证中"];
        [ActionPerformer loginWithName:[[NSUserDefaults standardUserDefaults] objectForKey:USER_NAME] password:alert.textFields[0].text andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
            if (success) {
                [KVNProgress showSuccessWithStatus:@"密码验证成功"];
                [self setUnlocked:YES];
            }else {
                [KVNProgress showErrorWithStatus:message completion:^{
                    [self showWarning];
                }];
                [self setUnlocked:NO];
            }
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self setUnlocked:NO];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
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
        selfie = nil;
        emotion = NO_EMOTION;
        [self setUnlocked:NO];
        shouldStopAnimate = YES;
        [self performSelector:@selector(unlockWithSelfie) withObject:nil afterDelay:0.5];
    }
}

@end
