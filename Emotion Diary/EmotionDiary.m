//
//  EmotionDiary.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/27.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "EmotionDiary.h"
#import "EmotionDiaryManager.h"

@implementation EmotionDiary

- (instancetype)initWithEmotion:(int)emotion selfie:(UIImage * _Nullable)selfie images:(NSArray<UIImage *> * _Nullable)images tags:(NSArray<NSString *> * _Nullable)tags text:(NSString *)text placeName:(NSString * _Nullable)placeName placeLong:(float)placeLong placeLat:(float)placeLat weather:(NSString * _Nullable)weather {
    self = [super init];
    if (self) {
        _emotion = emotion;
        _imageSelfie = selfie;
        _imageImages = images;
        _hasImage = (_images.count > 0);
        _tags = tags;
        _hasTag = (_tags.count > 0);
        _text = text;
        _placeName = placeName;
        _placeLong = placeLong;
        _placeLat = placeLat;
        _weather = weather;
        _createTime = [NSDate date];
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

- (void)writeToDiskWithBlock:(EmotionDiaryResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![Utilities checkAndCreatePath:SELFIE_PATH] || ![Utilities checkAndCreatePath:IMAGES_PATH] || ![Utilities checkAndCreatePath:DIARY_PATH]) {
            block(NO);
        }
        
        if (_imageSelfie) {
            NSString *selfieName;
            do {
                selfieName = [NSString stringWithFormat:@"%d", arc4random() % (int)1e8]; // Random number as file name
            }while ([Utilities fileExistsAtPath:SELFIE_PATH withName:selfieName]);
            if (![Utilities createFile:UIImageJPEGRepresentation(_imageSelfie, 0.3) atPath:SELFIE_PATH withName:selfieName]) {
                block(NO);
            }
            _selfie = selfieName;
        }
        
        NSMutableArray *imageNames = [[NSMutableArray alloc] init];
        for (UIImage *image in _imageImages) {
            NSString *imageName;
            do {
                imageName = [NSString stringWithFormat:@"%d", arc4random() % (int)1e8]; // Random number as file name
            }while ([Utilities fileExistsAtPath:IMAGES_PATH withName:imageName]);
            if (![Utilities createFile:UIImageJPEGRepresentation(image, 0.3) atPath:IMAGES_PATH withName:imageName]) {
                block(NO);
            }
            [imageNames addObject:imageName];
        }
        _images = imageNames;
        
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:self forKey:@"DIARY"];
        [archiver finishEncoding];
        NSString *fileName = [NSString stringWithFormat:@"%f", [_createTime timeIntervalSince1970]]; // Time as file name
        if (![Utilities createFile:data atPath:DIARY_PATH withName:fileName]) {
            block(NO);
        }
        // Save to NSUserDefaults
        if ([[EmotionDiaryManager sharedManager] saveLocalDiary:self]) {
            _hasLocalVersion = YES;
            block(YES);
        }else {
            block(NO);
        }
    });
}

- (EmotionDiary * _Nullable)fullVersion {
    NSString *fileName = [NSString stringWithFormat:@"%f", [_createTime timeIntervalSince1970]];
    NSData *diaryData = [Utilities getFileAtPath:DIARY_PATH withName:fileName];
    if (!diaryData) {
        return nil;
    }
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:diaryData];
    EmotionDiary *fullDiary = [unArchiver decodeObjectOfClass:[self class] forKey:@"DIARY"];
    
    if (!_hasOnlineVersion && fullDiary.selfie.length > 0) {
        fullDiary.imageSelfie = [UIImage imageWithData:[Utilities getFileAtPath:SELFIE_PATH withName:fullDiary.selfie]];
    }
    if (!_hasOnlineVersion && fullDiary.images.count > 0) {
        NSMutableArray<UIImage *> *imagesArray = [[NSMutableArray alloc] init];
        for (NSString *imageName in fullDiary.images) {
            [imagesArray addObject:[UIImage imageWithData:[Utilities getFileAtPath:IMAGES_PATH withName:imageName]]];
        }
        fullDiary.imageImages = imagesArray;
    }
    return fullDiary;
}

@end
