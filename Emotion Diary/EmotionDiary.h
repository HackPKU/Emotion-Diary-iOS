//
//  EmotionDiary.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/27.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define EMOTION @"emotion"
#define SELFIE @"selfie"
#define IMAGES @"images"
#define TAGS @"tags"
#define TEXT @"text"
#define PLACE_NAME @"placeName"
#define PLACE_LONG @"placeLong"
#define PLACE_LAT @"placeLat"
#define WEATHER @"weather"
#define CREATE_TIME @"createTime"
#define IS_SHARED @"isShared"

#define DIARY_ID @"diaryID"
#define HAS_IMAGE @"hasImage"
#define HAS_TAG @"hasTag"
#define SHORT_TEXT @"shortText"

#define SELFIE_PATH @"EmotionDiarySelfie"
#define IMAGES_PATH @"EmotionDiaryImages"
#define DIARY_PATH @"EmotionDiary"

#define NO_EMOTION -1
#define NO_DIARY_ID -1

NS_ASSUME_NONNULL_BEGIN

/**
 * The block is and should always in background thread
 */
typedef void (^EmotionDiaryResultBlock)(BOOL success, NSString * _Nullable message, NSObject * _Nullable data);

@interface EmotionDiary : NSObject <NSCoding>

@property int emotion;
@property NSString * _Nullable selfie;
@property UIImage * _Nullable imageSelfie;
@property NSArray<NSString *> * _Nullable images;
@property NSArray<UIImage *> * _Nullable imageImages;
@property NSArray<NSString *> * _Nullable tags;
@property NSString * _Nullable text;
@property NSString * _Nullable placeName;
@property float placeLong;
@property float placeLat;
@property NSString * _Nullable weather;
@property NSDate *createTime;
@property BOOL isShared;

@property int diaryID;
@property BOOL hasImage;
@property BOOL hasTag;
@property NSString * _Nullable shortText;

- (instancetype)initWithEmotion:(int)emotion selfie:(UIImage * _Nullable)selfie images:(NSArray<UIImage *> * _Nullable)images tags:(NSArray<NSString *> * _Nullable)tags text:(NSString *)text placeName:(NSString * _Nullable)placeName placeLong:(float)placeLong placeLat:(float)placeLat weather:(NSString * _Nullable)weather;

- (BOOL)hasOnlineVersion;

- (void)writeToDiskWithBlock:(EmotionDiaryResultBlock)block;

- (void)uploadToServerWithBlock:(EmotionDiaryResultBlock)block;

- (void)getFullVersionWithBlock:(EmotionDiaryResultBlock)block;

- (void)shareWithBlock:(EmotionDiaryResultBlock)block;

- (void)unshareWithBlock:(EmotionDiaryResultBlock)block;

- (void)deleteWithBlock:(EmotionDiaryResultBlock)block;

- (void)deleteLocalVersionWithBlock:(EmotionDiaryResultBlock)block;

NS_ASSUME_NONNULL_END

@end
