//
//  DMPhotoCell.m
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMPhotoCell.h"
#import <UIImageView+WebCache.h>
#import "UIView+layout.h"
#import "DMProgressView.h"

@interface DMPhotoCell ()

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation DMPhotoCell

#pragma mark - lazy load
- (UIScrollView *)scrollView {

    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 2;
    }
    
    return _scrollView;
}

- (UIImageView *)imageView {

    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
        _imageView.userInteractionEnabled = YES;
    
    }
    
    return _imageView;
}

#pragma mark - cycle
- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        [self initViews];
    }
    
    return self;
}

- (void)initViews {
 
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
    [self.contentView addGestureRecognizer:singleTap];
        
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
}

- (void)setSrcImageView:(UIImageView *)srcImageView {

    _srcImageView = srcImageView;
    
    //placeholder image
    self.imageView.image = srcImageView.image;
    //get thumbnail-imageView's frame
    self.imageView.frame = srcImageView.frame;
    
    CGFloat duration = _showAnimation ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        
        self.imageView.center = self.contentView.center;
    } completion:^(BOOL finished) {
        
        [self loadImage];
    }];
    
}

- (void)loadImage {

    DMProgressView *progressView = [DMProgressView showProgressViewAddedTo:self.contentView];
    [self.imageView sd_setImageWithURL:self.url placeholderImage:_srcImageView.image options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        //download from internet
        dispatch_async(dispatch_get_main_queue(), ^{
            
            progressView.process = (float)receivedSize/expectedSize;
            _showAnimation = YES;
            
        });
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        [progressView hideProgressView];
        
        CGSize imageSize = self.imageView.image.size;
        
        CGFloat imageScale = imageSize.width/imageSize.height;
        
        CGFloat width = imageSize.width > KScreenWidth ? KScreenWidth : imageSize.width;
        
        CGFloat height = width/imageScale;
        
        CGFloat x = width < KScreenWidth ? (KScreenWidth-width)*0.5 : 0;
        CGFloat y = height < KScreenHeight ? (KScreenHeight-height)*0.5 : 0;
        
        CGFloat duration = _showAnimation ? 0.2 : 0;
        
        [UIView animateWithDuration:duration animations:^{
            
            self.imageView.frame = CGRectMake(x, y, width, height);
            
        }];
        
        self.scrollView.contentSize = CGSizeMake(width, height);
    }];
}

#pragma mark - tap hanlde
- (void)singleTapHandle:(UITapGestureRecognizer *)tap {

    if ([self.delegate respondsToSelector:@selector(photoCell:hidePhotoFromLargeImgView:toThumbnailImgView:)]) {
        
        [self.delegate photoCell:self hidePhotoFromLargeImgView:_imageView toThumbnailImgView:_srcImageView];
    }
    
}

#pragma mark - Thumbnail-imageView
//hide
- (void)hideSrcImgView {

    _srcImageView.hidden = _hideSrcImageView;
}

//show
- (void)showSrcImgView {
        
    _srcImageView.hidden = !_hideSrcImageView;
}

@end
