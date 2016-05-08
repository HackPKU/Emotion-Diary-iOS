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

#define LOCALHOST

@implementation ActionPerformer

#pragma mark - Server connection

+ (void)postWithDictionary:(NSDictionary * _Nullable)dictionary toUrl:(NSString * _Nonnull)url andBlock:(ActionPerformerResultBlock)block {
    NSString *fullUrl = [NSString stringWithFormat:@"http://%@%@", SERVER_URL, url];
#ifdef DEBUG
#ifdef LOCALHOST
    fullUrl = [NSString stringWithFormat:@"http://localhost/~Frank/Emotion-Diary-Web%@", url];
#endif
#endif
    
    NSMutableDictionary *request = [dictionary mutableCopy];
    request[@"version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    request[@"platform"] = @"iOS";
    if ([ActionPerformer hasLoggedIn]) {
        request[@"userid"] = [[NSUserDefaults standardUserDefaults] objectForKey:USER_ID];
        request[@"token"] = [[NSUserDefaults standardUserDefaults] objectForKey:TOKEN];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:fullUrl parameters:request progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
    request[@"personid"] = [[NSUserDefaults standardUserDefaults] objectForKey:PERSON_ID];
    [ActionPerformer postWithDictionary:request toUrl:@"/api/register.php" andBlock:block];
}

+ (void)loginWithName:(NSString *)name password:(NSString *)password andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    if ([Utilities isValidateEmail:name]) {
        request[@"email"] = name;
    }else {
        request[@"name"] = name;
    }
    request[@"password"] = [Utilities MD5:password];
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
    request[@"personid"] = [[NSUserDefaults standardUserDefaults] objectForKey:PERSON_ID];
    [ActionPerformer postWithDictionary:request toUrl:@"/api/edit_user.php" andBlock:block];
}

+ (void)editPersonIDWithPassword:(NSString *)password personID:(NSString *)personID andBlock:(ActionPerformerResultBlock)block {
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:USER_INFO];
    request[@"name"] = dict[@"name"];
    request[@"password"] = password;
    request[@"sex"] = dict[@"sex"];
    request[@"email"] = dict[@"email"];
    request[@"icon"] = dict[@"icon"];
    request[@"personid"] = personID;
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"PRC"]];
    request[@"create_time"] = [formatter stringFromDate:diary.createTime];
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
                block(NO, @"没有检测到人脸\n您是否离镜头太近或太远了？", nil);
                return;
            }
            NSString *faceID = dictDetect[@"face"][0][@"face_id"];
    #ifdef DEBUG
            NSString *groupName = @"EmotionDiaryTest";
    #else
            NSString *groupName = @"EmotionDiary";
    #endif
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy_MM_dd_HH_mm_ss"];
            NSString *name = [NSString stringWithFormat:@"iOS_User_%@", [dateFormatter stringFromDate:[NSDate date]]];
            FaceppResult *registerResult = [[FaceppAPI person] createWithPersonName:name andFaceId:nil andTag:@"iOS" andGroupId:nil orGroupName:@[groupName]];
            [ActionPerformer processFaceppResult:registerResult andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                if (!success) {
                    [ActionPerformer processFaceppResult:detectResult andBlock:block];
                    return;
                }
                NSString *personID = data[@"person_id"];
                [[NSUserDefaults standardUserDefaults] setObject:personID forKey:PERSON_ID]; // Sace faceID in local storage
                [ActionPerformer addFace:faceID WithBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                    if (!success) {
                        [[NSUserDefaults standardUserDefaults] removeObjectForKey:PERSON_ID]; // Remove faceID for unsuccessful training
                        block(NO, message, nil);
                        return;
                    }
                    block(YES, nil, @{@"emotion": dictDetect[@"face"][0][@"attribute"][@"smiling"][@"value"]});
                }];
            }];
        }];
    });
}

+ (void)verifyFaceWithImage:(UIImage *)image andBlock:(ActionPerformerResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *personID = [[NSUserDefaults standardUserDefaults] objectForKey:PERSON_ID];
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
                block(NO, @"没有检测到人脸\n您是否离镜头太近或太远了？", nil);
                return;
            }
            NSString *faceID = dictDetect[@"face"][0][@"face_id"];
            FaceppResult *verifyResult = [[FaceppAPI recognition] verifyWithFaceId:faceID andPersonId:personID orPersonName:nil async:NO];
            [ActionPerformer processFaceppResult:verifyResult andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                if (!success) {
                    [ActionPerformer processFaceppResult:verifyResult andBlock:block];
                    return;
                }
                NSDictionary *dictVerify = data;
                if ([dictVerify[@"is_same_person"] boolValue]) {
                    block(YES, nil, @{@"emotion": dictDetect[@"face"][0][@"attribute"][@"smiling"][@"value"]});
                    
                    // Add and train the person with new face
                    [ActionPerformer addFace:faceID WithBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                        NSLog(@"Face added to current personID");
                    }];
                }else {
                    block(NO, @"这似乎不是您本人", nil);
                }
            }];
        }];
    });
}

+ (void)addFace:(NSString *)faceID WithBlock:(ActionPerformerResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *personID = [[NSUserDefaults standardUserDefaults] objectForKey:PERSON_ID];
        if (personID.length == 0) {
            block(NO, @"您还未注册人脸", nil);
            return;
        }
        FaceppResult *addResult = [[FaceppAPI person] addFaceWithPersonName:nil orPersonId:personID andFaceId:@[faceID]];
        [ActionPerformer processFaceppResult:addResult andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
            if (!success) {
                [ActionPerformer processFaceppResult:addResult andBlock:block];
                return;
            }
            FaceppResult *trainResult = [[FaceppAPI train] trainAsynchronouslyWithId:personID orName:nil andType:FaceppTrainVerify];
            [ActionPerformer processFaceppResult:trainResult andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                if (!success) {
                    [ActionPerformer processFaceppResult:trainResult andBlock:block];
                    return;
                }
                block(YES, nil, nil);
            }];
        }];
    });
}

+ (void)deletePersonWithBlock:(ActionPerformerResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *personID = [[NSUserDefaults standardUserDefaults] objectForKey:PERSON_ID];
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
    return ([[[NSUserDefaults standardUserDefaults] objectForKey:USER_ID] length] > 0 && [[[NSUserDefaults standardUserDefaults] objectForKey:TOKEN] length] > 0);
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
