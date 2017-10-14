//
//  DMPhotoBrowser.h
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, DMPhotoBrowserOptions) {
    /**
     * By default, when viewing a large image,hide the corresponding source imageView.
     * Use this flag if you don't want to hide the source imageView.
     */
    DMPhotoBrowserShowSrcImgView = 1 << 0,
    
    DMPhotoBrowser2 = 1 << 1,
    DMPhotoBrowser3 = 1 << 2
};

@interface DMPhotoBrowser : UIView

/**
 * The index of the image is currently selected.
 */
@property (nonatomic, assign)int index;


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

@end
