//
//  RecordTableViewController.h
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>

#define NO_EMOTION -1

@interface RecordTableViewController : UITableViewController <UITextViewDelegate> {
    NSDictionary *faceInfo;
    NSMutableArray *images;
}

@property (strong, nonatomic) IBOutlet UIImageView *selfieImage;
@property (strong, nonatomic) IBOutlet UIImageView *blurredSelfieImage;
@property (strong, nonatomic) IBOutlet UIImageView *faceImage;
@property (strong, nonatomic) IBOutlet UILabel *placeholder;
@property (strong, nonatomic) IBOutlet UITextView *textRecord;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionImages;

@property UIImage *selfie;
@property int emotion;

@end
