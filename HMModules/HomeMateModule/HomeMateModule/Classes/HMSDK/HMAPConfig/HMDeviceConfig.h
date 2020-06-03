//
//  VhAPConfig.h
//  HomeMateSDK
//
//  Created by Orvibo on 15/8/5.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMAPConfigMsg.h"
#import "HMAPConfigCallback.h"
#import "HMAPDevice.h"
#import "HMAPDeleteDeviceProtocol.h"
#import "HMAPConfigAPI.h"


@interface HMDeviceConfig : NSObject

@property (nonatomic, weak) id <VhAPConfigDelegate> delegate;

@property (nonatomic, assign) HmAPDeviceType apDeviceType;

@property (nonatomic, strong) NSString * ssid; // 配置设备时发送的ssid

@property (strong, nonatomic) HMAPDevice * APDevice;
@property (strong, nonatomic) HMDevice * vhDevice;

@property (nonatomic, assign) BOOL stopSetDevice;

@property (nonatomic, assign) BOOL autoRequestWifiList;

@property (nonatomic,assign) BOOL deviceControllerShowSearchResult;

@property (nonatomic, assign) BOOL searchResultAlertHidden; //是否需要隐藏搜索结果的alert default = NO

@property (nonatomic, assign) BOOL isCOorHCHODetecterConnnecting;   ///< CO／HCHO监测仪是否正在连接

/**
 *  重新绑定设备成功后，会自动删除数据库中的数据，其它本地数据由遵循这个协议的类删除
 */
@property (nonatomic, weak) id<HMAPDeleteDeviceProtocol>deleteDataDelegate;

@property (nonatomic, strong) NSMutableArray * lockUserInfo;


+ (instancetype)defaultConfig;


- (NSString *)getCurrentAPDeviceSSID;


/**
 *  搜索COCO
 */
- (void)searchUnbindCOCO;
/**
 *  搜索coco结果
 */
- (NSMutableArray *)getSearchCOCOResult;

- (void)removeDeviceArray;


- (void)onTimeout:(HMAPConfigMsg *)msg;

- (BOOL)isORviboDeviceSSID;

/**
 *  请求WiFi列表
 */
- (void)requestWifiListTimeOut:(NSTimeInterval)timeOut;

/**
 *  刷新wifi
 */
- (void)reFreshWiFiList;


/**
 *  停止请求wifi
 */
- (void)stopRequestWiFi;


/**
 *  修改设备名称
 */
- (void)modifyDeviceName:(NSString *)deviceName;

/**
 *  停止连接
 */
- (void)stopConnectToCOCO;
/**
 *  判断是否连接到COCO
 *
 */
- (BOOL)isConnectedToDevice;

/**
 *  绑定设备
 */
- (void)startBindDevice;

/**
 *  解绑设备,第一次调用这个方法需要给deleteDataDelegate赋值
 */
- (void)startUnBindDevice;
/**
 *  取消绑定
 */
- (void)stopBindDevice;

/**
 *  配置设备wifi
 */
- (void)settingDevice:(NSString *)ssid pwd:(NSString *)pwd timeOut:(NSTimeInterval)timeOut;


/**
 *  获取wifi列表
 *
 *  @return wifi
 */
- (NSMutableArray *)getOrderWifiList;

/**
 *  获取默认SSID
 *
 *  @return 默认ssid
 */
- (NSString *)getDefaultSSID;

/**
 *  保存用户默认SSID
 */
- (void)setDefaultSSID;

/**
 *  判断设备和Wifi名称是否对应
 *
 */
- (BOOL)isCOCOSsid;

//判断手机连的是否为设备的ssid
- (BOOL)isAlarmHubSsid;

/**
 *  获取手机正在连接的ssid
 *
 *  @return ssid
 */
- (NSString *)currentConnectSSID;


/**
 *  断开设备连接
 */
- (void)disConnect;

/**
 *  连接设备
 */
- (void)connetToHost;


/**
 *  绑定成功后，把返回的数据插入到数据库
 */
- (void)insertToDataBase:(NSDictionary *)returnDic isSearch:(BOOL)isSearch;



/**
 *  甲醛、CO 本地测试模式
 *
 *  @param uid     设备uid
 *  @param cmdType 0：开始本地测量模式  1：结束本地测量模式
 */
- (void)localMeasurementWithUid:(NSString *)uid cmdType:(int)cmdType;

/**
 *  一段时间内都不允许再连接Host
 */
- (void)dontConnectHostForAWhile:(NSTimeInterval)littleTime;





- (void)sendLockMsg:(HMAPConfigMsg *)msg callback:(void(^)(int status,NSDictionary *payload))callback;


- (BOOL)connectedToDevice:(HMDevice*)device;

+ (NSString *)appName;

@end
