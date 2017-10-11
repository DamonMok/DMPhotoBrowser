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

static NSString *reuseID = @"photoBrowser";
#define margin 10

@interface DMPhotoBrowser ()<UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, DMPhotoCellDelegate>{

    NSArray *_arrUrl;
    NSArray *_arrSrcImageView;
    
    //Show the animation when clicking on the thumbnail-imageView or download finished
    BOOL _showAnimation;
}

@property (nonatomic, strong)UICollectionView *collectionView;

@end

@implementation DMPhotoBrowser

#pragma mark - Show
- (void)showWithUrls:(NSArray<NSURL *> *)urls thumbnailImageViews:(NSArray<UIImageView *> *)imageViews {
    
    _arrUrl = [NSArray arrayWithArray:urls];
    _arrSrcImageView = [NSArray arrayWithArray:imageViews];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_index inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}


#pragma mark - lazy load
- (UICollectionView *)collectionView {

    if (!_collectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(KScreenWidth, KScreenHeight);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, margin, 0, 0);
        
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
        
        self.hideSrcImageView = YES;
        _showAnimation = YES;
        
        [self initViews];
    }
    
    return self;
}

- (void)initViews {

    //self
    self.frame = [UIApplication sharedApplication].keyWindow.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    //collection
    self.collectionView.backgroundColor = [UIColor blackColor];
    self.collectionView.frame = self.bounds;
    self.collectionView.dm_x -= margin;
    self.collectionView.dm_width += margin;
    [self addSubview:self.collectionView];
}

#pragma mark - UICollectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return _arrUrl.count;
}

- (__kindof DMPhotoCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
NSLog(@"%ld", indexPath.row);
    DMPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
   
    cell.hideSrcImageView = _hideSrcImageView;
    cell.showAnimation = _showAnimation;
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

    [cell willDisplayCell];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(DMPhotoCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    [cell didEndDisplayingCell];
}


#pragma mark - UIScrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    _showAnimation = NO;
}

#pragma DMPhotoCell delegate
//Exit the browser
- (void)photoCell:(DMPhotoCell *)cell hidePhotoFromLargeImgView:(UIImageView *)largeImgView toThumbnailImgView:(UIImageView *)srcImgView {

    CGPoint endPoint = [cell.contentView convertPoint:CGPointMake(srcImgView.dm_x, srcImgView.dm_y) toView:largeImgView];
    
    [UIView animateWithDuration:0.35 animations:^{
        
        largeImgView.frame = CGRectMake(endPoint.x, endPoint.y, srcImgView.dm_width, srcImgView.dm_height);
        
        self.collectionView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0];
    } completion:^(BOOL finished) {
        
        srcImgView.hidden = NO;
        [self removeFromSuperview];
    }];
}

- (void)dealloc {

    NSLog(@"%s", __func__);
}

@end
