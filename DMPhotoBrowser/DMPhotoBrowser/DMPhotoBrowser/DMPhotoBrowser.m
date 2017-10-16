//
//  DMPhotoBrowser.m
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMPhotoBrowser.h"
#import "UIView+layout.h"
#import "DMPhotoCell.h"
#import <objc/runtime.h>
#import <SDWebImageManager.h>
#import <SDImageCache.h>
#import <Photos/Photos.h>
#import "DMProgressView.h"
#import "DMActionSheetView.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *reuseID = @"photoBrowser";
static void *DMPhotoCellProcessValueKey = "DMPhotoCellProcessValueKey";
#define kMargin 10
#define kLabPageHeight 20

@interface DMPhotoBrowser ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>{

    NSArray *_arrUrl;
    NSArray *_arrSrcImageView;
    BOOL _hideSrcImageView;
    BOOL _showAnimation;
    DMPhotoBrowserOptions _options;

}

@property (nonatomic, strong)NSArray *arrSrcImageView;

@property (nonatomic, strong)UICollectionView *collectionView;

@property (nonatomic, strong)UILabel *labPage;

@property (nonatomic, strong)UIButton *btnSave;

@property (nonatomic, strong)UIButton *btnMore;

@property (nonatomic, strong)UIPageControl *pageControl;

@end

@implementation DMPhotoBrowser

#pragma mark - Show
- (void)showWithUrls:(NSArray<NSURL *> *)urls thumbnailImageViews:(NSArray<UIImageView *> *)imageViews {

    [self showWithUrls:urls thumbnailImageViews:imageViews options:0];
}

- (void)showWithUrls:(NSArray<NSURL *> *)urls thumbnailImageViews:(NSArray<UIImageView *> *)imageViews options:(DMPhotoBrowserOptions)options {
    
    _arrUrl = [NSArray arrayWithArray:urls];
    _arrSrcImageView = [NSArray arrayWithArray:imageViews];
    _options = options;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_index inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    for (UIImageView *srcImgView in _arrSrcImageView) {
        
        objc_setAssociatedObject(srcImgView, DMPhotoCellProcessValueKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    //Download
    //The download is asynchronous and cached.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (int i = 0; i < _arrUrl.count; i++) {
            
            [[SDWebImageManager sharedManager] loadImageWithURL:_arrUrl[i] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
                //save the process-value
                objc_setAssociatedObject(_arrSrcImageView[i], DMPhotoCellProcessValueKey, [NSNumber numberWithFloat:(CGFloat)receivedSize/expectedSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                
                objc_setAssociatedObject(_arrSrcImageView[i], DMPhotoCellProcessValueKey, @1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }];
        }
        
    });
    
    [self configOptions:options];
}


#pragma mark - lazy load
- (UICollectionView *)collectionView {

    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(KScreenWidth, KScreenHeight);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, kMargin, 0, 0);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[DMPhotoCell class] forCellWithReuseIdentifier:reuseID];
        _collectionView.pagingEnabled = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    
    }
    
    return _collectionView;
}

- (UILabel *)labPage {

    if (!_labPage) {
        
        _labPage = [[UILabel alloc] init];
        _labPage.textColor = [UIColor whiteColor];
        _labPage.textAlignment = NSTextAlignmentCenter;
        _labPage.text = [NSString stringWithFormat:@"%d/%ld",_index+1, _arrUrl.count];
    }
    
    return _labPage;
}

#pragma mark - cycle
- (instancetype)init {

    if (self = [super init]) {
        
        _showAnimation = YES;
        [self initViews];
    }
    
    return self;
}

- (void)initViews {

    //Self
    self.frame = [UIApplication sharedApplication].delegate.window.bounds;
    [[UIApplication sharedApplication].delegate.window addSubview:self];
    
    //Collection
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.frame = self.bounds;
    self.collectionView.dm_x -= kMargin;
    self.collectionView.dm_width += kMargin;
    [self addSubview:self.collectionView];
    
}

- (void)hidePhotoBrowser {

    self.collectionView.scrollEnabled = NO;
    UIImageView *srcImgView = self.arrSrcImageView[[self getCurrentIndex]];
    srcImgView.hidden = NO;
    [[SDImageCache sharedImageCache] clearMemory];
    [self removeFromSuperview];
}

#pragma mark - UICollectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _arrUrl.count;
}

