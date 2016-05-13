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
        if (!sharedManager) {
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
        isUploading = NO;
        uploadQueue = [NSMutableArray new];
    }
    return self;
}

- (NSDateFormatter *)PRCDateFormatter {
    if (!PRCDateFormatter) {
        PRCDateFormatter = [NSDateFormatter new];
        [PRCDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [PRCDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"PRC"]];
    }
    return PRCDateFormatter;
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
                        WEATHER: [self filter:diary.placeName],
                        CREATE_TIME: diary.createTime,
                        DIARY_ID: [NSNumber numberWithInt:diary.diaryID]
                        };
    
    // TODO: 二分查找优化
    for (int i = 0; i < diaries.count; i++) {
        NSDictionary *dict = diaries[i];
        NSTimeInterval interval = [diary.createTime timeIntervalSinceDate:dict[CREATE_TIME]];
        if (ABS(interval) < 1) {
            [diaries removeObjectAtIndex:i];
            break;
        }
        if (interval > 1) { // TODO: Verify
            break;
        }
    }
    
    [diaries addObject:diaryDictionary];
    return [self saveWithSort:YES];
}

- (BOOL)deleteDiary:(EmotionDiary *)diary {
    for (int i = 0; i < diaries.count; i++) {
        NSDictionary *dict = diaries[i];
        NSTimeInterval interval = [diary.createTime timeIntervalSinceDate:dict[CREATE_TIME]];
        if (ABS(interval) < 1) {
            [diaries removeObjectAtIndex:i];
            break;
        }
    }
    return [self saveWithSort:NO];
}

- (NSString *)filter:(NSString *)string {
    return string ? string : @"";
}

- (BOOL)saveWithSort:(BOOL)sort {
    if (sort) {
        // 按时间降序排列
        [diaries sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
            return [obj2[CREATE_TIME] compare:obj1[CREATE_TIME]];
        }];
    }
    [[NSUserDefaults standardUserDefaults] setObject:diaries forKey:@"diaries"];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (EmotionDiary *)createEmotionDiaryFromLocalDictionary:(NSDictionary *)dict {
    EmotionDiary *diary = [EmotionDiary new];
    diary.emotion = [dict[EMOTION] intValue];
    diary.selfie = dict[SELFIE];
    diary.hasImage = [dict[HAS_IMAGE] boolValue];
    diary.hasTag = [dict[HAS_TAG] boolValue];
    diary.shortText = dict[SHORT_TEXT];
    diary.placeName = dict[PLACE_NAME];
    diary.weather = dict[WEATHER];
    diary.createTime = dict[CREATE_TIME];
    diary.diaryID = [dict[DIARY_ID] intValue];
    return diary;
}

+ (EmotionDiary *)createEmotionDiaryFromServerDictionary:(NSDictionary *)dict {
    EmotionDiary *diary = [EmotionDiary new];
    diary.emotion = [dict[@"emotion"] intValue];
    diary.selfie = dict[@"selfie"];
    diary.hasImage = [dict[@"has_image"] boolValue];
    diary.hasTag = [dict[@"has_tag"] boolValue];
    diary.shortText = dict[@"short_text"];
    diary.placeName = dict[@"place_name"];
    diary.weather = dict[@"weather"];
    diary.createTime = [[[EmotionDiaryManager sharedManager] PRCDateFormatter] dateFromString:dict[@"create_time"]];
    diary.diaryID = [dict[@"diaryid"] intValue];
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
            [result addObject:[EmotionDiaryManager createEmotionDiaryFromLocalDictionary:diary]];
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
    return [EmotionDiaryManager createEmotionDiaryFromLocalDictionary:diaries[index]];
}

#pragma mark - Sync function

- (void)startUploading {
    if (!isUploading) {
        isUploading = YES;
        [uploadQueue removeAllObjects];
        for (NSDictionary *dict in diaries) {
            if ([dict[DIARY_ID] intValue] == NO_DIARY_ID) {
                EmotionDiary *diary = [EmotionDiaryManager createEmotionDiaryFromLocalDictionary:dict];
                [uploadQueue addObject:@{@"diary": diary, @"state": UPLOAD_STATE_WAITING, @"error": @0}];
            }
        }
        [self postNotification:UPLOAD_PROGRESS_CHANGED_NOTIFOCATION withDiaryID:NO_DIARY_ID];;
        [self upload];
    }
}

