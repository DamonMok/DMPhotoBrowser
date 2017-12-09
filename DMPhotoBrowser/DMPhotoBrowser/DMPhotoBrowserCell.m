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
#import <UIImage+GIF.h>

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

    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.arrSrcImgView removeAllObjects];
    
    CGFloat margin = kMargin;
    
    CGFloat ivX = 0;
    CGFloat ivY = 0;
    CGFloat ivWH = kImageViewWH;
    
    int row = 0;
    int col = 0;
    
    for (int i = 0; i < self.arrModel.count; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        
        //Gesture
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [imageView addGestureRecognizer:tap];
        
        if (self.fromInternet) {
            //From internet
            NSURL *url = [NSURL URLWithString:self.arrModel[i][@"thumbnail"]];
            
            [imageView sd_setImageWithURL:url placeholderImage:nil options:SDWebImageProgressiveDownload];
        } else {
            //From local
            __block UIImage *image = [UIImage imageNamed:self.arrModel[i][@"large"]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.01)];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    imageView.image = image;
                });
            });
        }
        
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

    //Get large-photo's URL/Image
    NSMutableArray *arrModel = [NSMutableArray array];

    for (NSDictionary *dicModel in self.arrModel) {

        if (self.fromInternet) {
            //From internet
            NSURL *url = [NSURL URLWithString:dicModel[@"large"]];
            
            [arrModel addObject:url];
        } else {
            //From local
            NSString *path = [[NSBundle mainBundle] pathForResource:dicModel[@"large"] ofType:nil];
            NSData *data = [NSData dataWithContentsOfFile:path];
            
            if (!data) {
                data = [NSData data];
            }
            
            [arrModel addObject:data];
        }
    }

    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];

    //Browser
    DMPhotoBrowser *photoBrowser = [[DMPhotoBrowser alloc] init];
    photoBrowser.index = (int)tap.view.tag;

    if (self.fromInternet) {
        //Internet
        [photoBrowser showWithUrls:arrModel thumbnailImageViews:self.arrSrcImgView options:DMPhotoBrowserStylePageControl|DMPhotoBrowserProgressCircle];
    } else {
        //Local
        [photoBrowser showWithDatas:arrModel thumbnailImageViews:self.arrSrcImgView options:DMPhotoBrowserStyleTop];
    }
}

- (void)setArrModel:(NSArray *)arrModel {

    _arrModel = arrModel;
    
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

+ (instancetype)photoBrowserCellModelWithImages:(NSArray *)imgs {

    DMPhotoBrowserCellModel *cellModel = [[self alloc] init];
    
    cellModel.arrImage = imgs;
    
    CGFloat row = ceilf((CGFloat)imgs.count/3);
    cellModel.cellHeight = 2*kMargin + kImageViewWH*row + (row-1)*kMargin;
    
    return cellModel;
}


@end
