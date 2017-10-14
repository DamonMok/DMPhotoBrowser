//
//  DMPhotoCell.h
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const DMPhotoCellWillBeginScrollingNotifiation;
extern NSString *const DMPhotoCellDidEndScrollingNotifiation;

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

//Use to change the alpha of background color
//This block will be called when UIPanGestureRecognizer is execute
@property (nonatomic, copy)void(^DMPhotoCellPanStateChange)(CGFloat alpha);

//This block will be called when UIPanGestureRecognizer ended
@property (nonatomic, copy)void(^DMPhotoCellPanStateEnd)();


/**The operations befor the cell will display*/
- (void)willDisplayCell;

/**The operations after the cell is displayed*/
- (void)didEndDisplayingCell;

@end

#pragma mark delegate
@protocol DMPhotoCellDelegate <NSObject>

@optional


/**Exit the photo browser*/
- (void)photoCell:(DMPhotoCell *)cell hidePhotoFromLargeImgView:(UIImageView *)largeImgView toSrcImgView:(UIImageView *)srcImgView;

@end
