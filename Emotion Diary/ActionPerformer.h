//
//  ActionPerformer.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/27.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ActionPerformerResult) {
    ActionPerformerResultSuccess,
    ActionPerformerResultFail
};

typedef void (^ActionPerformerResultBlock)(ActionPerformerResult result, NSString  * _Nullable message, NSObject  * _Nullable data);

@interface ActionPerformer : NSObject

+ (void)registerWithName:(NSString *)name password:(NSString *)password sex:(NSString * _Nullable)sex email:(NSString * _Nullable)email icon:(NSString * _Nullable)icon andBlock:(ActionPerformerResultBlock)block;

+ (void)loginWithName:(NSString *)name password:(NSString *)password andBlock:(ActionPerformerResultBlock)block;

+ (void)loginWithEmail:(NSString *)email password:(NSString *)password andBlock:(ActionPerformerResultBlock)block;

+ (void)logoutWithBlock:(ActionPerformerResultBlock)block;

+ (void)viewUserWithName:(NSString *)name andBlock:(ActionPerformerResultBlock)block;

+ (void)editUserWithName:(NSString *)name password:(NSString *)password newPassword:(NSString * _Nullable)newPassword sex:(NSString * _Nullable)sex email:(NSString * _Nullable)email icon:(NSString * _Nullable)icon andBlock:(ActionPerformerResultBlock)block;

+ (void)postDiary:(EmotionDiary *)diary andBlock:(ActionPerformerResultBlock)block;

/**
 * Check whether the user has logged in
 */
+ (BOOL)checkLogin;

NS_ASSUME_NONNULL_END

@end
