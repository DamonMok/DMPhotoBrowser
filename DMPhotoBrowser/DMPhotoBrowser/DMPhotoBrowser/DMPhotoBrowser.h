//
//  DMPhotoBrowser.h
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, DMPhotoBrowserOptions) {
    
    //By default, when viewing a large image,hide the corresponding source imageView.
    //Use this flag if you don't want to hide the source imageView.
    DMPhotoBrowserShowSrcImgView = 1 << 0,
    
    
    //Photo browser style:similar to the UIPageControl or Layout on top
    //If you do not set this parameter, use the default style
    DMPhotoBrowserStylePageControl = 1 << 1,
    DMPhotoBrowserStyleTop = 1 << 2,
    
    
    //Progress type
    DMPhotoBrowserProgressLoading = 1 << 3,
    DMPhotoBrowserProgressCircle = 1 << 4,
    DMPhotoBrowserProgressSector = 1 << 5
};

@interface DMPhotoBrowser : UIView

/**
 * The index of the image is currently selected.
 */
@property (nonatomic, assign) int index;


/**
 * Show a photo browser.
 
 * @param urls The urls for the large-images.
 * @param imageViews The imageViews from source imageViews.
 */
- (void)showWithUrls:(nonnull NSArray<NSURL *> *)urls thumbnailImageViews:(nonnull NSArray<UIImageView *> *)imageViews;


/**
 * Show a photo browser.

 * @param urls The urls for the large-images.
 * @param imageViews The imageViews from source imageViews.
 * @param options Some configurations about photo browser,get more details in 'DMPhotoBrowserOptions'.
 */
- (void)showWithUrls:(nonnull NSArray<NSURL *> *)urls thumbnailImageViews:(nonnull NSArray<UIImageView *> *)imageViews options:(DMPhotoBrowserOptions)options;

- (void)showWithDatas:(nonnull NSArray<NSData *> *)datas thumbnailImageViews:(nonnull NSArray<UIImageView *> *)imageViews;

@end
