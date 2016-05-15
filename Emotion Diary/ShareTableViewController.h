//
//  ShareTableViewController.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/15.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareTableViewController : UITableViewController {
    BOOL showNoDiary;
}

@property NSMutableArray<EmotionDiary *> *shareData;

@end
