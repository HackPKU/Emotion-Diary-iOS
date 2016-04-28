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
 * Resize the image to required size
 * @param image The image to be resized
 * @param size The required size
 * @return Resized image
 */
+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size;

/**
 * Compress the image to required size
 * @param image The image to be resized
 * @param size The required size, in KB
 * @return Compressed image data
 */
+ (NSData *)compressImage:(UIImage *)image toSize:(int)size;

/**
 * Get the local date from UTC date
 * @param date UTC date
 * @return Local date
 */
+ (NSDate *)getLocalDate:(NSDate *)date;

/**
 * Get the face name of a given smile value
 * @param smile The smile value
 * @return Face name
 */
+ (NSString *)getFaceNameBySmile:(int)smile;

NS_ASSUME_NONNULL_END

@end
