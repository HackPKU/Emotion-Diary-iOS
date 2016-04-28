//
//  EmotionDiary.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/27.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "EmotionDiary.h"

#define HAS_LOCAL_VERSION @"hasLocalVersion"
#define HAS_ONLINE_VERSION @"hasOnlineVersion"

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

#define USER_ID @"userID"
#define DIARY_ID @"diaryID"
#define HAS_IMAGE @"hasImage"
#define HAS_TAG @"hasTag"
#define SHORT_TEXT @"shortText"

@implementation EmotionDiary

- (instancetype)initWithEmotion:(int)emotion selfie:(UIImage *)selfie images:(NSArray *)images tags:(NSArray *)tags text:(NSString *)text placeName:(NSString *)placeName placeLong:(float)placeLong placeLat:(float)placeLat weather:(NSString *)weather {
    self = [super init];
    if (self) {
        _emotion = emotion;
        // TODO: selfie and images
        _tags = tags;
        _text = text;
        _placeName = placeName;
        _placeLong = placeLong;
        _placeLat = placeLat;
        _weather = weather;
        _createTime = [NSDate date];
        _hasLocalVersion = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _hasLocalVersion = [aDecoder decodeBoolForKey:HAS_LOCAL_VERSION];
        _hasOnlineVersion = [aDecoder decodeBoolForKey:HAS_ONLINE_VERSION];
        
        _emotion = [aDecoder decodeIntForKey:EMOTION];
        _selfie = [aDecoder decodeObjectForKey:SELFIE];
        _images = [aDecoder decodeObjectForKey:IMAGES];
        _tags = [aDecoder decodeObjectForKey:TAGS];
        _text = [aDecoder decodeObjectForKey:TEXT];
        _placeName = [aDecoder decodeObjectForKey:PLACE_NAME];
        _placeLong = [aDecoder decodeFloatForKey:PLACE_LONG];
        _placeLat = [aDecoder decodeFloatForKey:PLACE_LAT];
        _weather = [aDecoder decodeObjectForKey:WEATHER];
        _createTime = [aDecoder decodeObjectForKey:CREATE_TIME];
        
        _userID = [aDecoder decodeIntForKey:USER_ID];
        _diaryID = [aDecoder decodeIntForKey:DIARY_ID];
        _hasImage = [aDecoder decodeBoolForKey:HAS_IMAGE];
        _hasTag = [aDecoder decodeBoolForKey:HAS_TAG];
        _shortText = [aDecoder decodeObjectForKey:SHORT_TEXT];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeBool:_hasLocalVersion forKey:HAS_LOCAL_VERSION];
    [aCoder encodeBool:_hasOnlineVersion forKey:HAS_ONLINE_VERSION];
    
    [aCoder encodeInt:_emotion forKey:EMOTION];
    [aCoder encodeObject:_selfie forKey:SELFIE];
    [aCoder encodeObject:_images forKey:IMAGES];
    [aCoder encodeObject:_tags forKey:TAGS];
    [aCoder encodeObject:_text forKey:TEXT];
    [aCoder encodeObject:_placeName forKey:PLACE_NAME];
    [aCoder encodeFloat:_placeLong forKey:PLACE_LONG];
    [aCoder encodeFloat:_placeLat forKey:PLACE_LAT];
    [aCoder encodeObject:_weather forKey:WEATHER];
    [aCoder encodeObject:_createTime forKey:CREATE_TIME];
    
    [aCoder encodeInt:_userID forKey:USER_ID];
    [aCoder encodeInt:_diaryID forKey:DIARY_ID];
    [aCoder encodeBool:_hasImage forKey:HAS_IMAGE];
    [aCoder encodeBool:_hasTag forKey:HAS_TAG];
    [aCoder encodeObject:_shortText forKey:SHORT_TEXT];
}

@end
