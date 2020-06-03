//
//  HMProtocol.h
//  HomeMate
//
//  Created by Air on 16/9/24.
//  Copyright © 2017年 Air. All rights reserved.
//

#ifndef HMProtocol_h
#define HMProtocol_h

#import "AccountProtocol.h"

@class HMDevice;

@protocol SocketSendBusinessProtocol <NSObject>

@optional

/**
 *  toast 提示信息
 */
-(void)popAlert:(NSString *)alert;

/**
 *  显示默认的loading
 */
-(void)displayLoading;

/**
 *  停止默认的loading
 */
-(void)stopLoading;

@end

@protocol HMFloorRoomProtocol <NSObject>

@optional

/**
 *  楼层房间信息，因含有字符串资源，所以需要SDK的delegate来实现
 */

-(NSString *)floorAndRoom:(HMDevice *)device;

@end


@protocol HMBusinessProtocol <SocketSendBusinessProtocol,AccountProtocol,HMFloorRoomProtocol>

@optional

/**
 *  VRV面板上报弹框
 */
-(void)showVRVReportView:(NSString *)deviceName;

/**
 *  接收到错误码26，30，48 时调用此接口 数据已不存在
 */
-(void)handleDataNotExist:(NSDictionary *)dic;

/**
 *  删除wifi设备/主机上报接口
 */
-(void)handleDevcieDeletedReport:(NSDictionary *)payloadDic;


/**
 *  接收到任意数据时给委托对象的回调
 */
-(void)receiveDataCallback:(NSDictionary *)payloadDic;

/**
 *  接收到推送信息
 */
-(void)handlePushInfo:(NSDictionary *)resultDic;

/**
 *  后台自动登录时，服务器返回用户名密码错误
 */
-(void)logoutForPwdError;

/**
 *  后台自动登录时，服务器返回登录token过期
 */
-(void)logoutForTokenExpired;

/**
 *  向服务器查询传感器设备的最新状态（记录）
 */
-(void)queryLastestMsg;

/**
 *  查询主机升级状态
 */
-(void)checkHostUpgradeStatus;

/**
 处理配电箱属性报告
 */
-(void)handleDistBoxStatusReportWithDic:(NSDictionary *)dic;


/**
 *  控制指令下发后，电信设备网络异常时，统一弹框
 */
-(void)popAlertForTelecomDeviceNetworkError;

@end




#endif /* HMProtocol_h */
