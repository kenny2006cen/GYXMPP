
//
//  RemoteGateway.h
//  Vihome
//
//  Created by Air on 15-3-14.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "Gateway+Send.h"

@interface RemoteGateway : Gateway
// 数据接收
@property (nonatomic, strong) NSMutableArray *sensorTableQueue;
@property (nonatomic, strong) NSMutableArray *wifiTableQueue;
@property(nonatomic,strong,readonly)NSString *session;

+(instancetype)shareInstance;

+(void)refreshServerIpWithThirdId:(NSString *)thirdId completion:(VoidBlock)completion;

/*
 根据用户名来刷新IP更准确
 **/
+(void)refreshServerIpWithUserName:(NSString *)userName completion:(VoidBlock)completion;

/*
验证码登录，同时需要手机号+区号才能确认唯一的idc信息
**/
+(void)refreshServerIpWithPhoneNumber:(NSString *)phoneNumber areaCode:(NSString *)areaCode completion:(VoidBlock)completion;

// 如果某个接口返回idc错误，需要修正TCP链接的IP信息，则调用此方法更新IP
+(void)updateServerIP:(NSString *)newServerIP;

+(HMUserLoginType)userLoginType;

@end
