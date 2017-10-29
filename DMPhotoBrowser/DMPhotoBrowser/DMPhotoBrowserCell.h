//
//  DMPhotoBrowserCell.h
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/29.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMPhotoBrowserCell : UITableViewCell

@property (nonatomic, strong) NSArray *arrUrl;

@end


@interface DMPhotoBrowserCellModel : NSObject

@property (nonatomic, strong) NSArray *arrUrl;

@property (nonatomic, assign) CGFloat cellHeight;

+ (instancetype)photoBrowserCellModelWithUrls:(NSArray *)urls;

@end
