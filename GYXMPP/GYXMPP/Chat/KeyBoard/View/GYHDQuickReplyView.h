//
//  GYHDQuickReplyVIew.h
//  company
//
//  Created by apple on 16/3/16.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD. All rights reserved.
//

//#import <UIKit/UIKit.h>
#import "GYHDKeyboardSelectBaseView.h"

@interface GYHDQuickReplyView : GYHDKeyboardSelectBaseView
/**
 *数据源
 */
@property (nonatomic, strong) NSMutableArray *dataSource;
@end