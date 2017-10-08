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

@interface DMPhotoCell (){

    BOOL _download;
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
    
}

- (void)setSrcImageView:(UIImageView *)srcImageView {

    _srcImageView = srcImageView;
    
    srcImageView.hidden = self.hideSrcImageView;
    
    _download = NO;
    
    //placeholder image
    self.imageView.image = srcImageView.image;
    //get thumbnail-imageView's frame
    self.imageView.frame = srcImageView.frame;
    self.imageView.hidden = YES;
    [self.contentView addSubview:self.imageView];
    
    [self.imageView sd_setImageWithURL:self.url placeholderImage:srcImageView.image options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        //download from internet
        if (!_download) {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                CGFloat duration = _showAnimation ? 0.2 : 0;
                
                [UIView animateWithDuration:duration animations:^{
                    
                    self.imageView.center = self.contentView.center;
                    self.imageView.hidden = NO;
                }];
                
                _showAnimation = YES;
            });
            
            _download = YES;
        }
        
        if (receivedSize/expectedSize == 1) {
            
            NSLog(@"finish");
        }
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        self.imageView.hidden = NO;
        
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

@end
