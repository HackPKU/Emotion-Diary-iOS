//
//  ActionPerformer.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/27.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "ActionPerformer.h"
#import "AFNetworking.h"
#import "FaceppAPI.h"

@implementation ActionPerformer

#pragma mark Server connection

+ (void)performActionWithDictionary:(NSDictionary * _Nullable)dictionary toUrl:(NSString * _Nonnull)url andBlock:(ActionPerformerResultBlock)block {
#ifdef DEBUG
    url = [NSString stringWithFormat:@"http://localhost/~Frank/Emotion-Diary-Web%@", url];
#else
    url = [NSString stringWithFormat:@"http://%@%@", SERVER_URL, url];
#endif
    
    NSMutableDictionary *requestDictionary = [dictionary mutableCopy];
    requestDictionary[@"version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if ([ActionPerformer checkLogin]) {
        requestDictionary[@"userid"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
        requestDictionary[@"token"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:requestDictionary progress:^(NSProgress * _Nonnull uploadProgress) {} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        if ([responseDictionary[@"code"] intValue] != 0) {
            block(ActionPerformerResultFail, responseDictionary[@"message"], nil);
        }else {
            block(ActionPerformerResultSuccess, nil, responseDictionary[@"data"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef DEBUG
        block(ActionPerformerResultFail, error.localizedDescription, nil);
#else
        block(ActionPerformerResultFail, @"网络连接错误", nil);
#endif
    }];
}

+ (void)registerWithName:(NSString *)name password:(NSString *)password sex:(NSString * _Nullable)sex email:(NSString * _Nullable)email icon:(NSString * _Nullable)icon andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    requestDictionary[@"name"] = name;
    requestDictionary[@"password"] = [Utilities MD5:password];
    requestDictionary[@"sex"] = sex;
    requestDictionary[@"email"] = email;
    requestDictionary[@"icon"] = icon;
    requestDictionary[@"type"] = @"ios";
    [ActionPerformer performActionWithDictionary:requestDictionary toUrl:@"/api/register.php" andBlock:block];
}

+ (void)loginWithName:(NSString *)name password:(NSString *)password andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    requestDictionary[@"name"] = name;
    requestDictionary[@"password"] = [Utilities MD5:password];
    requestDictionary[@"type"] = @"ios";
    [ActionPerformer performActionWithDictionary:requestDictionary toUrl:@"/api/login.php" andBlock:block];
}

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    requestDictionary[@"email"] = email;
    requestDictionary[@"password"] = [Utilities MD5:password];
    requestDictionary[@"type"] = @"ios";
    [ActionPerformer performActionWithDictionary:requestDictionary toUrl:@"/api/login.php" andBlock:block];
}

+ (void)logoutWithBlock:(ActionPerformerResultBlock)block {
    [ActionPerformer performActionWithDictionary:nil toUrl:@"/api/logout.php" andBlock:block];
}

+ (void)viewUserWithName:(NSString *)name andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    requestDictionary[@"name"] = name;
    [ActionPerformer performActionWithDictionary:requestDictionary toUrl:@"/api/view_user.php" andBlock:block];
}

+ (void)editUserWithName:(NSString *)name password:(NSString *)password newPassword:(NSString * _Nullable)newPassword sex:(NSString * _Nullable)sex email:(NSString * _Nullable)email icon:(NSString * _Nullable)icon andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    requestDictionary[@"name"] = name;
    requestDictionary[@"password"] = [Utilities MD5:password];
    requestDictionary[@"new_password"] = [Utilities MD5:newPassword];
    requestDictionary[@"sex"] = sex;
    requestDictionary[@"email"] = email;
    requestDictionary[@"icon"] = icon;
    [ActionPerformer performActionWithDictionary:requestDictionary toUrl:@"/api/edit_user.php" andBlock:block];
}

+ (void)postDiary:(EmotionDiary *)diary andBlock:(ActionPerformerResultBlock)block {
    if (!diary.hasLocalVersion) {
        block(ActionPerformerResultFail, @"该日记没有本地存档", nil);
        return;
    }
    NSMutableDictionary *requestDictionary = [[NSMutableDictionary alloc] init];
    requestDictionary[@"emotion"] = [NSString stringWithFormat:@"%d", diary.emotion];
    requestDictionary[@"selfie"] = diary.selfie;
    requestDictionary[@"images"] = [diary.images componentsJoinedByString:@" | "];
    requestDictionary[@"tags"] = [diary.tags componentsJoinedByString:@" | "];
    requestDictionary[@"text"] = diary.text;
    requestDictionary[@"place_name"] = diary.placeName;
    requestDictionary[@"place_long"] = [NSString stringWithFormat:@"%f", diary.placeLong];
    requestDictionary[@"place_lat"] = [NSString stringWithFormat:@"%f", diary.placeLat];
    requestDictionary[@"weather"] = diary.weather;
    [ActionPerformer performActionWithDictionary:requestDictionary toUrl:@"/api/post_diary.php" andBlock:block];
}

#pragma mark Face++ connection

#pragma mark Local functions

+ (BOOL)checkLogin {
    return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] length] > 0 && [[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] length] > 0);
}

@end
