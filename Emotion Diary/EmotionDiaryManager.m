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
            sharedManager = [[EmotionDiaryManager alloc] init];
        }
    }
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        diaries = [[[NSUserDefaults standardUserDefaults] objectForKey:@"diaries"] mutableCopy];
        if (!diaries) {
            diaries = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

- (EmotionDiary *)createEmotionDiaryFromDictionary:(NSDictionary *)dict {
    EmotionDiary *diary = [[EmotionDiary alloc] init];
    diary.hasLocalVersion = [dict[HAS_LOCAL_VERSION] boolValue];
    diary.hasOnlineVersion = [dict[HAS_ONLINE_VERSION] boolValue];
    diary.diaryID = [dict[DIARY_ID] intValue];
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
    return diary;
}

- (BOOL)saveLocalDiary:(EmotionDiary *)diary {
    NSDictionary *diaryDictionary;
    diaryDictionary = @{EMOTION: [NSNumber numberWithInt:diary.emotion],
                        HAS_LOCAL_VERSION: [NSNumber numberWithBool:YES],
                        HAS_ONLINE_VERSION: [NSNumber numberWithBool:diary.hasOnlineVersion],
                        SELFIE: [self filter:diary.selfie],
                        HAS_IMAGE: [NSNumber numberWithBool:(diary.images.count > 0)],
                        HAS_TAG: [NSNumber numberWithBool:(diary.tags.count > 0)],
                        SHORT_TEXT: diary.text.length > 140 ? [diary.text substringToIndex:140] : diary.text,
                        PLACE_NAME: [self filter:diary.placeName],
                        PLACE_LONG: [NSNumber numberWithFloat:diary.placeLong],
                        PLACE_LAT: [NSNumber numberWithFloat:diary.placeLat],
                        WEATHER: [self filter:diary.placeName],
                        CREATE_TIME: diary.createTime};
    [diaries addObject:diaryDictionary];
    return [self save];
}

- (BOOL)saveOnlineDiary:(EmotionDiary *)diary {
    NSDictionary *diaryDictionary;
    diaryDictionary = @{HAS_LOCAL_VERSION: [NSNumber numberWithBool:diary.hasLocalVersion],
                        HAS_ONLINE_VERSION: [NSNumber numberWithBool:YES],
                        DIARY_ID:[NSNumber numberWithInt:diary.diaryID],
                        EMOTION: [NSNumber numberWithInt:diary.emotion],
                        SELFIE: [self filter:diary.selfie],
                        HAS_IMAGE: [NSNumber numberWithBool:diary.hasImage],
                        HAS_TAG: [NSNumber numberWithBool:diary.hasTag],
                        SHORT_TEXT: diary.shortText,
                        PLACE_NAME: [self filter:diary.placeName],
                        PLACE_LONG: [NSNumber numberWithFloat:diary.placeLong],
                        PLACE_LAT: [NSNumber numberWithFloat:diary.placeLat],
                        WEATHER: [self filter:diary.weather],
                        CREATE_TIME: diary.createTime};
    [diaries addObject:diaryDictionary];
    return [self save];
}

- (NSString *)filter:(NSString *)string {
    return string == nil ? @"" : string;
}

- (BOOL)save {
    // 按时间降序排列
    diaries = [NSMutableArray arrayWithArray:[diaries sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj2[CREATE_TIME] compare:obj1[CREATE_TIME]];
    }]];
    [[NSUserDefaults standardUserDefaults] setObject:diaries forKey:@"diaries"];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray<EmotionDiary *> *)getDiaryOfDate:(NSDate *)date {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    // diaries按时间降序排列，二分查找，找到该日期的后面一天作为下一步的搜索起点
    NSUInteger findIndex = [diaries indexOfObject:@{CREATE_TIME: date} inSortedRange:NSMakeRange(0, diaries.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) { // obj2 is the fixed date
        NSTimeInterval interval = [obj1[CREATE_TIME] timeIntervalSinceDate:obj2[CREATE_TIME]];
        return interval > 24 * 3600 ? NSOrderedAscending : NSOrderedDescending;
    }];
    for (NSUInteger i = findIndex; i < diaries.count; i++) {
        NSDictionary *diary = diaries[i];
        NSDate *diaryDate = diary[CREATE_TIME];
        if ([[NSCalendar currentCalendar] isDate:diaryDate inSameDayAsDate:date]) {
            [result addObject:[self createEmotionDiaryFromDictionary:diary]];
        }else if ([date timeIntervalSinceDate:diaryDate] > 0) {
            break;
        }
    }
    return result;
}

- (NSArray<NSNumber *> *)getStatOfLastDays:(int)dayNumber {
    NSMutableArray *stat = [[NSMutableArray alloc] init];
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
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
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

- (NSInteger)totalNumber {
    return diaries.count;
}

- (EmotionDiary *)getDiaryOfIndex:(NSInteger)index {
    return [self createEmotionDiaryFromDictionary:diaries[index]];
}

@end
