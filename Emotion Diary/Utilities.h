//
//  Utilities.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/10.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#define USER_DEFAULT [NSUserDefaults standardUserDefaults]
#define FILE_MANAGER [NSFileManager defaultManager]
// System version macros
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

NS_ASSUME_NONNULL_BEGIN

@interface Utilities : NSObject

/**
 * Calculate the MD5 value of a string
 * @param string The data to be calculated
 * @return MD5 encrypted string
 */
+ (NSString * _Nullable)MD5:(NSString * _Nullable)string;

/**
 * Check whether the string is a valid Email
 * @param email The string to be checked
 * @return Verification result
 */
+ (BOOL)isValidateEmail:(NSString *)email;

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
 * Open the URL in SFSafariViewController (iOS >= 9.0) or Safari (iOS < 9.0)
 * @param url The URL to open
 * @param viewController The view controller to present the SFSafariViewController
 */
+ (void)openURL:(NSURL *)url inViewController:(UIViewController *)viewController;

/**
 * Create an UIImage with the given color
 * @param color The color to create the image
 * @return UIImage with a 1.0f × 1.0f size
 */
+ (UIImage *)createImageWithColor:(UIColor *)color;

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
 * @remark The root directory is the document directory
 * @param path The required path
 * @return Whether the path exists after the function
 */
+ (BOOL)checkAndCreatePath:(NSString *)path;

/**
 * Check whether the file exists at the given path
 * @remark The root directory is the document directory
 * @param path The required path
 * @param name The file name
 * @return Whether the file exists
 */
+ (BOOL)fileExistsAtPath:(NSString *)path withName:(NSString *)name;

/**
 * Create file at the given path
 * @remark The root directory is the document directory
 * @param data The data to be saved as file
 * @param path The required path
 * @param name The file name
 * @return Whether the file is created successfully
 */
+ (BOOL)createFile:(NSData *)data atPath:(NSString *)path withName:(NSString *)name;

/**
 * Delete the file at the given path
 * @remark The root directory is the document directory
 * @param path The required path
 * @param name The file name
 * @return Whether the file is deleted successfully or YES if the file doesn't exist
 */
+ (BOOL)deleteFileAtPath:(NSString *)path withName:(NSString *)name;

/**
 * Get the file at the given path
 * @remark The root directory is the document directory
 * @param path The required path
 * @param name The file name
 * @return The data of the file (if exists) or nil
 */
+ (NSData * _Nullable)getFileAtPath:(NSString *)path withName:(NSString *)name;

NS_ASSUME_NONNULL_END

@end
