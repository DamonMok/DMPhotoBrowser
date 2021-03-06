//
//  DMPhotoCell.m
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMPhotoCell.h"
#import <UIImageView+WebCache.h>
#import <FLAnimatedImageView+WebCache.h>
#import "UIView+layout.h"
#import "DMProgressHUD.h"
#import <objc/runtime.h>
#import <NSData+ImageContentType.h>

static void *DMPhotoCellProgressValueKey = "DMPhotoCellProgressValueKey";

NSString *const DMPhotoCellWillBeginScrollingNotifiation = @"DMPhotoCellWillScrollNotifiation";

NSString *const DMPhotoCellDidEndScrollingNotifiation = @"DMPhotoCellDidEndScrollingNotifiation";

//The minimum width of image when Gesture-Pan is calling
static const CGFloat kMinimumWidth = 150.0;

@interface DMPhotoCell ()<UIScrollViewDelegate, UIGestureRecognizerDelegate> {

    BOOL _downloadFinished;
    BOOL _isGif;
    BOOL _isDisplaying;//cell is displaying
    BOOL _isPan;//UIPanGestureRecognizer is executing
    
    CGPoint _panStartPoint;// x/y before panGesture
    CGRect _panStartFrame;// frame before panGesture
    CGRect _finalFrame;//frame after downloading
    
}

@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIView *containerView;

@property (nonatomic, strong)UIImageView *imageView;

@property (nonatomic, strong)FLAnimatedImageView *gifView;

@property (nonatomic, strong)CADisplayLink *displayLink;

@property (nonatomic, strong)DMProgressHUD *progressHUD;

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
        _imageView.backgroundColor = [UIColor blackColor];
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

#pragma mark - cycle
- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        [self initViews];
    }
    
    return self;
}

- (void)dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self name:DMPhotoCellWillBeginScrollingNotifiation object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DMPhotoCellDidEndScrollingNotifiation object:nil];
}

- (void)initViews {
    
    //subViews
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.containerView];
    [self.containerView addSubview:self.imageView];
    [self.containerView addSubview:self.gifView];
    
    //Gesture
    //single
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapHandle:)];
    
    //double
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandle:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    //pan
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandle:)];
    pan.delegate = self;
    [pan requireGestureRecognizerToFail:singleTap];
    
    //long press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandle:)];
    
    [self.contentView addGestureRecognizer:doubleTap];
    [self.contentView addGestureRecognizer:singleTap];
    [self.contentView addGestureRecognizer:pan];
    [self.contentView addGestureRecognizer:longPress];
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willScrollCell) name:DMPhotoCellWillBeginScrollingNotifiation object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndScrollingCell) name:DMPhotoCellDidEndScrollingNotifiation object:nil];
}

#pragma mark - Gif
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
//singleTap: hide the photoBrowser
- (void)singleTapHandle:(UITapGestureRecognizer *)tap {

    [self removeDpLink];
    [_progressHUD dismiss];
    _progressHUD = nil;
    
    UIImageView *imgOrGifImgView = _isGif ? _gifView : _imageView;
    
    if (_isGif) {
        [self pauseGif];
    }
    
    [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    _scrollView.contentOffset = CGPointZero;
   
    if (self.DMPhotoCellSingleTap) {
        self.DMPhotoCellSingleTap(_containerView ,imgOrGifImgView);
    }
    
}

//double tap
- (void)doubleTapHandle:(UITapGestureRecognizer *)tap {

    if (!_downloadFinished) return;
    
    CGPoint tapPoint = [tap locationInView:_containerView];
    
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
    //began
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        if (!_downloadFinished) {
            _displayLink.paused = YES;
            self.progressHUD.hidden = YES;
        }
        
        _panStartPoint = CGPointMake(_containerView.dm_x, _containerView.dm_y);
        
        if (_scrollView.contentSize.height > _scrollView.dm_height) {
            
            //_panStartPoint = CGPointZero;
        }
        
        _panStartFrame = _containerView.frame;
        
        _isPan = YES;
    }

    CGPoint draggingPoint = [pan translationInView:pan.view];
    
    //Update the frame
    CGFloat scale = _containerView.dm_width/_containerView.dm_height;
    
    CGFloat decreaseValue = _containerView.dm_width > kMinimumWidth ? fabs(draggingPoint.y)*0.5 : _panStartFrame.size.width-_containerView.dm_width;
    
    _containerView.dm_y = _panStartPoint.y + draggingPoint.y;   //Y
    if (_scrollView.zoomScale == 1) {
        
        _containerView.dm_x = _panStartPoint.x + draggingPoint.x;   //X
        
        _containerView.dm_width = _panStartFrame.size.width - decreaseValue;    //Width
        
        _containerView.dm_height = _containerView.dm_width/scale;   //Height
        
        //Reset X
        if (_containerView.dm_width < _scrollView.dm_width) {
            
            _containerView.dm_centerX = KScreenWidth*0.5 + draggingPoint.x;
        } else {
            
            _containerView.dm_x += (_panStartFrame.size.width-_containerView.dm_width)*0.5;
        }
    }
    
    if (_isGif) {
        
        [self pauseGif];
        _gifView.frame = _containerView.bounds;
    } else {
        
        _imageView.frame = _containerView.bounds;
    }
    
    if (self.DMPhotoCellPanStateChange) {
        self.DMPhotoCellPanStateChange(1-(fabs(draggingPoint.y)/200));
    }
    
    //end
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        if ([self shouldHidePhotoBrowser]) {
            //hide the photoBrowser:large -> thumbnail
            
            [_progressHUD dismiss];
            _progressHUD = nil;
            
            [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
            _scrollView.contentOffset = CGPointZero;
            [UIView animateWithDuration:0.3 animations:^{
                
                CGRect absolutelyFrame = [_srcImageView convertRect:_srcImageView.bounds toView:[UIApplication sharedApplication].delegate.window];
                _containerView.frame = absolutelyFrame;
                
                if (_isGif) {
                    
                    _gifView.frame = _containerView.bounds;
                    
                } else {
                
                    _imageView.frame = _containerView.bounds;
                }
                
            } completion:^(BOOL finished) {
                
                if (self.DMPhotoCellPanStateEnd) {
                    self.DMPhotoCellPanStateEnd(YES);
                }
            }];
            
        } else {
            //reset the frame
            [UIView animateWithDuration:0.3 animations:^{
                
                _containerView.frame = _downloadFinished?_finalFrame:_panStartFrame;
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
                
                if (!_downloadFinished) {
                    self.progressHUD.hidden = NO;
                    _displayLink.paused = NO;
                }
                
                if (self.DMPhotoCellPanStateEnd) {
                    self.DMPhotoCellPanStateEnd(NO);
                }
            }];
        }
       
        
        
        _isPan = NO;
    }
}

