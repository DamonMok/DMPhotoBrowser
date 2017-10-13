//
//  FLAnimatedImageView+GifUpgrade.h
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/13.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <FLAnimatedImage/FLAnimatedImage.h>
#import "UIView+WebCache.h"

typedef void(^GifUpgradeFetchDataCompleted)();

@interface FLAnimatedImageView (GifUpgrade)

- (void)dm_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock;

- (void)dm_setImageWithURL:(nullable NSURL *)url options:(SDWebImageOptions)options  completed:(nullable GifUpgradeFetchDataCompleted)completedBlock;

@end




