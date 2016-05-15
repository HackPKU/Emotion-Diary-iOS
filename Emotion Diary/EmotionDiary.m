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
        _shortText = (text.length > 140) ? [text substringToIndex:139] : text;
        _placeName = placeName;
        _placeLong = placeLong;
        _placeLat = placeLat;
        _weather = weather;
        _createTime = [NSDate date];
        _isShared = NO;
        _diaryID = NO_DIARY_ID;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
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
        _isShared = [aDecoder decodeBoolForKey:IS_SHARED];
        
        _diaryID = [aDecoder decodeIntForKey:DIARY_ID];
        _hasImage = [aDecoder decodeBoolForKey:HAS_IMAGE];
        _hasTag = [aDecoder decodeBoolForKey:HAS_TAG];
        _shortText = [aDecoder decodeObjectForKey:SHORT_TEXT];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
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
    [aCoder encodeBool:_isShared forKey:IS_SHARED];
    
    [aCoder encodeInt:_diaryID forKey:DIARY_ID];
    [aCoder encodeBool:_hasImage forKey:HAS_IMAGE];
    [aCoder encodeBool:_hasTag forKey:HAS_TAG];
    [aCoder encodeObject:_shortText forKey:SHORT_TEXT];
}

- (BOOL)hasOnlineVersion {
    return (_diaryID != NO_DIARY_ID);
}

- (NSString *)getFileName {
    // 创建时间作为本地文件名，时间精确到秒，以与服务器兼容
    return [Utilities MD5:[[[EmotionDiaryManager sharedManager] PRCDateFormatter] stringFromDate:_createTime]];
}

- (void)writeToDiskWithBlock:(EmotionDiaryResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![Utilities checkAndCreatePath:SELFIE_PATH] || ![Utilities checkAndCreatePath:IMAGES_PATH] || ![Utilities checkAndCreatePath:DIARY_PATH]) {
            block(NO, @"创建目录失败", nil);
            return;
        }
        
        if (!self.hasOnlineVersion) {
            // 图片文件名使用随机数字
            if (_imageSelfie) {
                NSString *selfieName;
                do {
                    selfieName = [NSString stringWithFormat:@"%d", arc4random() % (int)1e8];
                }while ([Utilities fileExistsAtPath:SELFIE_PATH withName:selfieName]);
                if (![Utilities createFile:UIImageJPEGRepresentation(_imageSelfie, 0.25) atPath:SELFIE_PATH withName:selfieName]) {
                    block(NO, @"自拍文件写入失败", nil);
                    return;
                }
                _selfie = selfieName;
            }
            
            NSMutableArray *imageNames = [NSMutableArray new];
            for (UIImage *image in _imageImages) {
                NSString *imageName;
                do {
                    imageName = [NSString stringWithFormat:@"%d", arc4random() % (int)1e8];
                }while ([Utilities fileExistsAtPath:IMAGES_PATH withName:imageName]);
                if (![Utilities createFile:UIImageJPEGRepresentation(image, 0.25) atPath:IMAGES_PATH withName:imageName]) {
                    block(NO, @"图片文件写入失败", nil);
                    return;
                }
                [imageNames addObject:imageName];
            }
            _images = imageNames;
        }
        
        NSMutableData *data = [NSMutableData new];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:self forKey:@"DIARY"];
        [archiver finishEncoding];
        NSString *fileName = [self getFileName];
        if ([Utilities fileExistsAtPath:DIARY_PATH withName:fileName]) {
            [Utilities deleteFileAtPath:DIARY_PATH withName:fileName];
        }
        if (![Utilities createFile:data atPath:DIARY_PATH withName:fileName]) {
            block(NO, @"日记文件写入失败", nil);
            return;
        }
        // Save to NSUserDefaults
        if ([[EmotionDiaryManager sharedManager] saveDiary:self]) {
            block(YES, nil, self);
        }else {
            block(NO, @"日记记录创建失败", nil);
        }
    });
}

