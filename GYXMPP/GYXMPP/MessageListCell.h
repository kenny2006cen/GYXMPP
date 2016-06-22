//
//  GYHDBusinessCell.h
//  company
//
//  Created by apple on 16/2/16.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GYMessage;
#import <Masonry/Masonry.h>
#import "SWTableViewCell.h"
#import "PPDragDropBadgeView.h"

@interface MessageListCell : SWTableViewCell

+ (instancetype)cellWithTableView:(UITableView * )tableView;
/**
 *数据模型
 */
@property(nonatomic, strong) GYMessage *businessModel;

@end
