//
//  FLAnimatedImageView+GifUpgrade.m
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/13.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "FLAnimatedImageView+GifUpgrade.h"
#import "NSData+ImageContentType.h"

@implementation FLAnimatedImageView (GifUpgrade)

- (void)dm_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock {
    
}

- (void)dm_setImageWithURL:(NSURL *)url options:(SDWebImageOptions)options completed:(GifUpgradeFetchDataCompleted)completedBlock {

    __weak typeof(self) weakSelf = self;
    [self sd_internalSetImageWithURL:url
                    placeholderImage:nil
                             options:options
                        operationKey:nil
                       setImageBlock:^(UIImage *image, NSData *imageData) {
                           SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:imageData];
                           if (imageFormat == SDImageFormatGIF) {
                               
                               dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                   
                                   FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       
                                       weakSelf.animatedImage = animatedImage;
                                       
                                       if (completedBlock) {
                                           completedBlock();
                                       }
                                   });
                               });
                           }
                       }
                            progress:nil
                           completed:nil];
}

@end

