//
//  EmotionDiaryManager.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/1.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmotionDiaryManager : NSObject {
    NSMutableArray<NSDictionary *> *diaries;
}

NS_ASSUME_NONNULL_BEGIN

+ (EmotionDiaryManager *)sharedManager; // 单例模式

- (BOOL)saveLocalDiary:(EmotionDiary *)diary;

- (BOOL)saveOnlineDiary:(EmotionDiary *)diary;

- (NSArray<EmotionDiary *> * _Nullable)getDiaryOfDate:(NSDate *)date;

- (NSArray<NSNumber *> *)getStatOfLastDays:(int)dayNumber;

NS_ASSUME_NONNULL_END

@end
