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

+ (void)postWithDictionary:(NSDictionary * _Nullable)dictionary toUrl:(NSString * _Nonnull)url andBlock:(ActionPerformerResultBlock)block {
#ifdef DEBUG
    url = [NSString stringWithFormat:@"http://localhost/~Frank/Emotion-Diary-Web%@", url];
#else
    url = [NSString stringWithFormat:@"http://%@%@", SERVER_URL, url];
#endif
    
    NSMutableDictionary *request = [dictionary mutableCopy];
    request[@"version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    if ([ActionPerformer checkLogin]) {
        request[@"userid"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
        request[@"token"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:request progress:^(NSProgress * _Nonnull uploadProgress) {} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"name"] = name;
    request[@"password"] = [Utilities MD5:password];
    request[@"sex"] = sex;
    request[@"email"] = email;
    request[@"icon"] = icon;
    request[@"type"] = @"ios";
    [ActionPerformer postWithDictionary:request toUrl:@"/api/register.php" andBlock:block];
}

+ (void)loginWithName:(NSString *)name password:(NSString *)password andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"name"] = name;
    request[@"password"] = [Utilities MD5:password];
    request[@"type"] = @"ios";
    [ActionPerformer postWithDictionary:request toUrl:@"/api/login.php" andBlock:block];
}

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"email"] = email;
    request[@"password"] = [Utilities MD5:password];
    request[@"type"] = @"ios";
    [ActionPerformer postWithDictionary:request toUrl:@"/api/login.php" andBlock:block];
}

+ (void)logoutWithBlock:(ActionPerformerResultBlock)block {
    [ActionPerformer postWithDictionary:nil toUrl:@"/api/logout.php" andBlock:block];
}

+ (void)viewUserWithName:(NSString *)name andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"name"] = name;
    [ActionPerformer postWithDictionary:request toUrl:@"/api/view_user.php" andBlock:block];
}

+ (void)editUserWithName:(NSString *)name password:(NSString *)password newPassword:(NSString * _Nullable)newPassword sex:(NSString * _Nullable)sex email:(NSString * _Nullable)email icon:(NSString * _Nullable)icon andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"name"] = name;
    request[@"password"] = [Utilities MD5:password];
    request[@"new_password"] = [Utilities MD5:newPassword];
    request[@"sex"] = sex;
    request[@"email"] = email;
    request[@"icon"] = icon;
    [ActionPerformer postWithDictionary:request toUrl:@"/api/edit_user.php" andBlock:block];
}

+ (void)postDiary:(EmotionDiary *)diary andBlock:(ActionPerformerResultBlock)block {
    if (!diary.hasLocalVersion) {
        block(ActionPerformerResultFail, @"该日记没有本地存档", nil);
        return;
    }
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"emotion"] = [NSString stringWithFormat:@"%d", diary.emotion];
    request[@"selfie"] = diary.selfie;
    request[@"images"] = [diary.images componentsJoinedByString:@" | "];
    request[@"tags"] = [diary.tags componentsJoinedByString:@" | "];
    request[@"text"] = diary.text;
    request[@"place_name"] = diary.placeName;
    request[@"place_long"] = [NSString stringWithFormat:@"%f", diary.placeLong];
    request[@"place_lat"] = [NSString stringWithFormat:@"%f", diary.placeLat];
    request[@"weather"] = diary.weather;
    [ActionPerformer postWithDictionary:request toUrl:@"/api/post_diary.php" andBlock:block];
}

+ (void)viewDiaryWithDiaryID:(int)diaryID shareKey:(NSString * _Nullable)shareKey andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"diaryid"] = [NSString stringWithFormat:@"%d", diaryID];
    request[@"share_key"] = shareKey;
    [ActionPerformer postWithDictionary:request toUrl:@"/api/view_diary.php" andBlock:block];
}

+ (void)syncDiaryWithYear:(int)year month:(int)month andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"year"] = [NSString stringWithFormat:@"%d", year];
    request[@"month"] = [NSString stringWithFormat:@"%d", month];
    [ActionPerformer postWithDictionary:request toUrl:@"/api/sync_diary.php" andBlock:block];
}

+ (void)deleteDiaryWithDiaryID:(int)diaryID andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"diaryid"] = [NSString stringWithFormat:@"%d", diaryID];
    [ActionPerformer postWithDictionary:request toUrl:@"/api/delete_diary.php" andBlock:block];
}

+ (void)shareDiaryWithDiaryID:(int)diaryID andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"diaryid"] = [NSString stringWithFormat:@"%d", diaryID];
    [ActionPerformer postWithDictionary:request toUrl:@"/api/share_diary.php" andBlock:block];
}

