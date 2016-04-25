//
//  RecordTableViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "RecordTableViewController.h"
#import "UIImageEffects.h"
#import "KVNProgress.h"
#import "AssessmentHelper.h"
#import "Emotion_Diary-Swift.h"

@interface RecordTableViewController ()

@end

@implementation RecordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _selfieImage.image = _selfie;
    _selfieImage.layer.cornerRadius = _selfieImage.frame.size.width / 2;
    _blurredSelfieImage.image = [UIImageEffects imageByApplyingBlurToImage:_selfie withRadius:60.0 tintColor:[UIColor colorWithWhite:0.5 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
    _textRecord.delegate = self;
    _textRecord.scrollsToTop = NO;
    [self textViewDidChange:_textRecord];
    [self refreshView];
    [self analyseFace];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)analyseFace {
    FaceConnector *connector = [[FaceConnector alloc] init];
    [connector getDetailInfoOfFace:_faceID block:^(enum FaceConnectorRequestResult result, NSString * _Nonnull message, NSDictionary<NSString *,NSNumber *> * _Nullable info) {
        if (result == FaceConnectorRequestResultError) {
            [KVNProgress showErrorWithStatus:message];
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        faceInfo = info;
        [self refreshView];
    }];
}

- (void)refreshView {
    if (!faceInfo) {
        _faceImage.image = nil;
        _labelChickenSoup.text = @"正在分析您的心情";
    }else {
        _faceImage.image = [UIImage imageNamed:[AssessmentHelper getFaceNameBySmile:[faceInfo[@"smile"] intValue]]];
        _labelChickenSoup.text = [AssessmentHelper getWelcomeMsg:[faceInfo[@"smile"] intValue] withAttractive:[faceInfo[@"attractive"] intValue]];
    }
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    _placeholder.hidden = (textView.text.length > 0);
    self.navigationItem.rightBarButtonItem.enabled = (textView.text.length > 0);
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}
*/

/*
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}
*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"enterMain"]) {
        EmotionDiary *diary = [[EmotionDiary alloc] initWithSmile:[faceInfo[@"smile"] intValue] attractive:[faceInfo[@"attractive"] intValue] image:_selfie content:self.textRecord.text];
        [diary save];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
