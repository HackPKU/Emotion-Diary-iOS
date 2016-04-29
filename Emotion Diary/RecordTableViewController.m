//
//  RecordTableViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "RecordTableViewController.h"
#import "UIImageEffects.h"
#import "Emotion_Diary-Swift.h"

#define MAX_PICTURE_NUM 9

@interface RecordTableViewController ()

@end

@implementation RecordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    images = [[NSMutableArray alloc] init];
    _selfieImage.image = _selfie;
    _selfieImage.layer.cornerRadius = _selfieImage.frame.size.width / 2;
    _blurredSelfieImage.image = [UIImageEffects imageByApplyingBlurToImage:_selfie withRadius:60.0 tintColor:[UIColor colorWithWhite:0.5 alpha:0.5] saturationDeltaFactor:1.8 maskImage:nil];
    _textRecord.scrollsToTop = NO;
    if (_emotion == NO_EMOTION) {
        _emotion = 50;
    }
    _faceImage.image = [UIImage imageNamed:[Utilities getFaceNameByEmotion:_emotion]];
    [self textViewDidChange:_textRecord];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text View Delegate

- (void)textViewDidChange:(UITextView *)textView {
    _placeholder.hidden = (textView.text.length > 0);
    self.navigationItem.rightBarButtonItem.enabled = (textView.text.length > 0);
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 3:
            NSLog(@"Place");
            break;
        case 4:
            NSLog(@"Weather");
            break;
        default:
            break;
    }
}

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

#pragma mark - Collection view delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(MAX_PICTURE_NUM, images.count + 1);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < images.count) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"image" forIndexPath:indexPath];
        return cell;
    }else {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"upload" forIndexPath:indexPath];
    }
}

#pragma mark - Navigation

- (IBAction)cancel:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)done:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"enterMain"]) {
        EmotionDiarySwift *diary = [[EmotionDiarySwift alloc] initWithSmile:[faceInfo[@"smile"] intValue] attractive:[faceInfo[@"attractive"] intValue] image:_selfie content:self.textRecord.text];
        [diary save];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
