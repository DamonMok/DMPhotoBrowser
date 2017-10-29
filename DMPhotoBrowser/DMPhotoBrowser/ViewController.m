//
//  ViewController.m
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "ViewController.h"
#import "UIView+layout.h"
#import <UIImageView+WebCache.h>
#import "DMPhotoBrowser.h"
#import "YYFPSLabel.h"
#import "DMPhotoBrowserCell.h"

static NSString *reuseID = @"DMPhotoBrowser";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

//url
@property (nonatomic, strong)NSArray<DMPhotoBrowserCellModel *> *arrCellModel;

//thumbnail's UIImageView
@property (nonatomic, strong)NSMutableArray *arrThumbnailImgViews;

@property (nonatomic, strong)UITableView *tableView;

@end

@implementation ViewController

- (NSArray<DMPhotoBrowserCellModel *> *)arrCellModel {

    if (!_arrCellModel) {
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"images.plist" ofType:nil];
        NSArray *arrUrl = [NSArray arrayWithContentsOfFile:path];
        
        NSMutableArray *arrTemp = [NSMutableArray array];
        for (int i = 0; i < arrUrl.count; i++) {
            
            DMPhotoBrowserCellModel *cellModel = [DMPhotoBrowserCellModel photoBrowserCellModelWithUrls:arrUrl[i]];
            
            [arrTemp addObject:cellModel];
        }
        
        _arrCellModel = arrTemp;
    }
    
    return _arrCellModel;
}

- (NSMutableArray *)arrThumbnailImgViews {

    if (!_arrThumbnailImgViews) {
        
        _arrThumbnailImgViews = [NSMutableArray array];
    }
    
    return _arrThumbnailImgViews;
}

- (UITableView *)tableView {

    if (!_tableView) {
        
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
}

- (void)initViews {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
    
    
}

#pragma mark - TableView dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.arrCellModel.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    DMPhotoBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    
    if (!cell) {
        
        cell = [[DMPhotoBrowserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    
    cell.arrUrl = self.arrCellModel[indexPath.section].arrUrl;
    
    return cell;
}

#pragma mark - Tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    DMPhotoBrowserCellModel *cellModel = self.arrCellModel[indexPath.section];
    
    return cellModel.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 200.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return [NSString stringWithFormat:@"section-%ld", section];
}

#pragma mark FPS
- (void)initFPS {
    
    YYFPSLabel *labFPS = [[YYFPSLabel alloc] initWithFrame:CGRectMake(0, 30, 50, 30)];
    labFPS.dm_centerX = self.view.center.x-100;
    [labFPS sizeToFit];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:labFPS];
}

@end
