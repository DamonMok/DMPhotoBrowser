//
//  ViewController.m
//  DMPhotoBrowser
//
//  Created by Damon on 2017/10/8.
//  Copyright © 2017年 damon. All rights reserved.
//

#import "ViewController.h"
#import "UIView+layout.h"
#import "DMPhotoBrowser.h"
#import "DMPhotoBrowserCell.h"


static NSString *reuseID = @"DMPhotoBrowser";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

//url
@property (nonatomic, strong)NSMutableArray<DMPhotoBrowserCellModel *> *arrCellModel;

//thumbnail's UIImageView
@property (nonatomic, strong)NSMutableArray *arrThumbnailImgView;

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, assign) BOOL fromInternet;

@end

@implementation ViewController

- (NSMutableArray<DMPhotoBrowserCellModel *> *)arrCellModel {

    if (!_arrCellModel) {
        
        NSMutableArray *arrTemp = [NSMutableArray array];
        
        _arrCellModel = arrTemp;
    }
    
    return _arrCellModel;
}

- (NSMutableArray *)arrThumbnailImgView {

    if (!_arrThumbnailImgView) {
        
        _arrThumbnailImgView = [NSMutableArray array];
    }
    
    return _arrThumbnailImgView;
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
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
    
    UILabel *labDesc = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    labDesc.text = @"网络图片";
    labDesc.textColor = [UIColor blackColor];
    labDesc.font = [UIFont systemFontOfSize:14.0];
    [labDesc sizeToFit];
    labDesc.dm_centerY = titleView.dm_height*0.5;
    [titleView addSubview:labDesc];
    
    UISwitch *swt = [[UISwitch alloc] initWithFrame:CGRectMake(labDesc.dm_width+4, 0, 0, 0)];
    swt.on = YES;
    self.fromInternet = YES;
    [swt addTarget:self action:@selector(didChangeSwitchStatus:) forControlEvents:UIControlEventValueChanged];
    swt.dm_centerY = titleView.dm_centerY;
    [titleView addSubview:swt];
    [self didChangeSwitchStatus:swt];
    
    self.navigationItem.titleView = titleView;
    
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
    
    cell.fromInternet = self.fromInternet;
    
    cell.arrModel = self.fromInternet ? self.arrCellModel[indexPath.section].arrUrl : self.arrCellModel[indexPath.section].arrImage;
    
    return cell;
}

#pragma mark - Tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    DMPhotoBrowserCellModel *cellModel = self.arrCellModel[indexPath.section];
    
    return cellModel.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 20.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return [NSString stringWithFormat:@"section-%ld", section];
}

#pragma mark - UISwitch
- (void)didChangeSwitchStatus:(UISwitch *)sender {

    [self.arrCellModel removeAllObjects];
    
    NSString *path = nil;
    
    if (sender.on) {
        //Source from internet
        path = [[NSBundle mainBundle] pathForResource:@"images_internet.plist" ofType:nil];
        
        self.fromInternet = YES;
        
    } else {
        //Source from local
        path = [[NSBundle mainBundle] pathForResource:@"images_local.plist" ofType:nil];
        
        self.fromInternet = NO;
    }
    
    NSArray *arrModel = [NSArray arrayWithContentsOfFile:path];
    
    for (int i = 0; i < arrModel.count; i++) {
        
        DMPhotoBrowserCellModel *cellModel = nil;
        
        cellModel = sender.on ? cellModel = [DMPhotoBrowserCellModel photoBrowserCellModelWithUrls:arrModel[i]] : [DMPhotoBrowserCellModel photoBrowserCellModelWithImages:arrModel[i]];
        
        [self.arrCellModel addObject:cellModel];
    }
    
    [self.tableView reloadData];
}


@end
