//
//  EmotionDiaryManager.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/1.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "EmotionDiaryManager.h"

static EmotionDiaryManager *sharedManager;

@implementation EmotionDiaryManager

+ (EmotionDiaryManager *)sharedManager {
    @synchronized (self) {
        if (sharedManager == nil) {
            sharedManager = [EmotionDiaryManager new];
        }
    }
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        diaries = [[[NSUserDefaults standardUserDefaults] objectForKey:@"diaries"] mutableCopy];
        if (!diaries) {
            diaries = [NSMutableArray new];
        }
        isSyncing = NO;
        syncQueue = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Storage function

- (BOOL)saveDiary:(EmotionDiary *)diary {
    NSDictionary *diaryDictionary;
    diaryDictionary = @{
                        EMOTION: [NSNumber numberWithInt:diary.emotion],
                        SELFIE: [self filter:diary.selfie],
                        HAS_IMAGE: [NSNumber numberWithBool:(diary.images.count > 0 || diary.hasImage)],
                        HAS_TAG: [NSNumber numberWithBool:(diary.tags.count > 0 || diary.hasTag)],
                        SHORT_TEXT: diary.shortText,
                        PLACE_NAME: [self filter:diary.placeName],
                        PLACE_LONG: [NSNumber numberWithFloat:diary.placeLong],
                        PLACE_LAT: [NSNumber numberWithFloat:diary.placeLat],
                        WEATHER: [self filter:diary.placeName],
                        CREATE_TIME: diary.createTime,
                        DIARY_ID: [NSNumber numberWithInt:diary.diaryID]
                        };
    for (int i = 0; i < diaries.count; i++) {
        NSDictionary *dict = diaries[i];
        if (ABS([diary.createTime timeIntervalSinceDate:dict[CREATE_TIME]]) < 1) {
            [diaries removeObjectAtIndex:i];
            break;
        }
    }
    [diaries addObject:diaryDictionary];
    return [self sortAndSave];
}

- (NSString *)filter:(NSString *)string {
    return string ? string : @"";
}

- (BOOL)sortAndSave {
    // 按时间降序排列
    diaries = [NSMutableArray arrayWithArray:[diaries sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj2[CREATE_TIME] compare:obj1[CREATE_TIME]];
    }]];
    [[NSUserDefaults standardUserDefaults] setObject:diaries forKey:@"diaries"];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (EmotionDiary *)createEmotionDiaryFromDictionary:(NSDictionary *)dict {
    EmotionDiary *diary = [EmotionDiary new];
    diary.emotion = [dict[EMOTION] intValue];
    diary.selfie = dict[SELFIE];
    diary.hasImage = [dict[HAS_IMAGE] boolValue];
    diary.hasTag = [dict[HAS_TAG] boolValue];
    diary.shortText = dict[SHORT_TEXT];
    diary.placeName = dict[PLACE_NAME];
    diary.placeLong = [dict[PLACE_LONG] doubleValue];
    diary.placeLat = [dict[PLACE_LAT] doubleValue];
    diary.weather = dict[WEATHER];
    diary.createTime = dict[CREATE_TIME];
    diary.diaryID = [dict[DIARY_ID] intValue];
    return diary;
}

#pragma mark - Stat function