+ (void)unshareDiaryWithDiaryID:(int)diaryID andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"diaryid"] = [NSString stringWithFormat:@"%d", diaryID];
    [ActionPerformer postWithDictionary:request toUrl:@"/api/unshare_diary.php" andBlock:block];
}

+ (void)uploadImage:(UIImage *)image type:(EmotionDiaryImageType)type andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    NSData *imageData;
    NSString *imageType;
    switch (type) {
        case EmotionDiaryImageTypeIcon:
            imageData = [Utilities compressImage:image toSize:50];
            imageType = @"icon";
            break;
        case EmotionDiaryImageTypeSelfie:
            imageData = [Utilities compressImage:image toSize:100];
            imageType = @"selfie";
            break;
        case EmotionDiaryImageTypeImage:
            imageData = [Utilities compressImage:image toSize:200];
            imageType = @"image";
            break;
        default:
            block(ActionPerformerResultFail, @"图片类型不正确", nil);
            return;
    }
    request[@"image"] = [imageData base64EncodedStringWithOptions:0];
    request[@"type"] = imageType;
    [ActionPerformer postWithDictionary:request toUrl:@"/api/upload_image.php" andBlock:block];
}

#pragma mark Face++ connection

+ (void)processFaceppResult:(FaceppResult * _Nonnull)result detailed:(BOOL)detailed andBlock:(ActionPerformerResultBlock)block {
    if (result.success) {
        block(ActionPerformerResultSuccess, nil, result.content);
    }else {
        NSString *errorMessage = [NSString stringWithFormat:@"%d - %@", result.error.errorCode, result.error.message];
        if (detailed) {
            block(ActionPerformerResultFail, errorMessage, nil);
        }else {
#ifdef DEBUG
            block(ActionPerformerResultFail, errorMessage, nil);
#else
            block(ActionPerformerResultFail, @"网络连接错误", nil);
#endif
        }
    }
}

+ (void)registerFaceWithImage:(UIImage *)image name:(NSString *)name andBlock:(ActionPerformerResultBlock)block {
    FaceppResult *detectResult = [[FaceppAPI detection] detectWithURL:nil orImageData:[Utilities compressImage:image toSize:200] mode:FaceppDetectionModeOneFace];
    [ActionPerformer processFaceppResult:detectResult detailed:NO andBlock:^(ActionPerformerResult result, NSString * _Nullable message, NSObject * _Nullable data) {
        if (result == ActionPerformerResultFail) {
            [ActionPerformer processFaceppResult:detectResult detailed:NO andBlock:block];
            return;
        }
        NSDictionary *dictDetect = (NSDictionary *)data;
#ifdef DEBUG
        NSString *groupName = @"EmotionDiaryTest";
#else
        NSString *groupName = @"EmotionDiary";
#endif
        FaceppResult *registerResult = [[FaceppAPI person] createWithPersonName:name andFaceId:@[dictDetect[@"face"][0][@"face_id"]] andTag:@"iOS" andGroupId:nil orGroupName:@[groupName]];
        [ActionPerformer processFaceppResult:registerResult detailed:YES andBlock:^(ActionPerformerResult result, NSString * _Nullable message, NSObject * _Nullable data) {
            if (result == ActionPerformerResultFail) {
                if ([message intValue] == 1503) {
                    block(ActionPerformerResultFail, @"名称已被使用", nil);
                }else {
                    [ActionPerformer processFaceppResult:detectResult detailed:NO andBlock:block];
                }
                return;
            }
            NSDictionary *dictCreate = (NSDictionary *)data;
            [[NSUserDefaults standardUserDefaults] setObject:dictCreate[@"person_id"] forKey:@"faceID"]; // Sace faceID in local storage
            block(ActionPerformerResultSuccess, nil, @{@"emotion": dictDetect[@"face"][0][@"attribute"][@"smiling"], @"faceid": dictCreate[@"person_id"]});
        }];
    }];
}

+ (void)verifyFaceWithImage:(UIImage *)image andBlock:(ActionPerformerResultBlock)block {
    FaceppResult *detectResult = [[FaceppAPI detection] detectWithURL:nil orImageData:[Utilities compressImage:image toSize:200] mode:FaceppDetectionModeOneFace];
    [ActionPerformer processFaceppResult:detectResult detailed:NO andBlock:^(ActionPerformerResult result, NSString * _Nullable message, NSObject * _Nullable data) {
        if (result == ActionPerformerResultFail) {
            [ActionPerformer processFaceppResult:detectResult detailed:NO andBlock:block];
            return;
        }
    }];
}

#pragma mark Local functions

+ (BOOL)checkLogin {
    return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] length] > 0 && [[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] length] > 0);
}

@end