- (void)uploadToServerWithBlock:(EmotionDiaryResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self.hasOnlineVersion) {
            block(NO, @"该日记已上传", nil);
            return;
        }
        NSString *selfie = _selfie;
        NSArray *images = _images;
        [self getFullVersionWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
            if (!success) {
                block(NO, message, nil);
                return;
            }
            [self uploadSelfieWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
                if (!success) {
                    block(NO, message, nil);
                    return;
                }
                [self uploadImagesWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
                    if (!success) {
                        _selfie = selfie;
                        block(NO, message, nil);
                        return;
                    }
                    [ActionPerformer postDiary:self andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                        if (!success) {
                            _selfie = selfie;
                            _images = images;
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                block(NO, message, nil);
                            });
                            return;
                        }
                        _diaryID = [data[@"diaryid"] intValue];
                        [self writeToDiskWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
                            if (success) {
                                [Utilities deleteFileAtPath:SELFIE_PATH withName:selfie];
                                for (NSString *image in images) {
                                    [Utilities deleteFileAtPath:IMAGES_PATH withName:image];
                                }
                                block(YES, nil, self);
                            }else {
                                _selfie = selfie;
                                _images = images;
                                _diaryID = NO_DIARY_ID;
                                block(NO, message, nil);
                            }
                            
                        }];
                    }];
                }];
            }];
        }];
    });
}

- (void)uploadSelfieWithBlock:(EmotionDiaryResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (!_imageSelfie) {
            block(YES, nil, self);
            return;
        }
        [ActionPerformer uploadImage:_imageSelfie type:EmotionDiaryImageTypeSelfie andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (!success) {
                    block(NO, message, nil);
                    return;
                }
                _selfie = data[@"file_name"];
                block(YES, nil, self);
            });
        }];
    });
}

- (void)uploadImagesWithBlock:(EmotionDiaryResultBlock)block {
    NSArray *images = _images;
    [self uploadImage:0 WithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
        if (!success) {
            _images = images;
            block(NO, message, nil);
            return;
        }
        block(YES, nil, self);
    }];
}

- (void)uploadImage:(NSInteger)index WithBlock:(EmotionDiaryResultBlock)block {
    if (index == _imageImages.count) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(YES, nil, self);
        });
        return;
    }
    UIImage *imageToUpload = _imageImages[index];
    [ActionPerformer uploadImage:imageToUpload type:EmotionDiaryImageTypeImage andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
        if (!success) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                block(NO, message, nil);
            });
            return;
        }
        NSMutableArray *images = [_images mutableCopy];
        [images replaceObjectAtIndex:index withObject:data[@"file_name"]];
        _images = images;
        [self uploadImage:index + 1 WithBlock:block];
    }];
}

- (void)getFullVersionWithBlock:(EmotionDiaryResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_text.length > 0 && _images && _imageSelfie && _imageImages && _tags) {
            // Already has full version
            block(YES, nil, self);
            return;
        }
        
        if (self.hasOnlineVersion && [ActionPerformer hasLoggedIn]) {
            [ActionPerformer viewDiaryWithDiaryID:_diaryID shareKey:nil andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
                if (!success) {
                    // 网络加载失败时尝试本地读取
                    [self getLocalFullVersionWithBlock:block];
                    return;
                }
                
                _emotion = [data[@"emotion"] intValue];
                _selfie = data[@"selfie"];
                _images = data[@"images"];
                if (![_images isKindOfClass:[NSArray class]]) {
                    _images = [NSArray new];
                }
                _hasImage = (_images.count > 0);
                _tags = data[@"tags"];
                if (![_tags isKindOfClass:[NSArray class]]) {
                    _tags = [NSArray new];
                }
                _hasTag = (_tags.count > 0);
                NSString *text = data[@"text"];
                _text = text;
                _shortText = (text.length > 140) ? [text substringToIndex:139] : text;
                _placeName = data[@"place_name"];
                _placeLong = [data[@"place_long"] floatValue];
                _placeLat = [data[@"place_lat"] floatValue];
                _weather = data[@"weather"];
                _createTime = [[[EmotionDiaryManager sharedManager] PRCDateFormatter] dateFromString:data[@"create_time"]];
                _isShared = [data[@"is_shared"] boolValue];
                
                [self writeToDiskWithBlock:block];
            }];
        }else {
            [self getLocalFullVersionWithBlock:block];
        }
    });
}