- (NSArray<EmotionDiary *> *)getDiaryOfDate:(NSDate *)date {
    // diaries按时间降序排列，二分查找，找到该日期的后面一天作为下一步的搜索起点
    NSUInteger findIndex = [diaries indexOfObject:@{CREATE_TIME: date} inSortedRange:NSMakeRange(0, diaries.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) { // obj2 is the fixed object
        NSTimeInterval interval = [obj1[CREATE_TIME] timeIntervalSinceDate:obj2[CREATE_TIME]];
        return interval > 24 * 3600 ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSMutableArray *result = [NSMutableArray new];
    for (NSUInteger i = findIndex; i < diaries.count; i++) {
        NSDictionary *diary = diaries[i];
        NSDate *diaryDate = diary[CREATE_TIME];
        if ([[NSCalendar currentCalendar] isDate:diaryDate inSameDayAsDate:date]) {
            [result addObject:[EmotionDiaryManager createEmotionDiaryFromDictionary:diary]];
        }else if ([date timeIntervalSinceDate:diaryDate] > 0) {
            break;
        }
    }
    return result;
}

- (NSArray<NSNumber *> *)getStatOfLastDays:(int)dayNumber {
    NSMutableArray *stat = [NSMutableArray new];
    for (int i = 0; i < dayNumber; i++) {
        [stat addObject:diaries.count > 0 ? @[] : @[@50]];
    }
    
    NSMutableArray *tempArr;
    for (NSDictionary *dict in diaries) {
        int dayToToday = -[dict[CREATE_TIME] timeIntervalSinceNow] / (24 * 3600);
        if (dayToToday >= 0) {
            if (dayToToday < dayNumber) {
                tempArr = [stat[dayToToday] mutableCopy];
                [tempArr addObject:dict[EMOTION]];
                [stat setObject:tempArr atIndexedSubscript:dayToToday];
            }else {
                break;
            }
        }
    }
    
    NSMutableArray *result = [NSMutableArray new];
    for (int i = 0; i < dayNumber; i++) {
        NSDictionary *dict = stat[dayNumber - i - 1];
        double emotionAverage = 0;
        if (dict.count > 0) {
            for (NSNumber *num in dict) {
                emotionAverage += [num intValue];
            }
            emotionAverage /= dict.count;
        }else {
            emotionAverage = NO_EMOTION;
        }
        result[i] = [NSNumber numberWithFloat:emotionAverage];
    }
    
    if ([result[0] doubleValue] == NO_EMOTION) {
        for (int i = 1; ; i++) {
            if ([result[i] doubleValue] != NO_EMOTION) {
                result[0] = result[i];
                break;
            }
        }
    }
    if ([result[dayNumber - 1] doubleValue] == NO_EMOTION) {
        for (int i = dayNumber - 2; ; i--) {
            if ([result[i] doubleValue] != NO_EMOTION) {
                result[dayNumber - 1] = result[i];
                break;
            }
        }
    }
    for (int i = 0; i < dayNumber;) {
        if ([result[i] doubleValue] != NO_EMOTION) {
            i++;
        }else {
            int j = i + 1;
            while ([result[j] doubleValue] == NO_EMOTION) {
                j++;
            }
            double start = [result[i - 1] doubleValue];
            double length = [result[j] doubleValue] - start;
            for (int p = i; p < j; p++) {
                double middle = start + length * (p - i + 1) / (j - i + 1);
                result[p] = [NSNumber numberWithDouble:middle];
            }
            i = j + 1;
        }
    }
    
    return result;
}

- (NSInteger)totalDiaryNumber {
    return diaries.count;
}

- (EmotionDiary *)getDiaryOfIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalDiaryNumber) {
        return nil;
    }
    return [EmotionDiaryManager createEmotionDiaryFromDictionary:diaries[index]];
}

#pragma mark - Sync function

- (void)startSyncing {
    if (!isSyncing) {
        isSyncing = YES;
        [syncQueue removeAllObjects];
        for (NSDictionary *dict in diaries) {
            if ([dict[DIARY_ID] intValue] == NO_DIARY_ID) {
                EmotionDiary *diary = [EmotionDiaryManager createEmotionDiaryFromDictionary:dict];
                [syncQueue addObject:@{@"diary": diary, @"state": SYNC_STATE_WAITING}];
            }
        }
        [self postSyncNotification:[NSNumber numberWithInt:NO_DIARY_ID]];
        [self sync];
    }
}

- (void)sync {
    if (!isSyncing || self.totalSyncNumber == 0) {
        isSyncing = NO;
        [syncQueue removeAllObjects];
        return;
    }
    NSMutableDictionary *dict = [syncQueue[0] mutableCopy];
    dict[@"state"] = SYNC_STATE_SYNCING;
    [syncQueue setObject:dict atIndexedSubscript:0];
    [dict[@"diary"] uploadToServerWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
        if (!success) { // 放到同步队列的末尾等待重试
            dict[@"state"] = message;
            [syncQueue addObject:dict];
        }
        [syncQueue removeObjectAtIndex:0];
        [self postSyncNotification:[NSNumber numberWithInt:((EmotionDiary *)dict[@"diary"]).diaryID]];
        [self sync];
    }];
}

- (void)stopSyncing {
    isSyncing = NO;
    [self postSyncNotification:[NSNumber numberWithInt:NO_DIARY_ID]];
}

- (void)postSyncNotification:(NSNumber *)diaryID {
    // 因为接收通知的线程一般都需要更新UI，所以在主线程发通知
    NSDictionary *dict;
    if ([diaryID intValue] != NO_DIARY_ID) {
        dict = @{DIARY_ID: diaryID};
    }
    if ([[NSThread currentThread] isMainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SYNC_PROGRESS_CHANGED_NOTIFOCATION object:nil userInfo:dict];
    }else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SYNC_PROGRESS_CHANGED_NOTIFOCATION object:nil userInfo:dict];
        });
    }
}

- (NSInteger)totalSyncNumber {
    return syncQueue.count;
}

- (NSDictionary * _Nullable)getSyncDataOfIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalSyncNumber) {
        return nil;
    }
    return syncQueue[index];
}

@end
