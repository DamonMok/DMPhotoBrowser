//
//  DMPhotoCell.h
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMPhotoCell : UICollectionViewCell

//URL of the large image
@property (nonatomic, strong)NSURL *url;

//thumbnail's imageView
@property (nonatomic, strong)UIImageView *srcImageView;

//By default, when viewing a large image,hide the corresponding thumbnail's imageView
@property (nonatomic, assign)BOOL hideSrcImageView;

@property (nonatomic, assign)BOOL showAnimation;

- (void)clearReuse;

@end
