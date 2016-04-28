//
//  EmotionDiary.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/27.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface EmotionDiary : NSObject <NSCoding>

@property BOOL hasLocalVersion;
@property BOOL hasOnlineVersion;

@property int emotion;
@property NSString *selfie;
@property NSArray *images;
@property NSArray *tags;
@property NSString *text;
@property NSString *placeName;
@property float placeLong;
@property float placeLat;
@property NSString *weather;
@property NSDate *createTime;

@property int diaryID;
@property BOOL hasImage;
@property BOOL hasTag;
@property NSString *shortText;

@end
