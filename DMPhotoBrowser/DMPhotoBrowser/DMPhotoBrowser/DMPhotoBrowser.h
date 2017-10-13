//
//  DMPhotoBrowser.h
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMPhotoBrowser : UIView

/**
 * The index of the image is currently selected.
 */
@property (nonatomic, assign)int index;

/**
 * By default, when viewing a large image,hide the corresponding thumbnail's imageView.
 */
@property (nonatomic, assign)BOOL hideSrcImageView;


/**
 * Show a photo browser.

 * @param urls The urls for the large-images.
 * @param imageViews The imageViews from thumbnail imageViews.
 */
- (void)showWithUrls:(nonnull NSArray<NSURL *> *)urls thumbnailImageViews:(nonnull NSArray<UIImageView *> *)imageViews;

@end
