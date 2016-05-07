//
//  DiaryTableViewController.m
//  Emotion Diary
//
//  Created by 范志康 on 16/5/2.
//  Copyright © 2016年 范志康. All rights reserved.
//

#import "DiaryTableViewController.h"

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
    
    if (!_simpleDiary.hasLocalVersion) {
        [KVNProgress showWithStatus:@"加载中"];
    }
    [_simpleDiary getFullVersionWithBlock:^(BOOL success, NSObject * _Nullable data) {
        if (!success) {
            [KVNProgress showErrorWithStatus:@"日记加载错误"];
            return;
        }
        [KVNProgress dismiss];
        diary = (EmotionDiary *)data;
        [self updateDiaryView];
    }];
        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_cycleImageView startTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_cycleImageView stopTimer];
}

- (void)updateDiaryView {
    _imageSelfie.image = diary.imageSelfie ? diary.imageSelfie : PLACEHOLDER_IMAGE;
    _imageFace.image = [ActionPerformer getFaceImageByEmotion:diary.emotion];
    _labelEmotion.text = [NSString stringWithFormat:@"心情指数 %d", diary.emotion];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M月d日 HH:mm"];
    _labelDateAndTime.text = [formatter stringFromDate:diary.createTime];
    _textDetail.text = diary.text;
    _cycleImageView.pageControl.hidden = (diary.imageImages.count <= 1);
    [_cycleImageView reloadData];
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

#pragma mark - ZYBannerView data source

- (NSInteger)numberOfItemsInBanner:(ZYBannerView *)banner {
    return diary.imageImages.count;
}

- (UIView *)banner:(ZYBannerView *)banner viewForItemAtIndex:(NSInteger)index {
    UIImage *image = diary.imageImages[index];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    return imageView;
}

#pragma mark - ZYBannerView delegate

- (void)banner:(ZYBannerView *)banner didSelectItemAtIndex:(NSInteger)index {
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.enableGrid = YES;
    browser.displayActionButton = NO;
    [browser setCurrentPhotoIndex:index];
    [self.navigationController pushViewController:browser animated:YES];
}

#pragma mark - MWPhotoBrowser delegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return diary.imageImages.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < diary.imageImages.count) {
        return [MWPhoto photoWithImage:diary.imageImages[index]];
    }
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    return [self photoBrowser:photoBrowser photoAtIndex:index];
}

- (IBAction)delete:(id)sender {
}

- (IBAction)share:(id)sender {
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
