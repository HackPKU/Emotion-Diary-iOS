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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:SYNC_PROGRESS_CHANGED_NOTIFOCATION object:nil];
    
    [self updateDiaryView];
        
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
    [KVNProgress showWithStatus:@"加载中"];
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
    [_diary getFullVersionWithBlock:^(BOOL success, NSString *message, NSObject * _Nullable data) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!success) {
                [KVNProgress showErrorWithStatus:message];
                return;
            }
            [KVNProgress dismiss];
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
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.enableGrid = YES;
    [browser setCurrentPhotoIndex:index];
    imageBrowserMode = BROWSE_IMAGE;
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
    switch (imageBrowserMode) {
        case BROWSE_SELFIE:
            return nil;
        case BROWSE_IMAGE:
            return [self photoBrowser:photoBrowser photoAtIndex:index];
        default:
            return nil;
    }
}

- (IBAction)touchSelfie:(id)sender {
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.enableGrid = NO;
    imageBrowserMode = BROWSE_SELFIE;
    [self.navigationController pushViewController:browser animated:YES];
}

- (IBAction)delete:(id)sender {
    // TODO: Delete function
}

- (IBAction)share:(id)sender {
    // TODO: Share function
}

#pragma mark - Navigation

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
