//
//  AssessmentHelper.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "AssessmentHelper.h"

@implementation AssessmentHelper

+ (NSString *)getAssessment:(int) smileDegree {
    if (smileDegree < 20) {
        return @"不要灰心";
    }else {
        return @"你真棒";
    }
}

@end
