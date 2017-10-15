//
//  DMActionSheetView.h
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DMActionSheetViewSelectedBlock)(int tag);

@interface DMActionSheetView : UIView

@property (nonatomic, copy)DMActionSheetViewSelectedBlock selectedBlock;

+ (instancetype)showActionSheetAddedToView:(UIView *)view datas:(NSArray<NSString *> *)datas;

- (void)hideCompleteHandle:(void(^)())completeHandle;

@end