- (__kindof DMPhotoCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    DMPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
   
    cell.hideSrcImageView = _hideSrcImageView;
    cell.url = _arrUrl[indexPath.row];
    cell.srcImageView = _arrSrcImageView[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    cell.DMPhotoCellPanStateChange = ^(CGFloat alpha) {
        
        weakSelf.collectionView.backgroundColor = [UIColor colorWithWhite:0.f alpha:alpha];
        weakSelf.collectionView.scrollEnabled = NO;
    };
    
    cell.DMPhotoCellPanStateEnd = ^(BOOL hide) {
        
        if (hide) {
            [weakSelf hidePhotoBrowser];
            
        } else {
            
            weakSelf.collectionView.scrollEnabled = YES;
        }
    };
    
    cell.DMPhotoCellLongPress = ^{
        
        [weakSelf didClickMoreButton];
    };
    
    cell.DMPhotoCellSingleTap = ^(UIImageView *imgOrGifImgView) {
        
        UIImageView *srcImgView = weakSelf.arrSrcImageView[[weakSelf getCurrentIndex]];
        
        CGPoint endPoint = [weakCell.contentView convertPoint:CGPointMake(srcImgView.dm_x, srcImgView.dm_y) toView:imgOrGifImgView];
        
        [UIView animateWithDuration:0.35 animations:^{
            
            imgOrGifImgView.frame = CGRectMake(endPoint.x, endPoint.y, srcImgView.dm_width, srcImgView.dm_height);
            
            weakSelf.collectionView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0];
        } completion:^(BOOL finished) {
            
            [weakSelf hidePhotoBrowser];
        }];
    };
    
    return cell;
    
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(DMPhotoCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.showAnimation = (_index == indexPath.row && _showAnimation) ? YES : NO;
    [cell willDisplayCell];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(DMPhotoCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    [cell didEndDisplayingCell];
}


#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //update the index of current Page
    int currentIndex = [self getCurrentIndex];
    
    if (currentIndex == -1) return;
    
    if (!(_options & DMPhotoBrowserStylePageControl) && !(_options & DMPhotoBrowserStyleTop)) {
        //Default style
        _labPage.text = [NSString stringWithFormat:@"%d/%ld",currentIndex+1, _arrUrl.count];
        [_labPage sizeToFit];
        
    } else if (_options & DMPhotoBrowserStylePageControl) {
        //PageControl style
        _pageControl.currentPage = currentIndex;
        
    } else {
        //Top style
        _labPage.text = [NSString stringWithFormat:@"%d/%ld",currentIndex+1, _arrUrl.count];
        [_labPage sizeToFit];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    _showAnimation = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DMPhotoCellWillBeginScrollingNotifiation object:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    [[NSNotificationCenter defaultCenter] postNotificationName:DMPhotoCellDidEndScrollingNotifiation object:nil];
    
}


#pragma mark - DMPhotoCell delegate
//hide the browser
- (void)photoCell:(DMPhotoCell *)cell hidePhotoFromLargeImgView:(UIImageView *)largeImgView toSrcImgView:(UIImageView *)srcImgView {
    
    CGPoint endPoint = [cell.contentView convertPoint:CGPointMake(srcImgView.dm_x, srcImgView.dm_y) toView:largeImgView];
    
    [UIView animateWithDuration:0.35 animations:^{
        
        largeImgView.frame = CGRectMake(endPoint.x, endPoint.y, srcImgView.dm_width, srcImgView.dm_height);
        
        self.collectionView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0];
    } completion:^(BOOL finished) {
        
        srcImgView.hidden = NO;
        [[SDImageCache sharedImageCache] clearMemory];
        [self removeFromSuperview];
    }];
}

#pragma mark - Style options
- (void)configOptions:(DMPhotoBrowserOptions)options {
    
    _hideSrcImageView = !(options & DMPhotoBrowserShowSrcImgView);
    
    if (!(options & DMPhotoBrowserStylePageControl) && !(options & DMPhotoBrowserStyleTop)) {
        
        //Default style
        [self addStyleDefault];
        
    } else if (options & DMPhotoBrowserStylePageControl) {
        
        //PageControl style
        [self addStylePageControl];
    } else {
        
        //Top style
        [self addStyleTop];
    }
        
    
}

- (void)addStyleDefault {

    //page label
    [self.labPage sizeToFit];
    _labPage.font = [UIFont systemFontOfSize:14.0];
    _labPage.frame = CGRectMake(kMargin, self.dm_height-CGRectGetHeight(_labPage.frame)-kMargin, _labPage.dm_width, _labPage.dm_height);
    
    //save button
    _btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnSave setTitle:@"保存" forState:UIControlStateNormal];
    [_btnSave.titleLabel sizeToFit];
    _btnSave.titleLabel.font = [UIFont systemFontOfSize:14.0];
    _btnSave.frame = CGRectMake(self.dm_width-kMargin-_btnSave.titleLabel.dm_width, 0, _btnSave.titleLabel.dm_width, _btnSave.titleLabel.dm_height);
    _btnSave.dm_centerY = _labPage.dm_centerY;
    [_btnSave addTarget:self action:@selector(didClickSaveButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_labPage];
    [self addSubview:_btnSave];
    
}

- (void)addStylePageControl {

    _pageControl = [[UIPageControl alloc] init];
    _pageControl.numberOfPages = _arrUrl.count;
    _pageControl.currentPage = _index;
    
    CGSize size = [_pageControl sizeForNumberOfPages:_arrUrl.count];
    _pageControl.frame = CGRectMake(0, self.dm_height-size.height, size.width, size.height);
    _pageControl.dm_centerX = self.dm_centerX;
    
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
}

- (void)addStyleTop {

    [self.labPage sizeToFit];
    _labPage.font = [UIFont boldSystemFontOfSize:16.0];
    _labPage.frame = CGRectMake((self.dm_width-_labPage.dm_width)*0.5, 2*kMargin, _labPage.dm_width+20, _labPage.dm_height);
    
    //save button
    _btnMore = [UIButton buttonWithType:UIButtonTypeCustom];
    [_btnMore setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnMore setTitle:@"..." forState:UIControlStateNormal];
    [_btnMore.titleLabel sizeToFit];
    _btnMore.titleLabel.font = [UIFont boldSystemFontOfSize:22.0];
    _btnMore.titleLabel.textAlignment = NSTextAlignmentCenter;
    _btnMore.frame = CGRectMake(self.dm_width-kMargin-_btnMore.titleLabel.dm_width-20, 0, _btnMore.titleLabel.dm_width+20, _btnMore.titleLabel.dm_height+10);
    _btnMore.dm_centerY = _labPage.dm_centerY-6;
    [_btnMore addTarget:self action:@selector(didClickMoreButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_btnMore];
    [self addSubview:_labPage];
}

#pragma mark - Actions of options
#pragma mark Save the photo
- (void)didClickSaveButton {
    
    //Search for cached images
    NSURL *currentImageUrl = _arrUrl[[self getCurrentIndex]];
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromCacheForKey:currentImageUrl.absoluteString];
    
    if (cacheImage) {
        //save
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            NSString *cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:_arrUrl[[self getCurrentIndex]]];
            NSString *cachePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheKey];
            NSData *imageData = [NSData dataWithContentsOfFile:cachePath];
            
            PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
            [(PHAssetCreationRequest *)request addResourceWithType:PHAssetResourceTypePhoto data:imageData options:nil];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if (error) {
                //show the localized recovery suggestion
                NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
                [self showErrorMessage:[NSString stringWithFormat:@"保存失败，由于系统限制，请在“设置-隐私-照片”中，重新允许%@访问相册",appName]];
                
            } else {
                //success
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [DMProgressView showSuccessAddedTo:self message:@"保存成功"];
                });
            }
        }];
        
        //Can't save the Gif photo
        //UIImageWriteToSavedPhotosAlbum(cacheImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
        
        //Expired in iOS9 and later
        //ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        //[library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        
        //}] ;
        
        
    } else {
        //show downloading message
        [self showErrorMessage:@"图片正在下载，请稍后再试"];
    }
}

