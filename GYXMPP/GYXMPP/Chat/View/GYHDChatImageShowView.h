//
//  GYHDChatImageShowView.h
//  HSConsumer
//
//  Created by shiang on 16/3/7.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GYHDChatViewController.h"
@interface GYHDChatImageShowView : UIView
- (void)setImageWithUrl:(NSURL *)url;
- (void)show;
- (void)showInView:(UIView *)superView;  // add by jianglincen
@property(nonatomic, strong) NSURL *url;
@property(nonatomic, strong) GYHDChatViewController *delegate;
@end
