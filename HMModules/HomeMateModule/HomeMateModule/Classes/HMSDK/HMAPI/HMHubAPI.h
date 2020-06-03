//
//  HMHubAPI.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"
#import "HMTypes.h"

@class Gateway;

@interface HMHubAPI : HMBaseAPI

/**
 添加网关
 @param gateway Gateway对象
 @param valueBlock 添加结果
 */
+ (void)addGateway:(Gateway *)gateway result:(KReturnValueBlock)valueBlock;

/**
 添加网关
 
 @param gateway Gateway对象
 @param reSend 是否重发
 @param valueBlock 添加结果
 */
+ (void)addGateway:(Gateway *)gateway reSend:(BOOL)reSend result:(KReturnValueBlock)valueBlock;


/**  ---------- 如果想对绑定主机的返回数据作进一步处理，可调用此接口 -----------
 添加网关
 @param gateway Gateway对象
 @param completion 返回server 数据，可供进一步处理
 */
+ (void)addGateway:(Gateway *)gateway completion:(commonBlockWithObject)completion;



/**
 开启搜索ZigBee设备
 @param valueBlock 0：成功  其他：失败
 */
+ (void)openSearchZigBeeDevice:(KReturnValueBlock)valueBlock;

/**
 指定网关开启组网
 
 @param uids 网关uids
 @param completion 服务器返回数据
 */
+ (void)openSearchZigBeeDeviceInGatewayUids:(NSArray *)uids completion:(commonBlockWithObject)completion;


/**
 停止搜索ZigBee设备
 @param valueBlock  0：成功  其他：失败
 */
+ (void)closeSearchZigBeeDevice:(KReturnValueBlock)valueBlock;


/**
 获取已经被当前家庭添加的网关
 @param gatewaysBlock 回调已添加网关数组 （数组对象为 Gateway）
 */
+ (void)getGatewaysAdded:(void(^)(NSArray *gateways))gatewaysBlock;

/**
 搜索当前wifi下的网关
 */
+ (void)searchCurrentWifiGateways:(void(^)(NSArray *gateways))gatewaysBlock;

/**
 查询网关状态 （本地登录主机查询）
 @param gateway Gateway对象
 */
+ (void)queryGateway:(Gateway *)gateway status:(void(^)(HMGatewayStatus status))resultBlock;

/**
 查询主机绑定状态 （从服务器查询）

 @param uidList uid String数组   如 @[@"007e56880"]
 @param completion 返回绑定的uid列表，未绑定的不返回
 */
+ (void)queryBindStatusWithUidList:(NSArray *)uidList completion:(commonBlockWithObject)completion;

/**
 查询局域网内未绑定的报警主机
 @param completion 成功返回 0 和 网关Gateway对象，失败返回 错误码和nil
 */
+ (void)searchUnbindAlarmHostInLocalNetWorkRetBlock:(commonBlockWithObject)completion;

/**
 获取网关的名字
 
 @param gateway Gateway 对象
 @return 名字
 */
+ (NSString *)nameWithGateway:(Gateway *)gateway;


/**
 查询MixPad 的二维码信息

 @param token 二维码里的token
 @param completion 服务器返回数据
 */
+ (void)queryMixPadQrcodeWithToken:(NSString *)token block:(commonBlockWithObject)completion;


@end
