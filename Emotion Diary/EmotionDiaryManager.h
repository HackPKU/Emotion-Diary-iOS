//
//  EmotionDiaryManager.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/1.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SYNC_STATE_SYNCING @"EmotionDiarySyncStateSyncing"
#define SYNC_STATE_WAITING @"EmotionDiarySyncStateWaiting"

NS_ASSUME_NONNULL_BEGIN

@interface EmotionDiaryManager : NSObject {
    NSMutableArray<NSDictionary *> *diaries;
    BOOL isSyncing;
    NSMutableArray<NSDictionary *> *syncQueue;
}

+ (EmotionDiaryManager *)sharedManager; // 单例模式

#pragma mark - Storage function

- (BOOL)saveDiary:(EmotionDiary *)diary;

#pragma mark - Stat function

- (NSArray<EmotionDiary *> * _Nullable)getDiaryOfDate:(NSDate *)date;

- (NSArray<NSNumber *> *)getStatOfLastDays:(int)dayNumber;

- (NSInteger)totalDiaryNumber;

- (EmotionDiary * _Nullable)getDiaryOfIndex:(NSInteger)index;

#pragma mark - Sync function

- (void)startSyncing;

- (void)stopSyncing;

- (NSInteger)totalSyncNumber;

- (NSDictionary * _Nullable)getSyncDataOfIndex:(NSInteger)index;

NS_ASSUME_NONNULL_END

@end
