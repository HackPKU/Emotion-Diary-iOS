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
    diary.emotion = [dict[EMOTION] intValue];
    diary.selfie = dict[SELFIE];
    diary.hasImage = [dict[HAS_IMAGE] boolValue];
    diary.hasTag = [dict[HAS_TAG] boolValue];
    diary.shortText = dict[SHORT_TEXT];
    diary.placeName = dict[PLACE_NAME];
    diary.placeLong = [dict[PLACE_LONG] floatValue];
    diary.placeLat = [dict[PLACE_LAT] floatValue];
    diary.weather = dict[WEATHER];
    diary.createTime = dict[CREATE_TIME];
    return diary;
}

- (BOOL)saveLocalDiary:(EmotionDiary *)diary {
    NSDictionary *diaryDictionary;
    diaryDictionary = @{EMOTION: [NSNumber numberWithInt:diary.emotion], HAS_LOCAL_VERSION: [NSNumber numberWithBool:YES], HAS_ONLINE_VERSION: [NSNumber numberWithBool:diary.hasOnlineVersion], SELFIE: [self filter:diary.selfie], HAS_IMAGE: [NSNumber numberWithBool:(diary.images.count > 0)], HAS_TAG: [NSNumber numberWithBool:(diary.tags.count > 0)], SHORT_TEXT: diary.text.length > 140 ? [diary.text substringToIndex:140] : diary.text, PLACE_NAME: [self filter:diary.placeName], PLACE_LONG: [NSNumber numberWithFloat:diary.placeLong], PLACE_LAT: [NSNumber numberWithFloat:diary.placeLat], WEATHER: [self filter:diary.placeName], CREATE_TIME: diary.createTime};
    [diaries addObject:diaryDictionary];
    return [self save];
}

- (BOOL)saveOnlineDiary:(EmotionDiary *)diary {
    NSDictionary *diaryDictionary;
    diaryDictionary = @{HAS_LOCAL_VERSION: [NSNumber numberWithBool:diary.hasLocalVersion], HAS_ONLINE_VERSION: [NSNumber numberWithBool:YES], DIARY_ID:[NSNumber numberWithInt:diary.diaryID], EMOTION: [NSNumber numberWithInt:diary.emotion], SELFIE: [self filter:diary.selfie], HAS_IMAGE: [NSNumber numberWithBool:diary.hasImage], HAS_TAG: [NSNumber numberWithBool:diary.hasTag], SHORT_TEXT: diary.shortText, PLACE_NAME: [self filter:diary.placeName], PLACE_LONG: [NSNumber numberWithFloat:diary.placeLong], PLACE_LAT: [NSNumber numberWithFloat:diary.placeLat], WEATHER: [self filter:diary.weather], CREATE_TIME: diary.createTime};
    [diaries addObject:diaryDictionary];
    return [self save];
}

- (NSString *)filter:(NSString *)string {
    return string == nil ? @"" : string;
}

- (BOOL)save {
    // Sort by time descending
    diaries = [NSMutableArray arrayWithArray:[diaries sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [obj2[CREATE_TIME] compare:obj1[CREATE_TIME]];
    }]];
    [[NSUserDefaults standardUserDefaults] setObject:diaries forKey:@"diaries"];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray<EmotionDiary *> *)getDiaryOfDate:(NSDate *)date {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in diaries) {
        NSDate *diaryDate = dict[CREATE_TIME];
        if ([[NSCalendar currentCalendar] isDate:diaryDate inSameDayAsDate:date]) {
            [result addObject:[self createEmotionDiaryFromDictionary:dict]];
        }else if ([date compare:diaryDate] == NSOrderedDescending) {
            break;
        }
    }
    return result;
}

- (NSArray<NSNumber *> *)getStatOfLastDays:(int)dayNumber {
    if (dayNumber <= 0) {
        return @[];
    }
    NSMutableArray *stat = [[NSMutableArray alloc] init];
    for (int i = 0; i < dayNumber; i++) {
        [stat addObject:@[]];
    }
    NSMutableArray *tempArr;
    for (NSDictionary *dict in diaries) {
        int dayToToday = [dict[CREATE_TIME] timeIntervalSinceNow] / (24 * 3600);
        if (dayToToday >= 0 && dayToToday < dayNumber) {
            tempArr = [stat[dayToToday] mutableCopy];
            [tempArr addObject:dict[EMOTION]];
            [stat setObject:tempArr atIndexedSubscript:dayToToday];
        }
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (int i = 0; i < dayNumber; i++) {
        NSDictionary *dict = stat[dayNumber - i - 1];
        int emotionAverage = 0;
        for (NSNumber *num in dict) {
            emotionAverage += [num intValue];
        }
        if (dict.count > 0) {
            emotionAverage /= dict.count;
        }
        result[i] = [NSNumber numberWithInt:emotionAverage];
    }
    return result;
}

@end
