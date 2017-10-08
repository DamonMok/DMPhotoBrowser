//
//  ViewController.m
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "ViewController.h"
#import "UIView+layout.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self initViews];
}

- (void)initViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGFloat margin = 10;
    
    CGFloat ivX = 0;
    CGFloat ivY = 0;
    CGFloat ivWH = (KScreenWidth-5*margin)/3;
    
    int row = 0;
    int col = 0;
    
    for (int i = 0; i < 9; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = [UIColor blackColor];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        
        row = i/3;
        col = i%3;
        
        ivX = margin+(ivWH+margin)*col;
        ivY = margin+(ivWH+margin)*row+64;
        
        imageView.frame = CGRectMake(ivX, ivY, ivWH, ivWH);
        
        [self.view addSubview:imageView];
        
    }
}


@end
