//
//  ver 0.6 updated by 范志康
//  ver 0.5 updated by 温凯
//
//  AssessmentHelper.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssessmentHelper : NSObject

+ (NSString *)getWelcomeMsg:(int) smile withAttractive:(int)attractive;
+ (NSString *)getFaceNameBySmile:(int) smile;

@end