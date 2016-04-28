//
//  Utilities.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/10.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "Utilities.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation Utilities

+ (NSString *)MD5:(NSString *)string {
    const char* cStr = [string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH]; // CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(cStr, (unsigned int)strlen(cStr), digist);
    NSMutableString *outPutStr = [NSMutableString stringWithCapacity:10];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [outPutStr appendFormat:@"%02X", digist[i]];// 小写 x 表示输出的是小写 MD5 ，大写 X 表示输出的是大写 MD5
    }
    return outPutStr;
}

+ (UIImage *)normalizedImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) {
        return image;
    }
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizeImage;
}

+ (NSData *)compressImage:(UIImage *)image toSize:(int)size {
    float ratio = 1.0;
    NSData *imageData = UIImageJPEGRepresentation(image, ratio);
    while (imageData.length >= size * 1024 && ratio >= 0.05) {
        ratio *= 0.75;
        imageData = UIImageJPEGRepresentation(image, ratio);
    }
    return imageData;
}

+ (NSDate *)getLocalDate:(NSDate *)date {
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:date];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:date];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date];
    return destinationDateNow;
}

+ (NSString *)getFaceNameBySmile:(int)smile {
    if (smile <= 33) {
        return @"不笑";
    }else if (smile <= 66) {
        return @"中笑";
    }else {
        return @"大笑";
    }
}

@end
