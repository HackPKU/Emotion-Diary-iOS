//
//  DiaryTableViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/2.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "DiaryTableViewController.h"

#define BROWSE_SELFIE 1
#define BROWSE_IMAGE 2

@interface DiaryTableViewController ()

@end

@implementation DiaryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageSelfie.layer.cornerRadius = _imageSelfie.frame.size.width / 2;
    _cycleImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _cycleImageView.layer.shadowOffset = CGSizeZero;
    _cycleImageView.layer.shadowOpacity = 0.75;
    _cycleImageView.layer.shadowRadius = 6.0;
    imageViews = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:UPLOAD_PROGRESS_CHANGED_NOTIFOCATION object:nil];
    
    [self updateDiaryView];
    // TODO: 下拉刷新
        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getFullVersion];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_cycleImageView startTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_cycleImageView stopTimer];
}

- (void)refresh:(NSNotification *)noti {
    if (_diary.diaryID == NO_DIARY_ID || [noti.userInfo[DIARY_ID] intValue] == _diary.diaryID) {
        [self getFullVersion];
    }
}

- (void)getFullVersion {
    // 先读取本地文件
    [_diary getLocalFullVersionWithBlock:^(BOOL successLocal, NSString * _Nullable message, NSObject * _Nullable data) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            // 如果存在在线版，则读取在线日记
            if (_diary.hasOnlineVersion) {
                [_diary getOnlineFullVersionWithBlock:^(BOOL successOnline, NSString * _Nullable message, NSObject * _Nullable data) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        if (!successOnline && !successLocal) {
                            [KVNProgress showErrorWithStatus:message];
                            return;
                        }
                        if (successOnline) {
                            [self updateDiaryView];
                        }
                    });
                }];
            }else {
                if (!successLocal) {
                [KVNProgress showErrorWithStatus:message];
                    return;
                }
            }
            [self updateDiaryView];
        });
    }];
}

- (void)updateDiaryView {
    if (_diary.selfie.length > 0) {
        if (_diary.hasOnlineVersion) {
            [_imageSelfie sd_setImageWithURL:[ActionPerformer getImageURLWithName:_diary.selfie type:EmotionDiaryImageTypeSelfie] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageProgressiveDownload];
        }else {
            _imageSelfie.image = _diary.imageSelfie;
        }
    }else {
        _imageSelfie.image = PLACEHOLDER_IMAGE;
    }
    _imageFace.image = [ActionPerformer getFaceImageByEmotion:_diary.emotion];
    _labelEmotion.text = [NSString stringWithFormat:@"心情指数 %d", _diary.emotion];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"M月d日 HH:mm"];
    _labelDateAndTime.text = [formatter stringFromDate:_diary.createTime];
    _textDetail.text = _diary.text;
    
    _cycleImageView.pageControl.hidden = (_diary.images.count <= 1);
    [imageViews removeAllObjects];
    [self.tableView reloadData];
    [_cycleImageView reloadData];
}

#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2 + (_diary.images.count > 0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 130.0;
    }else if (indexPath.row == 1) {
        // 根据 AutoLayout 自动计算高度
        CGFloat height = [_textDetail systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return height + 17.0; // 8.0 + 8.0 + 1.0, 1.0 是分割线高度
    }else if (indexPath.row == 2){
        return 250.0;
    }
    return 0.0;
}

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

#pragma mark - ZYBannerView data source

- (NSInteger)numberOfItemsInBanner:(ZYBannerView *)banner {
    return _diary.images.count;
}

- (UIView *)banner:(ZYBannerView *)banner viewForItemAtIndex:(NSInteger)index {
    while (imageViews.count <= index) {
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageViews addObject:imageView];
    }
    
    UIImageView *imageView = imageViews[index];
    if (_diary.hasOnlineVersion) {
        [imageView sd_setImageWithURL:[ActionPerformer getImageURLWithName:_diary.images[index] type:EmotionDiaryImageTypeImage] placeholderImage:PLACEHOLDER_IMAGE options:SDWebImageProgressiveDownload];
    }else {
        imageView.image = _diary.imageImages[index];
    }
    return imageView;
}

