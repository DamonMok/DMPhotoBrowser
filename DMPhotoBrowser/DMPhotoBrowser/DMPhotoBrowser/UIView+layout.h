//
//  UIView+layout.h
//  DMImagePickerController
//
//  Created by Damon on 2017/8/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KScreenHeight [UIScreen mainScreen].bounds.size.height

#define KScreenWidth [UIScreen mainScreen].bounds.size.width

@interface UIView (layout)

@property (nonatomic, assign)CGFloat dm_x;

@property (nonatomic, assign)CGFloat dm_y;

@property (nonatomic, assign)CGFloat dm_width;

@property (nonatomic, assign)CGFloat dm_height;

@property (nonatomic, assign)CGPoint dm_center;

@property (nonatomic, assign)CGFloat dm_centerY;

@property (nonatomic, assign)CGFloat dm_centerX;


+ (CAKeyframeAnimation *)animationForSelectPhoto;

@end
