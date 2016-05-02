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

#pragma mark - Server connection

+ (void)postWithDictionary:(NSDictionary * _Nullable)dictionary toUrl:(NSString * _Nonnull)url andBlock:(ActionPerformerResultBlock)block {
#ifdef DEBUG
    url = [NSString stringWithFormat:@"http://localhost/~Frank/Emotion-Diary-Web%@", url];
#else
    url = [NSString stringWithFormat:@"http://%@%@", SERVER_URL, url];
#endif
    
    NSMutableDictionary *request = [dictionary mutableCopy];
    request[@"version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    request[@"platform"] = @"iOS";
    if ([ActionPerformer hasLoggedIn]) {
        request[@"userid"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
        request[@"token"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:request progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        if ([responseDictionary[@"code"] intValue] != 0) {
#ifdef DEBUG
            block(NO, [NSString stringWithFormat:@"%@ - %@", responseDictionary[@"code"], responseDictionary[@"message"]], nil);
#else
            block(NO, responseDictionary[@"message"], nil);
#endif
        }else {
            block(YES, nil, responseDictionary[@"data"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
#ifdef DEBUG
        block(NO, error.localizedDescription, nil);
#else
        block(NO, @"网络连接错误", nil);
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
    [ActionPerformer postWithDictionary:request toUrl:@"/api/register.php" andBlock:block];
}

+ (void)loginWithName:(NSString *)name password:(NSString *)password andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"name"] = name;
    request[@"password"] = [Utilities MD5:password];
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
        block(NO, @"该日记没有本地存档", nil);
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
            block(NO, @"图片类型不正确", nil);
            return;
    }
    request[@"image"] = [imageData base64EncodedStringWithOptions:0];
    request[@"type"] = imageType;
    [ActionPerformer postWithDictionary:request toUrl:@"/api/upload_image.php" andBlock:block];
}

#pragma mark - Face++ connection

+ (void)processFaceppResult:(FaceppResult * _Nonnull)result andBlock:(ActionPerformerResultBlock)block {
    if (result.success) {
        block(YES, nil, result.content);
    }else {
#ifdef DEBUG
        block(NO, [NSString stringWithFormat:@"%d - %@", result.error.errorCode, result.error.message], nil);
#else
        block(NO, @"网络连接错误", nil);
#endif
    }
}

+ (void)registerFaceWithImage:(UIImage *)image andBlock:(ActionPerformerResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FaceppResult *detectResult = [[FaceppAPI detection] detectWithURL:nil orImageData:[Utilities compressImage:image toSize:100] mode:FaceppDetectionModeOneFace];
        [ActionPerformer processFaceppResult:detectResult andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
            if (!success) {
                [ActionPerformer processFaceppResult:detectResult andBlock:block];
                return;
            }
            NSDictionary *dictDetect = data;
            if ([dictDetect[@"face"] count] == 0) {
                block(NO, @"没有检测到人脸，您是否离镜头太远了？", nil);
                return;
            }
    #ifdef DEBUG
            NSString *groupName = @"EmotionDiaryTest";
    #else
            NSString *groupName = @"EmotionDiary";
    #endif
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
            NSString *name = [NSString stringWithFormat:@"iOS_User_%@", [dateFormatter stringFromDate:[NSDate date]]];
            FaceppResult *registerResult = [[FaceppAPI person] createWithPersonName:name andFaceId:@[dictDetect[@"face"][0][@"face_id"]] andTag:@"iOS" andGroupId:nil orGroupName:@[groupName]];
            [ActionPerformer processFaceppResult:registerResult andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                if (!success) {
                    [ActionPerformer processFaceppResult:detectResult andBlock:block];
                    return;
                }
                NSDictionary *dictCreate = data;
                FaceppResult *trainResult = [[FaceppAPI train] trainAsynchronouslyWithId:dictCreate[@"person_id"] orName:nil andType:FaceppTrainVerify]; // Train the object
                [ActionPerformer processFaceppResult:trainResult andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                    if (!success) {
                        [ActionPerformer processFaceppResult:trainResult andBlock:block];
                        return;
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:dictCreate[@"person_id"] forKey:@"faceID"]; // Sace faceID in local storage
                    block(YES, nil, @{@"emotion": dictDetect[@"face"][0][@"attribute"][@"smiling"][@"value"]});
                }];
            }];
        }];
    });
}

+ (void)verifyFaceWithImage:(UIImage *)image andBlock:(ActionPerformerResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *personID = [[NSUserDefaults standardUserDefaults] objectForKey:@"faceID"];
        if (personID.length == 0) {
            block(NO, @"您还未注册人脸", nil);
            return;
        }
        FaceppResult *detectResult = [[FaceppAPI detection] detectWithURL:nil orImageData:[Utilities compressImage:image toSize:100] mode:FaceppDetectionModeOneFace];
        [ActionPerformer processFaceppResult:detectResult andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
            if (!success) {
                [ActionPerformer processFaceppResult:detectResult andBlock:block];
                return;
            }
            NSDictionary *dictDetect = data;
            if ([dictDetect[@"face"] count] == 0) {
                block(NO, @"没有检测到人脸，您是否离镜头太远了？", nil);
                return;
            }
            FaceppResult *verifyResult = [[FaceppAPI recognition] verifyWithFaceId:dictDetect[@"face"][0][@"face_id"] andPersonId:personID orPersonName:nil async:NO];
            [ActionPerformer processFaceppResult:verifyResult andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                if (!success) {
                    [ActionPerformer processFaceppResult:verifyResult andBlock:block];
                    return;
                }
                NSDictionary *dictVerify = data;
                if ([dictVerify[@"is_same_person"] boolValue]) {
                    block(YES, nil, @{@"emotion": dictDetect[@"face"][0][@"attribute"][@"smiling"][@"value"]});
                    // Train the person with new face
                    FaceppResult *addResult = [[FaceppAPI person] addFaceWithPersonName:nil orPersonId:personID andFaceId:@[dictDetect[@"face"][0][@"face_id"]]];
                    [ActionPerformer processFaceppResult:addResult andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                        if (!success) {
                            [[FaceppAPI train] trainAsynchronouslyWithId:personID orName:nil andType:FaceppTrainVerify];
                        }
                    }];
                }else {
                    block(NO, @"这似乎不是您本人", nil);
                }
            }];
        }];
    });
}

+ (void)deleteFaceWithBlock:(ActionPerformerResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *personID = [[NSUserDefaults standardUserDefaults] objectForKey:@"faceID"];
        if (personID.length == 0) {
            block(NO, @"您还未注册人脸", nil);
            return;
        }
        FaceppResult *clearResult = [[FaceppAPI person] deleteWithPersonName:nil orPersonId:personID];
        [ActionPerformer processFaceppResult:clearResult andBlock:block];
    });
}

#pragma mark - Local functions

+ (BOOL)hasLoggedIn {
    return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] length] > 0 && [[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] length] > 0);
}

+ (UIImage *)getFaceImageByEmotion:(int)smile {
    NSString *imageName;
    if (smile <= 33) {
        imageName = @"不笑";
    }else if (smile <= 66) {
        imageName = @"中笑";
    }else {
        imageName = @"大笑";
    }
    return [UIImage imageNamed:imageName];
}

@end