- (void)getLocalFullVersionWithBlock:(EmotionDiaryResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *diaryData = [Utilities getFileAtPath:DIARY_PATH withName:[self getFileName]];
        if (diaryData) {
            NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:diaryData];
            EmotionDiary *fullDiary = [unArchiver decodeObjectOfClass:[self class] forKey:@"DIARY"];
            
            _text = fullDiary.text;
            _images = fullDiary.images;
            _tags = fullDiary.tags;
            _isShared = fullDiary.isShared;
            
            if (_selfie.length > 0) {
                UIImage *selfie = [UIImage imageWithData:[Utilities getFileAtPath:SELFIE_PATH withName:_selfie]];
                if (selfie) {
                    _imageSelfie = selfie;
                }
            }
            if (_images.count > 0) {
                NSMutableArray<UIImage *> *imagesArray = [NSMutableArray new];
                for (NSString *imageName in _images) {
                    UIImage *image = [UIImage imageWithData:[Utilities getFileAtPath:IMAGES_PATH withName:imageName]];
                    if (image) {
                        [imagesArray addObject:image];
                    }
                }
                if (imagesArray.count == _images.count) {
                    _imageImages = imagesArray;
                }
            }
            
            block(YES, nil, self);
        }else {
            block(NO, @"本地日记文件载入失败", nil);
        }
    });
}

- (void)shareWithBlock:(EmotionDiaryResultBlock)block {
    [ActionPerformer shareDiaryWithDiaryID:_diaryID andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
        if (!success) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                block(NO, message, nil);
            });
            return;
        }
        BOOL shareBackup = _isShared;
        _isShared = YES;
        NSString *shareKey = data[@"share_key"];
        [self writeToDiskWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
            if (!success) {
                _isShared = shareBackup;
                block(NO, message, nil);
                return;
            }
            block(YES, nil, [NSURL URLWithString:[NSString stringWithFormat:@"%@/web/diary/?diaryid=%d&share_key=%@", [ActionPerformer getServerUrl], _diaryID, shareKey]]);
        }];
    }];
}

- (void)unshareWithBlock:(EmotionDiaryResultBlock)block {
    [ActionPerformer unshareDiaryWithDiaryID:_diaryID andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
        if (!success) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                block(NO, message, nil);
            });
            return;
        }
        BOOL shareBackup = _isShared;
        _isShared = NO;
        [self writeToDiskWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
            if (!success) {
                _isShared = shareBackup;
                block(NO, message, nil);
                return;
            }
            block(YES, nil, nil);
        }];
    }];
}

- (void)deleteWithBlock:(EmotionDiaryResultBlock)block {
    if (self.hasOnlineVersion) {
        [ActionPerformer deleteDiaryWithDiaryID:_diaryID andBlock:^(BOOL success, NSString * _Nullable message, NSDictionary * _Nullable data) {
            if (!success) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    block(NO, message, nil);
                });
                return;
            }
            [self deleteLocalVersionWithBlock:block];
        }];
    }else {
        [self deleteLocalVersionWithBlock:block];
    }
}

- (void)deleteLocalVersionWithBlock:(EmotionDiaryResultBlock)block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [Utilities deleteFileAtPath:DIARY_PATH withName:[self getFileName]];
        if (_selfie.length > 0) {
            [Utilities deleteFileAtPath:SELFIE_PATH withName:_selfie];
        }
        if (_images.count > 0) {
            for (NSString *imageName in _images) {
                [Utilities deleteFileAtPath:IMAGES_PATH withName:imageName];
            }
        }
        if ([[EmotionDiaryManager sharedManager] deleteDiary:self]) {
            block(YES, nil, nil);
        }else {
            block(NO, @"日记记录删除失败", nil);
        }
    });
}

@end