#pragma mark - ZYBannerView delegate

- (void)banner:(ZYBannerView *)banner didSelectItemAtIndex:(NSInteger)index {
    imageBrowserMode = BROWSE_IMAGE;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.enableGrid = YES;
    [browser setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - MWPhotoBrowser delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    switch (imageBrowserMode) {
        case BROWSE_SELFIE:
            return 1;
        case BROWSE_IMAGE:
            return _diary.images.count;
        default:
            return 0;
    }
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    switch (imageBrowserMode) {
        case BROWSE_SELFIE:
            if (_diary.hasOnlineVersion) {
                return [MWPhoto photoWithURL:[ActionPerformer getImageURLWithName:_diary.selfie type:EmotionDiaryImageTypeSelfie]];
            }else {
                return [MWPhoto photoWithImage:_imageSelfie.image];
            }
        case BROWSE_IMAGE:
            if (index < _diary.images.count) {
                if (_diary.hasOnlineVersion) {
                    return [MWPhoto photoWithURL:[ActionPerformer getImageURLWithName:_diary.images[index] type:EmotionDiaryImageTypeImage]];
                }else {
                    return [MWPhoto photoWithImage:_diary.imageImages[index]];
                }
            }
            return nil;
        default:
            return nil;
    }
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return [self photoBrowser:photoBrowser photoAtIndex:index];
}

- (IBAction)touchSelfie:(id)sender {
    imageBrowserMode = BROWSE_SELFIE;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.enableGrid = NO;
    [self.navigationController pushViewController:browser animated:YES];
}

- (IBAction)delete:(id)sender {
    NSString *message = @"该操作不可逆，您确定吗？";
    if (_diary.isShared) {
        message = [message stringByAppendingString:@"\n该日记已分享，删除后分享将不存在"];
    }
    UIAlertController *action = [UIAlertController alertControllerWithTitle:@"删除日记" message:message preferredStyle:UIAlertControllerStyleAlert];
    [action addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (_diary.hasOnlineVersion) {
            [KVNProgress showWithStatus:@"删除中"];
        }
        [_diary deleteWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (!success) {
                    [KVNProgress showErrorWithStatus:message];
                    return;
                }
                [KVNProgress showSuccessWithStatus:@"删除成功"];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:SYNC_PROGRESS_CHANGED_NOTIFOCATION object:nil userInfo:@{DIARY_ID: [NSNumber numberWithInt:NO_DIARY_ID]}];
            });
        }];
    }]];
    [action addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:action animated:YES completion:nil];
}

- (IBAction)share:(id)sender {
    if (!_diary.hasOnlineVersion) {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:@"该日记未上传" message:@"请先至用户中心同步日记" preferredStyle:UIAlertControllerStyleAlert];
        [action addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:action animated:YES completion:nil];
        return;
    }
    if (_diary.isShared) {
        UIAlertController *action = [UIAlertController alertControllerWithTitle:@"该日记已分享" message:@"请至用户中心管理您的分享" preferredStyle:UIAlertControllerStyleAlert];
        [action addAction:[UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:action animated:YES completion:nil];
        return;
    }
    [KVNProgress showWithStatus:@"分享中"];
    [_diary shareWithBlock:^(BOOL success, NSString * _Nullable message, NSObject * _Nullable data) {
        if (!success) {
            [KVNProgress showErrorWithStatus:message];
            return;
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SHARE_STATE_CHANGED_NOTIFOCATION object:nil];
        });
        [KVNProgress showSuccessWithStatus:@"分享成功\n快把链接分享给朋友吧！" completion:^{
            [Utilities openURL:(NSURL *)data inViewController:self];
        }];
    }];
}

#pragma mark - Navigation

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
