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
 * Get the view controller that the application is presenting
 * @return Current view controller
 */
+ (UIViewController *)getCurrentViewController;

/**
 * Get the view controller that the application is presenting with constraints
 * @param class The designated class
 * @param appearTime The time that the class can appear
 * @param canBeTop Whether the view controller can be the top view controller
 * @return Current view controller, nil if the view controller does not satisfy the contraints
 */
+ (UIViewController * _Nullable)getCurrentViewControllerWhileClass:(Class _Nullable)class appearsWithTime:(int)appearTime andCanBeTop:(BOOL)canBeTop;

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

/**
 * Check whether the path exists. If not, try to create one.
 
 * The root directory is the document directory
 * @param path The required path
 * @return Whether the path exists after the function
 */
+ (BOOL)checkAndCreatePath:(NSString *)path;

/**
 * Check whether the file exists at the given path
 
 * The root directory is the document directory
 * @param path The required path
 * @param name The file name
 * @return Whether the file exists
 */
+ (BOOL)fileExistsAtPath:(NSString *)path withName:(NSString *)name;

/**
 * Create file at the given path
 
 * The root directory is the document directory
 * @param data The data to be saved as file
 * @param path The required path
 * @param name The file name
 * @return Whether the file is created successfully
 */
+ (BOOL)createFile:(NSData *)data atPath:(NSString *)path withName:(NSString *)name;

/**
 * Get the file at the given path
 
 * The root directory is the document directory
 * @param path The required path
 * @param name The file name
 * @return The data of the file (if exists) or nil
 */
+ (NSData * _Nullable)getFileAtPath:(NSString *)path withName:(NSString *)name;

NS_ASSUME_NONNULL_END

@end
