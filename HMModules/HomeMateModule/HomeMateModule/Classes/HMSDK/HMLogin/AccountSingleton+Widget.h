//
//  AccountSingleton+Widget.h
//  HomeMate
//
//  Created by Air on 17/2/24.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "AccountSingleton.h"

@interface AccountSingleton (Widget)

@property(nonatomic,assign) HMWidgetType widgetType;

-(NSDictionary *)widgetUserInfo;

/// 保存widget所需信息
-(void)widgetSaveUserInfo;

/// 移除widget保存的信息
-(void)widgetRemoveUserInfo;

/**
 *  登录接口，根据widget保存的数据登录，优先token登录，token登录失败则尝试账号密码登录
 *  @param dict 如果传入nil，则自动获取widget保存的数据
 *  @param completion 回调结果
 */
-(void)widgetLoginWithDict:(NSDictionary *)dict completion:(commonBlock)completion;

@end
