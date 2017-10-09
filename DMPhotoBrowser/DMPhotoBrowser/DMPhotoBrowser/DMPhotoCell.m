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

@interface DMPhotoCell (){

    DMProgressView *_progressView;
}

@property (nonatomic, strong)UIImageView *imageView;

@end

@implementation DMPhotoCell

- (UIImageView *)imageView {

    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.masksToBounds = YES;
    }
    
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        [self initViews];
    }
    
    return self;
}

- (void)initViews {

    self.contentView.backgroundColor = [UIColor blueColor];
 
    [self.contentView addSubview:self.imageView];
}

- (void)setSrcImageView:(UIImageView *)srcImageView {

    _srcImageView = srcImageView;
    
    srcImageView.hidden = self.hideSrcImageView;
    
    //placeholder image
    self.imageView.image = srcImageView.image;
    //get thumbnail-imageView's frame
    self.imageView.frame = srcImageView.frame;
    
    CGFloat duration = _showAnimation ? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        
        self.imageView.center = self.contentView.center;
    }];
    
    _progressView = [DMProgressView showProgressViewAddedTo:self.contentView];
    [self.imageView sd_setImageWithURL:self.url placeholderImage:srcImageView.image options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        //download from internet
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _progressView.process = (float)receivedSize/expectedSize;
            _showAnimation = YES;
            
        });
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                
        [_progressView hideProgressView];
                
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
    }];
}

- (void)clearReuse {

    [_progressView hideProgressView];
}

@end
