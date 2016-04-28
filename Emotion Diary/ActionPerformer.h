//
//  ActionPerformer.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/27.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EmotionDiary.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ActionPerformerResult) {
    ActionPerformerResultSuccess,
    ActionPerformerResultFail
};

typedef void (^ActionPerformerResultBlock)(ActionPerformerResult result, NSString  * _Nullable message, NSObject  * _Nullable data);

@interface ActionPerformer : NSObject

#pragma mark Server connection

+ (void)registerWithName:(NSString *)name password:(NSString *)password sex:(NSString * _Nullable)sex email:(NSString * _Nullable)email icon:(NSString * _Nullable)icon andBlock:(ActionPerformerResultBlock)block;

+ (void)loginWithName:(NSString *)name password:(NSString *)password andBlock:(ActionPerformerResultBlock)block;

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password andBlock:(ActionPerformerResultBlock)block;

+ (void)logoutWithBlock:(ActionPerformerResultBlock)block;

+ (void)viewUserWithName:(NSString *)name andBlock:(ActionPerformerResultBlock)block;

+ (void)editUserWithName:(NSString *)name password:(NSString *)password newPassword:(NSString * _Nullable)newPassword sex:(NSString * _Nullable)sex email:(NSString * _Nullable)email icon:(NSString * _Nullable)icon andBlock:(ActionPerformerResultBlock)block;

+ (void)postDiary:(EmotionDiary *)diary andBlock:(ActionPerformerResultBlock)block;

+ (void)viewDiaryWithDiaryID:(int)diaryID shareKey:(NSString * _Nullable)shareKey andBlock:(ActionPerformerResultBlock)block;

+ (void)syncDiaryWithYear:(int)year month:(int)month andBlock:(ActionPerformerResultBlock)block;

+ (void)deleteDiaryWithDiaryID:(int)diaryID andBlock:(ActionPerformerResultBlock)block;

+ (void)shareDiaryWithDiaryID:(int)diaryID andBlock:(ActionPerformerResultBlock)block;

+ (void)unshareDiaryWithDiaryID:(int)diaryID andBlock:(ActionPerformerResultBlock)block;

+ (void)uploadImage:(UIImage *)image type:(EmotionDiaryImageType)type andBlock:(ActionPerformerResultBlock)block;

#pragma mark Face++ connection

+ (void)registerFaceWithImage:(UIImage *)image name:(NSString *)name andBlock:(ActionPerformerResultBlock)block;

+ (void)verifyFaceWithImage:(UIImage *)image andBlock:(ActionPerformerResultBlock)block;

#pragma mark Local functions

/**
 * Check whether the user has logged in
 */
+ (BOOL)checkLogin;

NS_ASSUME_NONNULL_END

@end
