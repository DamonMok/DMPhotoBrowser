//
//  DMPhotoBrowser.h
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMPhotoBrowser : UIView

- (void)showWithUrls:(nonnull NSArray<NSURL *> *)urls thumbnailImageViews:(nonnull NSArray<UIImageView *> *)imageViews;

@end
