//
//  DMPhotoBrowserCell.m
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/29.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMPhotoBrowserCell.h"
#import "UIView+layout.h"
#import <UIImageView+WebCache.h>
#import "DMPhotoBrowser.h"

#define kMargin 10
#define kImageViewWH (KScreenWidth-5*kMargin)/3

@interface DMPhotoBrowserCell ()

@property (nonatomic, strong) NSMutableArray *arrSrcImgView;

@end

@implementation DMPhotoBrowserCell

- (NSMutableArray *)arrSrcImgView {

    if (!_arrSrcImgView) {
        
        _arrSrcImgView = [NSMutableArray array];
    }
    
    return _arrSrcImgView;
}

- (void)initViews {

    CGFloat margin = kMargin;
    
    CGFloat ivX = 0;
    CGFloat ivY = 0;
    CGFloat ivWH = kImageViewWH;
    
    int row = 0;
    int col = 0;
    
    for (int i = 0; i < self.arrUrl.count; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        
        //Gesture
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [imageView addGestureRecognizer:tap];
        
        NSURL *url = [NSURL URLWithString:self.arrUrl[i][@"thumbnail"]];
        [imageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageProgressiveDownload];
        
        row = i/3;
        col = i%3;
        
        ivX = margin+(ivWH+margin)*col;
        ivY = margin+(ivWH+margin)*row;
        
        imageView.frame = CGRectMake(ivX, ivY, ivWH, ivWH);
        
        [self.contentView addSubview:imageView];
        
        [self.arrSrcImgView addObject:imageView];
        
    }
}

- (void)tapHandle:(UITapGestureRecognizer *)tap {

    //get large-photo's URL
    NSMutableArray *arrUrl = [NSMutableArray array];

    for (NSDictionary *dicUrl in self.arrUrl) {

        NSURL *url = [NSURL URLWithString:dicUrl[@"large"]];
        [arrUrl addObject:url];
    }

    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];

    //Browser
    DMPhotoBrowser *photoBrowser = [[DMPhotoBrowser alloc] init];
    photoBrowser.index = (int)tap.view.tag;

    [photoBrowser showWithUrls:arrUrl thumbnailImageViews:self.arrSrcImgView options:DMPhotoBrowserStylePageControl|DMPhotoBrowserProgressCircle];
}

- (void)setArrUrl:(NSArray *)arrUrl {

    _arrUrl = arrUrl;
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self initViews];
}

@end


@implementation DMPhotoBrowserCellModel

+ (instancetype)photoBrowserCellModelWithUrls:(NSArray *)urls {

    DMPhotoBrowserCellModel *cellModel = [[self alloc] init];
    
    cellModel.arrUrl = urls;
    
    CGFloat row = ceilf((CGFloat)urls.count/3);
    cellModel.cellHeight = 2*kMargin + kImageViewWH*row + (row-1)*kMargin;
    
    return cellModel;
}

@end
