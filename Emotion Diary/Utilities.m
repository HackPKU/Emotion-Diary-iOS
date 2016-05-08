//
//  Utilities.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/10.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "Utilities.h"
#import "AppDelegate.h"
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

+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRange range = [email rangeOfString:emailRegex options:NSRegularExpressionSearch];
    return (range.location != NSNotFound);
}

+ (UIViewController *)getCurrentViewController {
    return [Utilities getCurrentViewControllerWhileClass:nil appearsWithTime:0 andCanBeTop:YES];
}

+ (UIViewController * _Nullable)getCurrentViewControllerWhileClass:(Class _Nullable)class appearsWithTime:(int)appearTime andCanBeTop:(BOOL)canBeTop {
    UIViewController *view = ((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController;
    int time = [view isKindOfClass:class];
    while (view.childViewControllers.count > 0 || view.presentedViewController) {
        if (view.childViewControllers.count > 0) {
            for (UIViewController *childView in view.childViewControllers) {
                time += [childView isKindOfClass:class];
            }
            view = [view.childViewControllers lastObject];
        }else {
            view = view.presentedViewController;
            time += [view isKindOfClass:class];
        }
    }
    if (!class || (time == appearTime && (!canBeTop && ![view isKindOfClass:class]))) {
        return view;
    }
    return nil;
}

+ (UIImage *)createImageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
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

+ (UIImage *)resizeImage:(UIImage *)image toMaxWidthAndHeight:(NSInteger)max {
    if (image.size.width < max && image.size.height < max) {
        return image;
    }
    CGSize size;
    if (image.size.width > image.size.height) {
        size = CGSizeMake(max, (NSInteger)(max * image.size.height / image.size.width));
    }else {
        size = CGSizeMake((NSInteger)(max * image.size.width / image.size.height), max);
    }
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

+ (BOOL)checkAndCreatePath:(NSString *)path {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], path];
    BOOL isDirectory;
    if (![manager fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
        return [manager createDirectoryAtPath:fullPath withIntermediateDirectories:NO attributes:nil error:nil];
    }else {
        return isDirectory;
    }
}

+ (BOOL)fileExistsAtPath:(NSString *)path withName:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], path, name];
    BOOL isDirectory;
    if (![manager fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
        return NO;
    }else {
        return isDirectory;
    }
}

+ (BOOL)createFile:(NSData *)data atPath:(NSString *)path withName:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], path, name];
    if ([manager fileExistsAtPath:fullPath]) {
        return NO;
    }
    return [manager createFileAtPath:fullPath contents:data attributes:nil];
}

+ (NSData * _Nullable)getFileAtPath:(NSString *)path withName:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0], path, name];
    return [manager contentsAtPath:fullPath];
}

@end
