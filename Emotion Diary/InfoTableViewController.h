//
//  InfoTableViewController.h
//  Emotion Diary
//
//  Created by 范志康 on 16/5/10.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

@interface InfoTableViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, MWPhotoBrowserDelegate> {
    int imagePickerState;
    NSString *password;
}

@property (strong, nonatomic) IBOutlet UIImageView *imageIconBlurred;
@property (strong, nonatomic) IBOutlet UIImageView *imageIcon;
@property (strong, nonatomic) IBOutlet UILabel *labelUserName;

@property (strong, nonatomic) IBOutlet UIButton *buttonEdit;
@property (strong, nonatomic) IBOutlet UIButton *buttonResetFace;
@property (strong, nonatomic) IBOutlet UIButton *buttonLogout;

@end