#pragma mark did click More button
- (void)didClickMoreButton {

    DMActionSheetView *actionSheetView = [DMActionSheetView showActionSheetAddedToView:self datas:@[@"发送给朋友", @"保存图片", @"赞"]];

    actionSheetView.selectedBlock = ^(int tag) {
        
        switch (tag) {
            case 0:
                NSLog(@"发送给朋友");
                break;
            case 1:
                [self didClickSaveButton];
                break;
            case 2:
                NSLog(@"赞");
                break;
                
            default:
                break;
        }
    };
}

//Result of save the photo
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    if (error) {
        //show the localized recovery suggestion
        NSString *appName = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
        [self showErrorMessage:[NSString stringWithFormat:@"保存失败，由于系统限制，请在“设置-隐私-照片”中，重新允许%@访问相册",appName]];
        
    } else {
        //success
        [DMProgressView showSuccessAddedTo:self message:@"保存成功"];
    }
}

//Show error message
- (void)showErrorMessage:(NSString *)message {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIViewController *vc = [[UIViewController alloc] init];
    __weak typeof(alertController) weakAlertCtler = alertController;
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [weakAlertCtler dismissViewControllerAnimated:YES completion:nil];
        [vc.view removeFromSuperview];
    }];
    [alertController addAction:action];
    
    [[UIApplication sharedApplication].delegate.window addSubview:vc.view];
    [vc presentViewController:alertController animated:YES completion:nil];
}

#pragma mark Get current index of photo
- (int)getCurrentIndex {
    
    NSIndexPath *currentIndexPath = [_collectionView indexPathForItemAtPoint:[self convertPoint:CGPointMake(self.dm_width*0.5, self.dm_height*0.5) toView:_collectionView]];
    
    if (!currentIndexPath) {
        return -1;
    }
    
    return (int)currentIndexPath.row;
}

- (void)dealloc {

    NSLog(@"%s", __func__);
}

@end
