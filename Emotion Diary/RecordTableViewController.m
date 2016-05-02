//
//  RecordTableViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "RecordTableViewController.h"
#import "RecordCollectionViewCell.h"
#import "WelcomeViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

#define MAX_PICTURE_NUM 9

@interface RecordTableViewController ()

@end

@implementation RecordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    images = [[NSMutableArray alloc] init];
    showCamera = YES;
    _imageSelfie.layer.cornerRadius = _imageSelfie.frame.size.width / 2;
    [self setSelfieImage];
    
    if (_emotion == NO_EMOTION) {
        _emotion = 50;
    }
    _sliderEmotion.value = _emotion;
    _sliderEmotion.userInteractionEnabled = _selfie ? NO : YES;
    _sliderEmotion.alpha = _selfie ? 0.0 : 1.0;
    [self updateEmotion];
    
    _textRecord.scrollsToTop = NO;
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

- (void)setSelfieImage {
    UIImage *displaySelfie = _selfie;
    if (!displaySelfie) {
        displaySelfie = PLACEHOLDER_IMAGE;
    }
    _imageSelfie.image = displaySelfie;
    _imageSelfieBlurred.image = displaySelfie;
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

#pragma mark - Emotion adjust

- (IBAction)showEmotionSlider:(id)sender {
    _sliderEmotion.userInteractionEnabled = !_sliderEmotion.userInteractionEnabled;
    [UIView animateWithDuration:0.3 animations:^{
        _sliderEmotion.alpha = 1 - _sliderEmotion.alpha;
    }];
}

- (IBAction)emotionChanged:(UISlider *)sender {
    _emotion = (int)sender.value;
    [self updateEmotion];
}

- (void)updateEmotion {
    [_buttonFace setImage:[UIImage imageNamed:[ActionPerformer getFaceNameByEmotion:_emotion]] forState:UIControlStateNormal];
}

#pragma mark - Image picker collection view

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(MAX_PICTURE_NUM, images.count + showCamera);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < images.count) {
        RecordCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"image" forIndexPath:indexPath];
        cell.imagePhoto.image = images[indexPath.row];
        return cell;
    }else {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"select" forIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [collectionView numberOfItemsInSection:0] - 1) {
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.enableGrid = YES;
        browser.displayActionButton = NO;
        [browser setCurrentPhotoIndex:indexPath.row];
        [self.navigationController pushViewController:browser animated:YES];
    }
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return images.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < images.count) {
        return [MWPhoto photoWithImage:images[index]];
    }
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return [self photoBrowser:photoBrowser photoAtIndex:index];
}

- (IBAction)deletePhoto:(id)sender {
    RecordCollectionViewCell *cell = (RecordCollectionViewCell *)[[sender superview] superview];
    NSInteger row = [_collectionImages indexPathForCell:cell].row;
    [images removeObjectAtIndex:row];
    if (images.count < MAX_PICTURE_NUM - 1) {
        [_collectionImages deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
    }else { // Add button replaces the last image
        showCamera = NO;
        [_collectionImages deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]]];
        showCamera = YES;
        [_collectionImages performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }
}

- (IBAction)addPhoto:(UIButton *)sender {
    UIAlertController *action = [UIAlertController alertControllerWithTitle:@"选择图片来源" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [action addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }]];
    }
    [action addAction:[UIAlertAction actionWithTitle:@"照片图库" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self presentImagePicker:sender];
    }]];
    [action addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    action.popoverPresentationController.sourceView = sender;
    action.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:action animated:YES completion:nil];
}

- (void)addImage:(UIImage *)image {
    [images addObject:image];
    [_collectionImages reloadData];
    
    // Scroll to newly added image
    [_collectionImages scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[_collectionImages numberOfItemsInSection:0] - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self addImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
}

- (void)presentImagePicker:(UIButton *)sender {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
            picker.delegate = self;
            picker.showsEmptyAlbums = NO;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                picker.modalPresentationStyle = UIModalPresentationPopover;
                picker.popoverPresentationController.sourceView = sender;
                picker.popoverPresentationController.sourceRect = sender.bounds;
            }
            [self presentViewController:picker animated:YES completion:nil];
        });
    }];
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [picker dismissViewControllerAnimated:YES completion:^{
        for (PHAsset *asset in assets) {
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.version = PHImageRequestOptionsVersionCurrent;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.synchronous = YES;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
                [self addImage:[UIImage imageWithData:imageData]];
            }];
        }
    }];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset {
    NSInteger max = MAX_PICTURE_NUM - images.count;
    if (picker.selectedAssets.count >= max) {
        [KVNProgress showErrorWithStatus:[NSString stringWithFormat:@"您最多可以选择%d张图片", MAX_PICTURE_NUM]];
    }
    return (picker.selectedAssets.count < max);
}

#pragma mark - Navigation

- (IBAction)cancel:(id)sender {
    if (_textRecord.text.length > 0 || images.count > 0) {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:@"警告" message:@"您编辑了内容，确定要退出吗？" preferredStyle:UIAlertControllerStyleAlert];
        [action addAction:[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }]];
        [action addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:action animated:YES completion:nil];
        return;
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    EmotionDiary *diary = [[EmotionDiary alloc] initWithEmotion:(int)_sliderEmotion.value selfie:_selfie images:images tags:nil text:_textRecord.text placeName:nil placeLong:0.0 placeLat:0.0 weather:nil];
    [KVNProgress showWithStatus:@"日记保存中"];
    [diary saveToDiskWithBlock:^(BOOL success) {
        if (success) {
            [KVNProgress showSuccessWithStatus:@"日记保存成功"];
        }else {
            [KVNProgress showErrorWithStatus:@"日记保存失败"];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"enterMain" object:nil];
        }];
    }];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
