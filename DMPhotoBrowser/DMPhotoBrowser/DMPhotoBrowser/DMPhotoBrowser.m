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

static NSString *reuseID = @"photoBrowser";
static void *DMPhotoCellProcessValueKey = "DMPhotoCellProcessValueKey";
#define kMargin 10
#define kLabPageHeight 20

@interface DMPhotoBrowser ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, DMPhotoCellDelegate>{

    NSArray *_arrUrl;
    NSArray *_arrSrcImageView;
    BOOL _hideSrcImageView;
    BOOL _showAnimation;
    DMPhotoBrowserOptions _options;
}

@property (nonatomic, strong)UICollectionView *collectionView;

@property (nonatomic, strong)UILabel *labPage;

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
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    //Collection
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.frame = self.bounds;
    self.collectionView.dm_x -= kMargin;
    self.collectionView.dm_width += kMargin;
    [self addSubview:self.collectionView];
    
    //Default tool view
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
    cell.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    cell.DMPhotoCellPanStateChange = ^(CGFloat alpha) {
        
        weakSelf.collectionView.backgroundColor = [UIColor colorWithWhite:0.f alpha:alpha];
        weakSelf.collectionView.scrollEnabled = NO;
    };
    
    cell.DMPhotoCellPanStateEnd = ^{
        
        weakSelf.collectionView.scrollEnabled = YES;
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
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    _showAnimation = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DMPhotoCellWillBeginScrollingNotifiation object:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    [[NSNotificationCenter defaultCenter] postNotificationName:DMPhotoCellDidEndScrollingNotifiation object:nil];
    
    //update the index of current Page
    NSIndexPath *currentIndexPath = [_collectionView indexPathForItemAtPoint:CGPointMake(_collectionView.contentOffset.x+kMargin, 0)];
    
    if (!(_options & DMPhotoBrowserStylePageControl) && !(_options & DMPhotoBrowserStyleTop)) {
        //Default style
        _labPage.text = [NSString stringWithFormat:@"%d/%ld",(int)currentIndexPath.row+1, _arrUrl.count];
        [_labPage sizeToFit];
        
    } else if (_options & DMPhotoBrowserStylePageControl) {
        //PageControl style
        _pageControl.currentPage = currentIndexPath.row;
        
    } else {
        //Top style
        
    }
    
}


#pragma DMPhotoCell delegate
//Exit the browser
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

#pragma mark - options
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
        
    }
        
    
}

- (void)addStyleDefault {

    _labPage = [[UILabel alloc] init];
    _labPage.textColor = [UIColor whiteColor];
    _labPage.font = [UIFont systemFontOfSize:14.0];
    _labPage.text = [NSString stringWithFormat:@"%d/%ld",_index+1, _arrUrl.count];
    [_labPage sizeToFit];
    
    _labPage.frame = CGRectMake(kMargin, self.dm_height-CGRectGetHeight(_labPage.frame)-kMargin, _labPage.dm_width, _labPage.dm_height);
    [self addSubview:_labPage];
    
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




- (void)dealloc {

    NSLog(@"%s", __func__);
}

@end
