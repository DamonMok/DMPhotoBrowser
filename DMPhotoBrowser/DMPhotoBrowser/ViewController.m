//
//  ViewController.m
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "ViewController.h"
#import "UIView+layout.h"
#import <UIImageView+WebCache.h>
#import "DMPhotoBrowser.h"
#import "YYFPSLabel.h"

@interface ViewController ()

//url
@property (nonatomic, strong)NSArray *arrUrl;

//thumbnail's UIImageView
@property (nonatomic, strong)NSMutableArray *arrThumbnailImgViews;

@end

@implementation ViewController

- (NSArray *)arrUrl {

    if (!_arrUrl) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"images.plist" ofType:nil];
        _arrUrl = [NSArray arrayWithContentsOfFile:path];
    }
    
    return _arrUrl;
}

- (NSMutableArray *)arrThumbnailImgViews {

    if (!_arrThumbnailImgViews) {
        
        _arrThumbnailImgViews = [NSMutableArray array];
    }
    
    return _arrThumbnailImgViews;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat margin = 10;
    
    CGFloat ivX = 0;
    CGFloat ivY = 0;
    CGFloat ivWH = (KScreenWidth-5*margin)/3;
    
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
        ivY = margin+(ivWH+margin)*row+64;
        
        imageView.frame = CGRectMake(ivX, ivY, ivWH, ivWH);
        
        [self.view addSubview:imageView];
        
        [self.arrThumbnailImgViews addObject:imageView];
        
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
//    photoBrowser.hideSrcImageView = NO;
    
    [photoBrowser showWithUrls:arrUrl thumbnailImageViews:self.arrThumbnailImgViews];
    
    [self initFPS];
}

#pragma mark FPS
- (void)initFPS {
    
    YYFPSLabel *labFPS = [[YYFPSLabel alloc] initWithFrame:CGRectMake(0, 30, 50, 30)];
    labFPS.dm_centerX = self.view.center.x;
    [labFPS sizeToFit];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:labFPS];
}

@end
