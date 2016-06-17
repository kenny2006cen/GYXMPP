//
//  GYHDVideoView.h
//  HSConsumer
//
//  Created by shiang on 16/2/15.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//  录制视频界面

//#import <UIKit/UIKit.h>

#import "GYHDKeyboardSelectBaseView.h"
@interface GYHDVideoView : GYHDKeyboardSelectBaseView

//是否开启相机权限
+ (BOOL)isCameraAuth;

//提示相机权限信息
+ (void)showAuthInfo;
@end