//long press
- (void)longPressHandle:(UILongPressGestureRecognizer *)longPress {

    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        if (self.DMPhotoCellLongPress) {
            self.DMPhotoCellLongPress();
        }
    }
}

//Check if you need to hide the photoBrowser
- (BOOL)shouldHidePhotoBrowser {
    
    if (_scrollView.contentSize.height <= _scrollView.dm_height) {

        if (fabs((_containerView.dm_centerY-_scrollView.dm_centerY))>200) {
            
            return YES;
        }
    } else {
    
//        //pull down
//        CGPoint downP = [_containerView convertPoint:CGPointZero toView:self.contentView];
//        
//        //pull up
//        CGPoint upP = [_containerView convertPoint:CGPointMake(0, _containerView.dm_height) toView:self.contentView];
//        
//        if(downP.y>_scrollView.dm_centerY || upP.y < _scrollView.dm_centerY) {
//        
//            return YES;
//        }
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
        
        
        if (fabs(point.y) - fabs(point.x) > 3 && pan.numberOfTouches == 1 && (_scrollView.contentSize.height < _scrollView.dm_height)) {
            
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
    
    _finalFrame = _containerView.frame;
}

#pragma mark - cell's cycle
- (void)willDisplayCell {

    if (_fromInternet) {
        
        _isGif = [[_url absoluteString] hasSuffix:@"gif"];
    } else {
        
        SDImageFormat format = [NSData sd_imageFormatForImageData:_data];
        _isGif = format == SDImageFormatGIF;
    }
    
    _srcImageView.hidden = _hideSrcImageView;
    _isDisplaying = YES;
    _scrollView.zoomScale = 1;
    
    [self configInitialLocation];

}

- (void)didEndDisplayingCell {

    _srcImageView.hidden = !_hideSrcImageView;
    [self removeDpLink];
    [self.progressHUD dismiss];
    self.progressHUD = nil;
    _isDisplaying = NO;
    
    if (_isGif) {
        
        [self pauseGif];
    }
}

- (void)willScrollCell {

    if (_isGif && _isDisplaying) {
        [self pauseGif];
    }
}

- (void)didEndScrollingCell {

    if (_isGif && _isDisplaying) {
        [self playGif];
    }
}

#pragma mark - Image/Gif handle
//config the initial location before downloading
- (void)configInitialLocation {

    _imageView.hidden = _isGif;
    _gifView.hidden = !_isGif;
    
    UIImageView *imgOrGifView = _isGif ? _gifView : _imageView;
    
    CGRect absolutelyFrame = [_srcImageView convertRect:_srcImageView.bounds toView:[UIApplication sharedApplication].delegate.window];
    
    _containerView.frame = absolutelyFrame;
    //placeholder image
    imgOrGifView.image = _srcImageView.image;
    //get thumbnail-imageView's frame
    imgOrGifView.frame = _containerView.bounds;
    
    CGFloat duration = _showAnimation ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        
        _containerView.center = self.contentView.center;
        _scrollView.contentSize = _containerView.bounds.size;
        
    } completion:^(BOOL finished) {
        
        [self loadImage:imgOrGifView];
        
        if (_fromInternet) {
            [self addDpLink];
        }
    }];
}

