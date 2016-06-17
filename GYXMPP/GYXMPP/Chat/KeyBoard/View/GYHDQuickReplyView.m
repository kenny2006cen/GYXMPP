//
//  GYHDQuickReplyVIew.m
//  company
//
//  Created by apple on 16/3/16.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD. All rights reserved.
//

#import "GYHDQuickReplyView.h"
@interface GYHDQuickReplyView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) UITableView *tableView;
@end
@implementation GYHDQuickReplyView
#pragma mark - 懒加载
- (UITableView *)tableView {
    
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:self.frame style:UITableViewStylePlain];
        tableView.frame = self.bounds;
        tableView.rowHeight = 52.0f;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithObjects:@"快递公司",@"货到付款",@"商品保修",@"您好!......",@"您好!......",@"您好!......", nil];
    }
    return _dataSource;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return self;
//    [self.tableView reloadData];
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    tableView.frame = self.bounds;
    tableView.rowHeight = 52.0f;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:tableView];
    _tableView = tableView;
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    
    return self;
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count - 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"quickReplyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        UILabel *modeLabel = [[UILabel alloc]init];
        modeLabel.text = self.dataSource[indexPath.row];
        modeLabel.font = [UIFont systemFontOfSize:12.0];
        modeLabel.textAlignment = NSTextAlignmentCenter;
        modeLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
        modeLabel.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:164.0/255.0 blue:214.0/255.0 alpha:1.0];
        [cell addSubview:modeLabel];
        [modeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(84);
            make.height.mas_equalTo(42);
        }];
        
        UILabel *replyLabel = [[UILabel alloc]init];
        replyLabel.text = self.dataSource[indexPath.row + 3];
        replyLabel.font = [UIFont systemFontOfSize:16.0];
        [cell addSubview:replyLabel];
        [replyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.equalTo(modeLabel.mas_right).offset(10);
            make.right.mas_equalTo(-18);
            make.height.mas_equalTo(42);
        }]; 
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([self.delegate respondsToSelector:@selector(GYHDKeyboardSelectBaseView:sendDict:SendType:)]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
         dict[@"string"] = [self.dataSource[indexPath.row] stringByAppendingString:self.dataSource[indexPath.row + 3]];
        [self.delegate GYHDKeyboardSelectBaseView:self sendDict:dict SendType:GYHDKeyboardSelectBaseSendText];
    }
}





@end
