//
//  DMActionSheetView.m
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/15.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "DMActionSheetView.h"

#define kSectionMargin 5

static NSString *reuseId = @"DMActionSheetView";

@interface DMActionSheetView ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)NSArray *datas;

@end

@implementation DMActionSheetView

- (UITableView *)tableView {

    if (!_tableView) {
        
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return _tableView;
}

+ (instancetype)showActionSheetAddedToView:(UIView *)view datas:(NSArray<NSString *> *)datas {

    DMActionSheetView *actionSheetView = [[self alloc] initWithView:view];
    [view addSubview:actionSheetView];
    
    [actionSheetView configViewWithDatas:datas];
    
    return actionSheetView;
}

- (void)configViewWithDatas:(NSArray *)datas {

    _datas = datas;
    self.tableView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    [self addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.tableView.contentSize.height);
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.tableView.frame = CGRectMake(0, self.bounds.size.height-self.tableView.contentSize.height, self.bounds.size.width, self.tableView.contentSize.height);
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.4];
    }];
}

- (instancetype)initWithView:(UIView *)view {
    
    return [self initWithFrame:view.bounds];
}

- (instancetype)initWithFrame:(CGRect)frame {

    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        
    }
    
    return self;
}

#pragma mark - TableView datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return _datas.count;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    
    if (indexPath.section == 0) {
        
        cell.textLabel.text = _datas[indexPath.row];
        
    } else {
    
        cell.textLabel.text = @"取消";
    }
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor colorWithRed:248/255.0 green:240/255.0 blue:230/255.0 alpha:1];
    cell.textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    
    return cell;
}

#pragma mark - TableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return kSectionMargin;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kSectionMargin)];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        //action
        [self hideCompleteHandle:^{
            
            if (self.selectedBlock) {
                self.selectedBlock((int)indexPath.row);
            }
        }];
        
        
    } else {
        //cancle
        [self hideCompleteHandle:nil];
    }
}

- (void)hideCompleteHandle:(void (^)())completeHandle {

    [UIView animateWithDuration:0.2 animations:^{
        
        self.tableView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.tableView.contentSize.height);
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
        if (completeHandle) {
            completeHandle();
        }
    }];
}

#pragma mark - hide
- (void)didTap {

    [self hideCompleteHandle:nil];
}

#pragma mark - UIGestureRecognizer delegate
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//
//    return YES;
//}


//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//
//    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
//        CGPoint tapPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
//        if (CGRectContainsPoint(_tableView.frame, tapPoint)) {
//            
//            return NO;
//        }
//    }
//    
//    return YES;
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // 若点击了tableViewCell，则不截获Touch事件
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        return NO;
    }
    return  YES;
}

- (void)dealloc {

    NSLog(@"%s", __func__);
}

@end
