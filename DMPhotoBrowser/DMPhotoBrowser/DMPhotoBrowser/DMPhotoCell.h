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

typedef NS_ENUM(NSInteger, DMPhotoProgressType) {

    DMPhotoProgressTypeLoading,
    
    DMPhotoProgressTypeCircle,
    
    DMPhotoProgressTypeSector
};

@protocol DMPhotoCellDelegate;

@interface DMPhotoCell : UICollectionViewCell

//From Local or Internet(Web/Cache)
@property (nonatomic, assign) BOOL fromInternet;

@property (nonatomic, strong)NSURL *url; //URL for image

@property (nonatomic, strong) NSData *data; //Data for image

//Thumbnail's imageView
@property (nonatomic, strong)UIImageView *srcImageView;

//By default, when viewing a large image,hide the corresponding thumbnail's imageView
@property (nonatomic, assign)BOOL hideSrcImageView;

@property (nonatomic, assign)BOOL showAnimation;

@property (nonatomic, assign)DMPhotoProgressType progressType;

@property (nonatomic, weak)id<DMPhotoCellDelegate> delegate;

//Use to change the alpha of background color
//This block will be called when UIPanGestureRecognizer is execute
@property (nonatomic, copy)void(^DMPhotoCellPanStateChange)(CGFloat alpha);

//This block will be called when UIPanGestureRecognizer ended
@property (nonatomic, copy)void(^DMPhotoCellPanStateEnd)(BOOL hide);

//This block will be called when UILongPressGestureRecognizer
@property (nonatomic, copy)void(^DMPhotoCellLongPress)();

//This block will be called after single tapped
@property (nonatomic, copy)void(^DMPhotoCellSingleTap)(UIView *containerView ,UIImageView *imgOrGifImgView);


/**The operations befor the cell will display*/
- (void)willDisplayCell;

/**The operations after the cell is displayed*/
- (void)didEndDisplayingCell;

@end

#pragma mark delegate
@protocol DMPhotoCellDelegate <NSObject>

@optional

@end
