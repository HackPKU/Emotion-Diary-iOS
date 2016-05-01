//
//  Utilities.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/10.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utilities : NSObject

/**
 * Calculate the MD5 value of a string
 * @param string The data to be calculated
 * @return MD5 encrypted string
 */
+ (NSString *)MD5:(NSString *)string;

/**
 * Normalize the image to the correct position
 * @param image The image to be normalized
 * @return Normalized image
 */
+ (UIImage *)normalizedImage:(UIImage *)image;

/**
 * Resize the image to required max width and height
 * @param image The image to be resized
 * @param max The max width and height
 * @return Resized image
 */
+ (UIImage *)resizeImage:(UIImage *)image toMaxWidthAndHeight:(NSInteger)max;

/**
 * Compress the image to required size
 * @param image The image to be resized
 * @param size The required size, in KB
 * @return Compressed image data
 */
+ (NSData *)compressImage:(UIImage *)image toSize:(int)size;

NS_ASSUME_NONNULL_END

@end
