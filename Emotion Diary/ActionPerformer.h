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

typedef NS_ENUM(NSInteger, EmotionDiaryImageType) {
    EmotionDiaryImageTypeIcon,
    EmotionDiaryImageTypeSelfie,
    EmotionDiaryImageTypeImage
};

NS_ASSUME_NONNULL_BEGIN

typedef void (^ActionPerformerResultBlock)(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data);

@interface ActionPerformer : NSObject

#pragma mark - Server connection

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

#pragma mark - Face++ connection

+ (void)registerFaceWithImage:(UIImage *)image andBlock:(ActionPerformerResultBlock)block;

+ (void)verifyFaceWithImage:(UIImage *)image andBlock:(ActionPerformerResultBlock)block;

+ (void)deleteFaceWithBlock:(ActionPerformerResultBlock)block;

#pragma mark - Local functions

/**
 * Check whether the user has logged in
 * @return Whether the user has logged in
 */
+ (BOOL)hasLoggedIn;

/**
 * Get the face name of a given emotion value
 * @param smile The emotion value
 * @return Face name
 */
+ (NSString *)getFaceNameByEmotion:(int)smile;

NS_ASSUME_NONNULL_END

@end
