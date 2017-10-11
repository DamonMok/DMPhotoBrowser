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

@interface DMPhotoCell ()<UIScrollViewDelegate, UIGestureRecognizerDelegate> {

    
    DMProgressView *_progressView;
    BOOL _isGif;
    BOOL _downloadFinished;
    CGPoint _panStartPoint;
    CGRect _panStartFrame;
    
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
        _gifView.contentMode = UIViewContentModeScaleAspectFill;
        _gifView.layer.masksToBounds = YES;
        _gifView.userInteractionEnabled = YES;
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
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
    pan.delegate = self;
    [pan requireGestureRecognizerToFail:singleTap];
    
    [self.contentView addGestureRecognizer:doubleTap];
    [self.contentView addGestureRecognizer:singleTap];
    [self.contentView addGestureRecognizer:pan];
}

- (void)setSrcImageView:(UIImageView *)srcImageView {

    _srcImageView = srcImageView;
    
    _imageView.hidden = _isGif;
    _gifView.hidden = !_isGif;
    
    _containerView.frame = _srcImageView.frame;
    
    if (!_isGif) {
        
        //placeholder image
        _imageView.image = srcImageView.image;
        //get thumbnail-imageView's frame
        _imageView.frame = _containerView.bounds;
        
    } else {
    
        _gifView.image = srcImageView.image;
        _gifView.frame = _containerView.bounds;
    }
    
    
    CGFloat duration = _showAnimation ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        
        _containerView.center = self.contentView.center;
        
    } completion:^(BOOL finished) {
        
        _isGif ? [self loadGif:_gifView] : [self loadImage:_imageView];
    }];
    
}

//Load image
- (void)loadImage:(UIImageView *)imageView {

    _downloadFinished = NO;
    
    _progressView = [DMProgressView showProgressViewAddedTo:self.contentView];
    //sdwebImage default Indicator
    //[_imageView sd_setShowActivityIndicatorView:YES];
    //[_imageView sd_setIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [imageView sd_setImageWithURL:self.url placeholderImage:_srcImageView.image options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        //download from internet
        
        //the location of imageView here may be changed after another picture download finished
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //reset the location of the imageView
            imageView.center = CGPointMake(_containerView.dm_width/2, _containerView.dm_height/2);
            
            _progressView.process = (float)receivedSize/expectedSize;
            _showAnimation = YES;
            
        });
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        //load from cache
        [_progressView hideProgressView];
        
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
        
        _downloadFinished = YES;
    }];
}

#pragma mark - Gif
- (void)loadGif:(FLAnimatedImageView *)gifView {

    [self loadImage:gifView];
}

//pause
-(void)pauseGif
{
    [_gifView stopAnimating];
}

//play
-(void)playGif
{
    [_gifView startAnimating];
}

#pragma mark - Gesture hanlde
//singleTap: exit the photoBrowser
- (void)singleTapHandle:(UITapGestureRecognizer *)tap {
    
    _progressView.hidden = YES;
    
    UIImageView *imageView = _isGif ? _gifView : _imageView;
    
    if (_isGif) {
        [self pauseGif];
    }
    
    if ([self.delegate respondsToSelector:@selector(photoCell:hidePhotoFromLargeImgView:toThumbnailImgView:)]) {
        
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:NO];
        
        [self.delegate photoCell:self hidePhotoFromLargeImgView:imageView toThumbnailImgView:_srcImageView];
    }
}

//double tap
- (void)doubleTapHandle:(UITapGestureRecognizer *)tap {

    if (!_downloadFinished) return;
    
    CGPoint tapPoint = [tap locationInView:tap.view];
    
    CGFloat zoomScale = _scrollView.zoomScale == _scrollView.minimumZoomScale ? _scrollView.maximumZoomScale : _scrollView.minimumZoomScale;
    
    CGFloat width = _scrollView.dm_width/zoomScale;
    CGFloat height = _scrollView.dm_height/zoomScale;
    CGFloat x = tapPoint.x - width*0.5;
    CGFloat y = tapPoint.y - height*0.5;
    
    CGRect zoomRect = CGRectMake(x, y, width, height);
    
    [_scrollView zoomToRect:zoomRect animated:YES];
}