//set image
- (void)loadImage:(UIImageView *)imgOrGifView {
    
    if (_fromInternet) {
        //Load image from internet
        CGFloat progress = [objc_getAssociatedObject(_srcImageView, DMPhotoCellProgressValueKey) doubleValue];
        
        if (progress < 1) {
            //downloading
            
            //ProgressHUD
            if (!_progressHUD) {
                _progressHUD = [DMProgressHUD showProgressHUDAddedTo:self.contentView];
                
                if (_progressType == DMPhotoProgressTypeSector || _progressType == DMPhotoProgressTypeCircle) {
                    
                    _progressHUD.mode = DMProgressHUDModeProgress;
                    
                    if (_progressType == DMPhotoProgressTypeCircle) {
                        
                        _progressHUD.progressType = DMProgressHUDProgressTypeCircle;
                    } else if (_progressType == DMPhotoProgressTypeSector) {
                        
                        _progressHUD.progressType = DMProgressHUDProgressTypeSector;
                    }
                    
                } else if (_progressType == DMPhotoProgressTypeLoading) {
                    
                    _progressHUD.mode = DMProgressHUDModeLoading;
                    _progressHUD.loadingType = DMProgressHUDLoadingTypeCircle;
                }
            }
            
            if (_progressType == DMPhotoProgressTypeSector || _progressType == DMPhotoProgressTypeCircle) {
                
                self.progressHUD.progress = progress;
            }
            
            
            imgOrGifView.center = CGPointMake(_containerView.dm_width/2, _containerView.dm_height/2);
            
            _showAnimation = YES;
            _downloadFinished = NO;
            
        } else {
            //download finished
            _displayLink.paused = YES;
            [self.progressHUD dismiss];
            self.progressHUD = nil;
            
            if (_isGif) {
                
                [[SDWebImageManager sharedManager] loadImageWithURL:_url options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    //from cache
                    if (!error) {
                        
                        if (data) {
                            [self removeDpLink];
                            
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                
                                FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:data];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    _gifView.animatedImage = animatedImage;
                                    [self configTheLastLocation:_gifView];
                                });
                            });
                        } else {
                            
                            _displayLink.paused = NO;
                        }
                    } else {
                        
                        [self removeDpLink];
                    }
                }];
                
            } else {
                
                [_imageView sd_setImageWithURL:_url placeholderImage:_srcImageView.image completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    //from cache
                    if (!error) {
                        
                        [self removeDpLink];
                        [self configTheLastLocation:_imageView];
                    } else {
                        
                        [self removeDpLink];
                    }
                }];
            }
        }
    } else {
        //Load image from local
        if (_isGif) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:_data];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    _gifView.animatedImage = animatedImage;
                    [self configTheLastLocation:_gifView];
                });
            });
            
        } else {
            
            _imageView.image = [UIImage imageWithData:_data];
            
            [self configTheLastLocation:_imageView];
        }
    }
}

//config the last location after downloading
- (void)configTheLastLocation:(UIImageView *)imgOrGifView {

    //load image/gif from cache
    CGSize imageSize = imgOrGifView.image.size;
    
    if (imageSize.width == 0 || imageSize.height == 0) return;
    
    CGFloat imageScale = imageSize.width/imageSize.height;
    
    CGFloat width = imageSize.width > KScreenWidth ? KScreenWidth : imageSize.width;
    
    CGFloat height = width/imageScale;
    
    CGFloat x = width < KScreenWidth ? (KScreenWidth-width)*0.5 : 0;
    CGFloat y = height < KScreenHeight ? (KScreenHeight-height)*0.5 : 0;
    
    CGFloat duration = _showAnimation ? 0.25 : 0;
    [UIView animateWithDuration:duration animations:^{
        
        if (!_isPan) {
            
            _containerView.frame = CGRectMake(x, y, width, height);
            imgOrGifView.frame = _containerView.bounds;
        }
    }];
    
    _finalFrame = CGRectMake(x, y, width, height);
    _scrollView.contentSize = CGSizeMake(width, height);
    _downloadFinished = YES;
    
    if (_isGif) {
        [self playGif];
    }
}

#pragma mark - DisplayLink
//Refresh progress-value
- (void)refreshProgress {
    
    _isGif ? [self loadImage:_gifView] : [self loadImage:_imageView];
    
}

- (void)addDpLink {

    if (!_downloadFinished) {
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshProgress)];
        _displayLink.preferredFramesPerSecond = 15;
        _displayLink.paused = NO;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)removeDpLink {

    if (_displayLink) {
        _displayLink.paused = YES;
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

@end
