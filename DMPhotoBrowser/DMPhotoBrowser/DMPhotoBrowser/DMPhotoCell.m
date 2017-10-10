//
//  DMPhotoCell.m
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMPhotoCell.h"
#import <UIImageView+WebCache.h>
#import <UIView+WebCache.h>
#import <FLAnimatedImageView+WebCache.h>
#import "UIView+layout.h"
#import "DMProgressView.h"

@interface DMPhotoCell ()<UIScrollViewDelegate> {

    BOOL _isGif;
}

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIView *containerView;

@property (nonatomic, strong)UIImageView *imageView;

@property (nonatomic, strong)FLAnimatedImageView *gifView;

@end

@implementation DMPhotoCell

#pragma mark - lazy load
- (UIScrollView *)scrollView {

    if (!_scrollView) {
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 2;
        _scrollView.delegate = self;
        
    }
    
    return _scrollView;
}

- (UIView *)containerView {

    if (!_containerView) {
        
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
    }
    
    return _containerView;
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

- (FLAnimatedImageView *)gifView {

    if (!_gifView) {
        
        _gifView = [FLAnimatedImageView new];
        
    }
    
    return _gifView;
}

- (void)setUrl:(NSURL *)url {

    _url = url;
    
    _isGif = [[_url absoluteString] hasSuffix:@"gif"];
}

#pragma mark - cycle
- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        [self initViews];
    }
    
    return self;
}

- (void)initViews {
    
    //subViews
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.containerView];
    [self.containerView addSubview:self.imageView];
    [self.containerView addSubview:self.gifView];
    
    //Gesture
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandle:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [self.containerView addGestureRecognizer:doubleTap];
    [self.contentView addGestureRecognizer:singleTap];
}

- (void)setSrcImageView:(UIImageView *)srcImageView {

    _srcImageView = srcImageView;
    
    _imageView.hidden = _isGif;
    _gifView.hidden = !_isGif;
    
    _containerView.frame = _scrollView.bounds;
    
    if (!_isGif) {
        
        //placeholder image
        _imageView.image = srcImageView.image;
        //get thumbnail-imageView's frame
        _imageView.frame = srcImageView.frame;
        
    } else {
    
        _gifView.image = srcImageView.image;
        _gifView.frame = srcImageView.frame;
    }
    
    
    CGFloat duration = _showAnimation ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        
        _imageView.center = self.contentView.center;
        _gifView.center = self.contentView.center;
        
    } completion:^(BOOL finished) {
        
        _isGif ? [self loadGif:_gifView] : [self loadImage:_imageView];
    }];
    
}

//Load image
- (void)loadImage:(UIImageView *)imageView {

    DMProgressView *progressView = [DMProgressView showProgressViewAddedTo:self.contentView];
    //sdwebImage default Indicator
    //[_imageView sd_setShowActivityIndicatorView:YES];
    //[_imageView sd_setIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [imageView sd_setImageWithURL:self.url placeholderImage:_srcImageView.image options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        //download from internet
        dispatch_async(dispatch_get_main_queue(), ^{
            
            progressView.process = (float)receivedSize/expectedSize;
            _showAnimation = YES;
            
        });
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        //load from cache
        [progressView hideProgressView];
        
        CGSize imageSize = imageView.image.size;
        
        CGFloat imageScale = imageSize.width/imageSize.height;
        
        CGFloat width = imageSize.width > KScreenWidth ? KScreenWidth : imageSize.width;
        
        CGFloat height = width/imageScale;
        
        CGFloat x = width < KScreenWidth ? (KScreenWidth-width)*0.5 : 0;
        CGFloat y = height < KScreenHeight ? (KScreenHeight-height)*0.5 : 0;
        
        CGFloat duration = _showAnimation ? 0.2 : 0;
        
        [UIView animateWithDuration:duration animations:^{
            
            _containerView.frame = CGRectMake(x, y, width, height);
        
            imageView.frame = _containerView.bounds;
        }];
        
        _scrollView.contentSize = CGSizeMake(width, height);
    }];
}

//Load gif
- (void)loadGif:(FLAnimatedImageView *)gifView {

    [self loadImage:gifView];
}

//pause
-(void)pauseGifOnLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
    
}

-(void)playGifOnLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] -    pausedTime;
    layer.beginTime = timeSincePause;
    
}

#pragma mark - tap hanlde
- (void)singleTapHandle:(UITapGestureRecognizer *)tap {
    
    UIImageView *imageView = _isGif ? _gifView : _imageView;
    
    if ([self.delegate respondsToSelector:@selector(photoCell:hidePhotoFromLargeImgView:toThumbnailImgView:)]) {
        
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:NO];
        
        [self.delegate photoCell:self hidePhotoFromLargeImgView:imageView toThumbnailImgView:_srcImageView];
    }
}

- (void)doubleTapHandle:(UITapGestureRecognizer *)tap {

    CGPoint tapPoint = [tap locationInView:tap.view];
    
    CGFloat zoomScale = _scrollView.zoomScale == _scrollView.minimumZoomScale ? _scrollView.maximumZoomScale : _scrollView.minimumZoomScale;
    
    CGFloat width = _scrollView.dm_width/zoomScale;
    CGFloat height = _scrollView.dm_height/zoomScale;
    CGFloat x = tapPoint.x - width*0.5;
    CGFloat y = tapPoint.y - height*0.5;
    
    CGRect zoomRect = CGRectMake(x, y, width, height);
    
    [_scrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark - UIScrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return self.containerView;
}

//reset containerView's position
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {

    CGFloat offsetX = _scrollView.dm_width > _scrollView.contentSize.width? (_scrollView.dm_width-_scrollView.contentSize.width)*0.5 : 0;
    
    CGFloat offsetY = _scrollView.dm_height > _scrollView.contentSize.height? (_scrollView.dm_height-_scrollView.contentSize.height)*0.5 : 0;
    
    _containerView.center = CGPointMake(_scrollView.contentSize.width*0.5+offsetX, _scrollView.contentSize.height*0.5+offsetY);
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
