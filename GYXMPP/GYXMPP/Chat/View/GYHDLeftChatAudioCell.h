//
//  GYHDLeftChatAudioCell.h
//  HSConsumer
//
//  Created by shiang on 16/3/1.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GYHDBaseChatCell.h"
#import "GYHDChatDelegate.h"

@class GYHDNewChatModel;
@interface GYHDLeftChatAudioCell : GYHDBaseChatCell
@property(nonatomic, weak) GYHDNewChatModel *chatModel;
@property(nonatomic, weak) id<GYHDChatDelegate> delegate;
- (void)startAudioAnimation;
- (void)stopAudioAnimation;
- (BOOL)isAudioAnimation;
@end
