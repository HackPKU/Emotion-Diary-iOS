//
//  EmotionDiaryManager.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/1.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmotionDiaryManager : NSObject {
    NSMutableArray<NSDictionary *> *diaries;
}

+ (EmotionDiaryManager *)sharedManager; // 单例模式

- (BOOL)saveLocalDiary:(EmotionDiary *)diary;

- (BOOL)saveOnlineDiary:(EmotionDiary *)diary;

- (NSArray<EmotionDiary *> * _Nullable)getDiaryOfDate:(NSDate *)date;

- (NSArray<NSNumber *> *)getStatOfLastDays:(int)dayNumber;

- (NSInteger)totalNumber;

- (EmotionDiary *)getDiaryOfIndex:(NSInteger)index;

NS_ASSUME_NONNULL_END

@end