//pan
- (void)panHandle:(UIPanGestureRecognizer *)pan {
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        _progressView.hidden = YES;
        
        _panStartPoint = CGPointMake(_containerView.dm_x, _containerView.dm_y);
        
        if (_scrollView.contentSize.height > _scrollView.dm_height) {
            
            _panStartPoint = CGPointZero;
        }
        
        _panStartFrame = _containerView.frame;
        
    }

    CGPoint draggingPoint = [pan translationInView:pan.view];
    
    //Update the frame
    CGFloat scale = _containerView.dm_width/_containerView.dm_height;
    CGFloat decreaseValue = _containerView.dm_width > 150 ? fabs(draggingPoint.y)*0.5 : 0;
    _containerView.dm_x = _panStartPoint.x + draggingPoint.x;
    _containerView.dm_y = _panStartPoint.y + draggingPoint.y;
    _containerView.dm_width = _panStartFrame.size.width - decreaseValue;
    _containerView.dm_height = _containerView.dm_width/scale;
    _containerView.dm_centerX = KScreenWidth*0.5 + draggingPoint.x;
    
    if (_isGif) {
        
        [self pauseGif];
        _gifView.frame = _containerView.bounds;
    } else {
        
        _imageView.frame = _containerView.bounds;
    }
    
    if (self.DMPhotoCellPanStateChange) {
        self.DMPhotoCellPanStateChange(1-(fabs(draggingPoint.y)/200));
    }

    if (pan.state == UIGestureRecognizerStateEnded) {
        
        if ([self shouldExitPhotoBrowser]) {
            //exit the photoBrowser:large -> thumbnail
            
            _progressView.hidden = YES;
            
            [UIView animateWithDuration:0.3 animations:^{
                
                _containerView.frame = _srcImageView.frame;
                
                if (_isGif) {
                    
                    _gifView.frame = _containerView.bounds;
                    
                } else {
                
                    _imageView.frame = _containerView.bounds;
                }
                
            } completion:^(BOOL finished) {
                
                _srcImageView.hidden = NO;
                [(UIView *)_delegate removeFromSuperview];
            }];
            
        } else {
            //reset the frame
            [UIView animateWithDuration:0.3 animations:^{
                
                _containerView.frame = _panStartFrame;
                if (_isGif) {
                    
                    _gifView.frame = _containerView.bounds;
                    [self playGif];
                    
                } else {
                    
                    _imageView.frame = _containerView.bounds;
                }
                if (self.DMPhotoCellPanStateChange) {
                    self.DMPhotoCellPanStateChange(1);
                }
            } completion:^(BOOL finished) {
                _progressView.hidden = _downloadFinished;
            }];
        }
       
        if (self.DMPhotoCellPanStateEnd) {
            self.DMPhotoCellPanStateEnd();
        }
    }
}

//Check if you need to exit the photoBrowser
- (BOOL)shouldExitPhotoBrowser {
    
    if (_scrollView.contentSize.height <= _scrollView.dm_height) {

        if (fabs((_containerView.dm_centerY-_scrollView.dm_centerY))>200) {
            
            return YES;
        }
    } else {
    
        //pull down
        CGPoint downP = [_containerView convertPoint:CGPointZero toView:self.contentView];
        
        //pull up
        CGPoint upP = [_containerView convertPoint:CGPointMake(0, _containerView.dm_height) toView:self.contentView];
        
        if(downP.y>_scrollView.dm_centerY || upP.y < _scrollView.dm_centerY) {
        
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - UIGestureRecognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {

    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [pan translationInView:pan.view];
        
        if (fabs(point.y) - fabs(point.x) > 3) {
            
            if (_scrollView.contentSize.height<=KScreenHeight) {
                //response
                return YES;
            } else {
                
                if ((_scrollView.contentOffset.y == 0 && point.y>0) || ((int)_scrollView.contentOffset.y >= (int)(_scrollView.contentSize.height-KScreenHeight) && point.y<0)) {
                    //response the long photo
                    return YES;
                }
            }
        }
    }
    
    return NO;
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

#pragma mark - cell's cycle
- (void)willDisplayCell {

    _srcImageView.hidden = _hideSrcImageView;
    
    if (_isGif) {
        [self playGif];
    }
}

- (void)didEndDisplayingCell {

    _srcImageView.hidden = !_hideSrcImageView;
    
    if (_isGif) {
        [self pauseGif];
    }
}


@end
