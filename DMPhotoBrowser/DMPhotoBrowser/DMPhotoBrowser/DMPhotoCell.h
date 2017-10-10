//
//  DMPhotoCell.h
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DMPhotoCellDelegate;

@interface DMPhotoCell : UICollectionViewCell

//URL of the large photo
@property (nonatomic, strong)NSURL *url;

//Thumbnail's imageView
@property (nonatomic, strong)UIImageView *srcImageView;

//By default, when viewing a large image,hide the corresponding thumbnail's imageView
@property (nonatomic, assign)BOOL hideSrcImageView;

@property (nonatomic, assign)BOOL showAnimation;

@property (nonatomic, weak)id<DMPhotoCellDelegate> delegate;


/**The operations befor the cell will display*/
- (void)willDisplayCell;

/**The operations after the cell is displayed*/
- (void)didEndDisplayingCell;

@end

#pragma mark delegate
@protocol DMPhotoCellDelegate <NSObject>

@optional


/**Hide photo from large to small*/
- (void)photoCell:(DMPhotoCell *)cell hidePhotoFromLargeImgView:(UIImageView *)largeImgView toThumbnailImgView:(UIImageView *)srcImgView;

@end
