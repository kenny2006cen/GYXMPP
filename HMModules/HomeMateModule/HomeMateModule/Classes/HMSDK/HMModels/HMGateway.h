//
//  VihomeGateway.h
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMGateway : HMBaseModel

/**
 *  主键、自增长
 */
@property (nonatomic, retain)NSString *        gatewayId;

/**
 *  版本识别码
 */
@property (nonatomic, assign)int                versionID;

/**
 *  硬件版本
 */
@property (nonatomic, retain)NSString *         hardwareVersion;

/**
 *  软件版本
 */
@property (nonatomic, retain)NSString *         softwareVersion;

/**
 *  静态服务器端口
 */
@property (nonatomic, assign)int                staticServerPort;
/**
 *  静态服务器IP
 */
@property (nonatomic, retain)NSString *         staticServerIP;

/**
 *  动态服务器端口
 */
@property (nonatomic, assign)int                domainServerPort;
/**
 *  服务器动态域名
 */
@property (nonatomic, retain)NSString *         domainName;

/**
 *  本地静态IP
 */
@property (nonatomic, retain)NSString *         localStaticIP;

/**
 *  本地静态网关
 */
@property (nonatomic, retain)NSString *         localGateway;

/**
 *  本地静态子网掩码
 */
@property (nonatomic, retain)NSString *         localNetMask;

/**
 *  DHCP模式
 */
@property (nonatomic, assign)int                dhcpMode;

/**
 *  机身型号
 */
@property (nonatomic, retain)NSString *         model;

/**
 *  旧的主机和WiFi设备，WiFi 芯片的MAC地址就是 UUID
 *  新的主机和WiFi设备，WiFi 芯片的MAC地址只是设备MAC，会单独有UUID
 *
 *  主机或WiFi设备的mac地址
 *  MixPad填WiFi mac地址
 */
@property (nonatomic, retain)NSString *         mac;

/**
 *  家庭名称
 */
@property (nonatomic, retain)NSString *         homeName;


@property (nonatomic, retain)NSString *         password;

/**
 *  时区
 */
@property (nonatomic, retain)NSString *         timeZone;

/**
 *  夏令时标志
 */
@property (nonatomic, assign)int                dst;

/**
 *  信道
 */
@property (nonatomic, assign)int                channel;

/**
 *  个域网ID
 */
@property (nonatomic, assign)int                panID;

/**
 *  扩展ID
 */
@property (nonatomic, assign)int                externalPanID;

/**
 *  秘钥
 */
@property (nonatomic, retain)NSString *         securityKey;

/**
 *  0：表示为主机模式
 */
@property (nonatomic, assign)int                masterSlaveFlag;

/**
 *  协调器版本号
 */
@property (nonatomic, retain)NSString *         coordinatorVersion;


/**
 国家名字
 */
@property (nonatomic, retain)NSString * country;

/**
 国家缩写
 */
@property (nonatomic, retain)NSString * countryCode;

/**
 *  系统版本号
 */
@property (nonatomic, retain)NSString *         systemVersion;

@property (nonatomic, assign)int                netState;


@property (nonatomic, assign)BOOL isAlarmHub;// 是否报警主机

@property (nonatomic, assign)BOOL isMiniHub;

@property (nonatomic, assign)BOOL isViCenterHub;


@property (nonatomic, copy)NSString *bindTimeForSort;// 绑定时间，排序用， 用userGatewayBind 表中的saveTime

/**
 *  根据uid获取网关的所有信息
 *
 *  @param uid 网关uid
 *
 *  @return 返回nil表示没有找到网关
 */
+(HMGateway *)objectWithUid:(NSString *)uid;


/**
 返回所有的网关绑定关系
 */
+(NSArray *)gatewayArr;

//根据蓝牙门锁的蓝牙地址来查gateway
+(HMGateway *)bluetoothLockGateWayWithbleMac:(NSString *)bleMac;

@end