- (void)upload {
    if (!isUploading || self.totalUploadNumber == 0) {
        isUploading = NO;
        [uploadQueue removeAllObjects];
        return;
    }
    NSMutableDictionary *dict = [uploadQueue[0] mutableCopy];
    if ([dict[@"error"] intValue] > 5) { // 错误超过五次放弃尝试
        [uploadQueue removeObjectAtIndex:0];
        [self postNotification:UPLOAD_PROGRESS_CHANGED_NOTIFOCATION withDiaryID:NO_DIARY_ID];
        sleep(1);
        [self upload];
        return;
    }
    dict[@"state"] = UPLOAD_STATE_SYNCING;
    [uploadQueue setObject:dict atIndexedSubscript:0];
    EmotionDiary *diary = dict[@"diary"];
    [self postNotification:UPLOAD_PROGRESS_CHANGED_NOTIFOCATION withDiaryID:diary.diaryID];
    [diary uploadToServerWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
        if (!success) { // 出错则放到同步队列的末尾等待重试
            dict[@"error"] = [NSNumber numberWithInt:[dict[@"error"] intValue] + 1];
            dict[@"state"] = message;
            [uploadQueue addObject:dict];
        }
        [uploadQueue removeObjectAtIndex:0];
        [self postNotification:UPLOAD_PROGRESS_CHANGED_NOTIFOCATION withDiaryID:diary.diaryID];
        sleep(1);
        [self upload];
    }];
}

- (void)stopUploading {
    if (isUploading) {
        isUploading = NO;
        [self postNotification:UPLOAD_PROGRESS_CHANGED_NOTIFOCATION withDiaryID:NO_DIARY_ID];
    }
}

- (void)postNotification:(NSString *)name withDiaryID:(int)diaryID {
    NSDictionary *dict = @{DIARY_ID: [NSNumber numberWithInt:diaryID]};
    // 接收通知的对象大多需要更新UI 因此在主线程上发通知
    if ([[NSThread currentThread] isMainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:dict];
    }else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil userInfo:dict];
        });
    }
}

- (NSInteger)totalUploadNumber {
    return uploadQueue.count;
}

- (NSDictionary * _Nullable)getUploadDataOfIndex:(NSInteger)index {
    if (index < 0 || index >= self.totalUploadNumber) {
        return nil;
    }
    return uploadQueue[index];
}

- (void)syncDiaryOfYear:(NSInteger)year month:(NSInteger)month fromServerWithBlock:(EmotionDiaryResultBlock)block {
    [ActionPerformer syncDiaryWithYear:(int)year month:(int)month andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
        if (!success) {
            block(NO, message, nil);
            return;
        }
        
        NSArray *diaryArray = data[@"diaries"];
        
        // 删除本月多余的日记
        NSArray *diariesCopy = [diaries copy];
        for (int i = 0; i < diariesCopy.count; i++) {
            NSDictionary *localDict = diariesCopy[i];
            if ([localDict[DIARY_ID] intValue] == NO_DIARY_ID) { // 只有本地版
                return;
            }
            NSDate *theDate = localDict[CREATE_TIME];
            NSInteger theYear, theMonth;
            [[NSCalendar currentCalendar] getEra:nil year:&theYear month:&theMonth day:nil fromDate:theDate];
            if (theYear == year && theMonth == month) {
                BOOL found = NO;
                for (NSDictionary *onlineDict in diaryArray) {
                    NSDate *thatDate = [PRCDateFormatter dateFromString:onlineDict[@"create_time"]];
                    if (ABS([theDate timeIntervalSinceDate:thatDate]) < 1) {
                        found = YES;
                        break;
                    }
                }
                if (!found) {
                    [[EmotionDiaryManager createEmotionDiaryFromLocalDictionary:localDict] deleteLocalVersionWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
                        NSLog(@"Deleted redundant diary %@", [PRCDateFormatter stringFromDate:localDict[CREATE_TIME]]);
                    }];
                }
            }else if (theYear < year || (theYear == year && theMonth < month)) {
                break;
            }
        }
        
        for (NSDictionary *dict in diaryArray) {
            EmotionDiary *diary = [EmotionDiaryManager createEmotionDiaryFromServerDictionary:dict];
            if (![self saveDiary:diary]) {
                block(NO, @"日记记录创建失败", nil);
                return;
            }
        }
        [self postNotification:SYNC_PROGRESS_CHANGED_NOTIFOCATION withDiaryID:NO_DIARY_ID];
        block(YES, nil, nil);
    }];
}

@end
