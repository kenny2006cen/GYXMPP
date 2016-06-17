//
//  GYHDChatViewController.h
//  HSConsumer
//
//  Created by shiang on 15/12/30.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD. All rights reserved.
//

#import "GYHDBasicViewController.h"


@interface GYHDChatViewController : GYHDBasicViewController
@property (nonatomic, strong) NSDictionary *consumerDictionary;

@property (nonatomic,copy) void(^reloadConsumerBlock)();//block回调刷新
@end
