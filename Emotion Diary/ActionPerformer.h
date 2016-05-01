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

/**
 * Check whether the path exists. If not, try to create one.
 
 * The root directory is the document directory
 * @param path The required path
 * @return Whether the path exists after the function
 */
+ (BOOL)checkAndCreatePath:(NSString *)path;

/**
 * Check whether the file exists at the given path
 
 * The root directory is the document directory
 * @param path The required path
 * @param name The file name
 * @return Whether the file exists
 */
+ (BOOL)fileExistsAtPath:(NSString *)path withName:(NSString *)name;

/**
 * Create file at the given path
 
 * The root directory is the document directory
 * @param data The data to be saved as file
 * @param path The required path
 * @param name The file name
 * @return Whether the file is created successfully
 */
+ (BOOL)createFile:(NSData *)data atPath:(NSString *)path withName:(NSString *)name;

/**
 * Get the file at the given path
 
 * The root directory is the document directory
 * @param path The required path
 * @param name The file name
 * @return The data of the file (if exists) or nil
 */
+ (NSData * _Nullable)getFileAtPath:(NSString *)path withName:(NSString *)name;

NS_ASSUME_NONNULL_END

@end
