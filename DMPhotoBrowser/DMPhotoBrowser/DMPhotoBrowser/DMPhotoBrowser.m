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

    DMPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
   
    cell.hideSrcImageView = _hideSrcImageView;
    cell.showAnimation = _showAnimation;
    cell.url = _arrUrl[indexPath.row];
    cell.srcImageView = _arrSrcImageView[indexPath.row];
    cell.delegate = self;
    
    return cell;
    
}

#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(DMPhotoCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    [cell hideSrcImgView];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(DMPhotoCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    [cell showSrcImgView];
}

#pragma mark - UIScrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    _showAnimation = NO;
}

#pragma DMPhotoCell delegate
- (void)photoCell:(DMPhotoCell *)cell hidePhotoFromLargeImgView:(UIImageView *)largeImgView toThumbnailImgView:(UIImageView *)srcImgView {

    [UIView animateWithDuration:0.25 animations:^{
        
        largeImgView.frame = srcImgView.frame;
        
        self.collectionView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0];
    } completion:^(BOOL finished) {
        
        srcImgView.hidden = NO;
        [self removeFromSuperview];
    }];
}

@end
