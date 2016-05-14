//
//  EmotionDiaryManager.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/1.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UPLOAD_STATE_SYNCING @1
#define UPLOAD_STATE_WAITING @2
#define SYNC_INFO @"syncInfo"

NS_ASSUME_NONNULL_BEGIN

@interface EmotionDiaryManager : NSObject {
    NSMutableArray<NSDictionary *> *diaries;
    BOOL isUploading;
    NSMutableArray<NSDictionary *> *uploadQueue;
    NSDateFormatter *PRCDateFormatter;
}

+ (EmotionDiaryManager *)sharedManager; // 单例模式

- (NSDateFormatter *)PRCDateFormatter;

#pragma mark - Storage function

- (BOOL)saveDiary:(EmotionDiary *)diary;

- (BOOL)deleteDiary:(EmotionDiary *)diary;

#pragma mark - Stat function

- (NSArray<EmotionDiary *> * _Nullable)getDiaryOfDate:(NSDate *)date;

- (NSArray<NSNumber *> *)getStatOfLastDays:(int)dayNumber;

- (NSInteger)totalDiaryNumber;

- (EmotionDiary * _Nullable)getDiaryOfIndex:(NSInteger)index;

#pragma mark - Upload and sync function

- (void)startUploading;

- (void)stopUploading;

- (NSInteger)totalUploadNumber;

- (NSDictionary * _Nullable)getUploadDataOfIndex:(NSInteger)index;

- (void)syncDiaryOfYear:(NSInteger)year month:(NSInteger)month forced:(BOOL)forced fromServerWithBlock:(EmotionDiaryResultBlock)block;

NS_ASSUME_NONNULL_END

@end
