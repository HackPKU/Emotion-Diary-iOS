//
//  ver 0.6 updated by 范志康
//  ver 0.5 updated by 温凯
//  AssessmentHelper.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Updated by wenkai on 16/4/9
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "AssessmentHelper.h"

#define validSimleLowerLimit 1
#define lowSmileUpperLimit 33
#define moderateSmileUpperLimit 67
#define validSimleUpperLimit 100
#define validAttactiveLowerLimit 1
#define lowAttractiveUpperLimit 33
#define validAttactiveUpperLimit 100
#define moderateAttractiveUpperLimit 67

@implementation AssessmentHelper

+ (NSString *)getWelcomeMsg:(int) smile withAttractive:(int)attractive{
    NSString * welcomeHint = [self getWelcomeHint:smile withAttractive:attractive ];
    NSString * psychWelcome = [self getRandomPsychWelcome];
    return [[welcomeHint stringByAppendingString:@"\n"] stringByAppendingString:psychWelcome];
}

+ (NSString *)getWelcomeHint:(int) smile withAttractive:(int) attractive{
    // classify by smileDegreee and attactive
    if(![self isSmileValid:smile] || ![self isAttractiveValid:attractive]){
        NSLog(@"输入了非法的smile或attractive");
        return @"你好~";
    }
    
    int randSelecct = arc4random() % 100; // 产生一个0~99的随机数来确定呈现哪句话？
    if(smile <= lowSmileUpperLimit){ // 小笑容
        if(attractive <= lowAttractiveUpperLimit){ // 小颜值
            if(randSelecct < 50){
                return @"Hi~ 我等你好久啦~";
            }else{
                return @"我也对你微笑呢 : -)";
            }
        }else if(attractive <= moderateAttractiveUpperLimit){ // 中颜值
            if(randSelecct < 50){
                return @"你今天很漂亮呢~";
            }else{
                return @"今天有什么开心事吗？";
            }
        }else{ // 高颜值
            if(randSelecct < 50){
                int randPercent = arc4random()%5 + attractive - 5;
                return [NSString stringWithFormat:@"不错呦，你的颜值击败了%d%%的用户~~",randPercent];
            }else{
                return @"你今天把我都迷倒了呢（害羞）";
            }
        }
    }
    else if(smile <= moderateSmileUpperLimit){
        if(attractive <= lowAttractiveUpperLimit){
            if(randSelecct < 50){
                return @"你笑的很标准呢 : -) ";
            }else{
                return @"今天遇到了开心事吧 嘿嘿~";
            }
        }else if(attractive <= moderateAttractiveUpperLimit){ // 中颜值
            if(randSelecct < 50){
                return @"想写点什么吗？";
            }else{
                return @"保持微笑的表情可以使人心情舒畅哦";
            }
        }else { // 高颜值
            if(randSelecct < 50){
                int randPercent = arc4random()%5 + attractive - 5;
                return [NSString stringWithFormat:@"不错呦，你的颜值击败了%d%%的用户~~", randPercent];
            }else {
                return @"迷人的笑容  ⁄(⁄ ⁄•⁄ω⁄•⁄ ⁄)⁄";
            }
        }
    }else{
        if(attractive <=lowAttractiveUpperLimit){
            if(randSelecct < 50){
                return @"你笑得好！开！心！啊！";
            }else{
                return @"笑吧！！";
            }
        }else if(attractive <= moderateAttractiveUpperLimit){ // 中颜值
            if(randSelecct < 50){
                return @"你的颜值吓到我啦";
            }else{
                return @"开心~~";
            }
        }else{ // 高颜值
            if(randSelecct < 50){
                int randPercent = arc4random()%5 + attractive - 5;
                return [NSString stringWithFormat:@"不错呦，你的颜值击败了%d%%的用户~~", randPercent];
            }else{
                return @"笑得太厉害会岔气哦~~~";
            }
        }
    }
}

+ (BOOL) isSmileValid:(int) smile{
    return (smile >= validSimleLowerLimit && smile <= validSimleUpperLimit );
}

+ (BOOL) isAttractiveValid:(int) attractive{
    return (attractive >= validAttactiveLowerLimit && attractive <= validAttactiveUpperLimit);
}

+ (NSString *)getRandomPsychWelcome{
    NSArray * psychWelcomeArray = @[@"一颗积极的心，会为自己带来意想不到的收获",
                                    @"一个不欣赏自己的人是难以快乐的",
                                    @"一个有信念者所发出的力量大于九十九个只有兴趣者",
                                    @"聪明的人善说，智慧的人善听，高明的人善问",
                                    @"心情再不好也要给自己一个灿烂的微笑",
                                    @"当你拥有一颗快乐的心那么你就拥有了整个世界",
                                    @"我们总是以自己的喜好来判断他人的喜好",
                                    @"爱情三要素：激情、友情和承诺",
                                    @"结婚三要素：物质、感情、婚后生活"];
    int NpsychWelcome = (int)[psychWelcomeArray count];
    int randSelecct = arc4random()%NpsychWelcome;
    return psychWelcomeArray[randSelecct];
}


+ (NSString *)getFaceNameBySmile:(int) smile{
    if(smile <= lowSmileUpperLimit){
        return @"不笑";
    }else if(smile <= moderateSmileUpperLimit){
        return @"中笑";
    }else{
        return @"大笑";
    }
}

@end
