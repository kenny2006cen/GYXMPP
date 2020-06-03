//
//  HMAPConfigAPI.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAPConfigAPI.h"
#import "HMDeviceConfig.h"

@implementation HMAPConfigAPI

/**
 设置ap配置的回调
 
 @param delegate
 */
+ (void)setAPConfigDelegate:(id<VhAPConfigDelegate>)delegate {
    
    [HMDeviceConfig defaultConfig].delegate = delegate;
}

/**
 获取配置成功后HMDevice对象
 
 @return
 */
+ (HMDevice*)getAPConfigHMDevice {
    return [HMDeviceConfig defaultConfig].vhDevice;
}

/**
 获取正在配置的HMAPDevice对象
 
 @return
 */
+ (HMAPDevice *)getHMAPDevice {
    return [HMDeviceConfig defaultConfig].APDevice;
}

/**
 设置ap配置设备类型
 
 @param apDeviceType
 */
+ (void)setHmAPDeviceType:(HmAPDeviceType)apDeviceType {
    [HMDeviceConfig defaultConfig].apDeviceType = apDeviceType;
}


/**
 获取ap配置类型
 
 @return
 */
+ (HmAPDeviceType)getHmAPDeviceType {
   return [HMDeviceConfig defaultConfig].apDeviceType;
}
/**
 连接成功之后是否获取wifi列表
 
 @param autoRequestWifiList YES 获取 NO 不获取
 */
+ (void)setAutoRequestWifiList:(BOOL)autoRequestWifiList {
    [HMDeviceConfig defaultConfig].autoRequestWifiList = autoRequestWifiList;
}

/**
 是否需要隐藏搜索结果的alert
 
 @param deviceControllerShowSearchResult YES 不隐藏 NO 隐藏
 */
+ (void)setDeviceControllerShowSearchResult:(BOOL)deviceControllerShowSearchResult {
    [HMDeviceConfig defaultConfig].deviceControllerShowSearchResult = deviceControllerShowSearchResult;
}

/**
 判断是否要隐藏局域网搜索结果
 
 @return YES 不隐藏 NO 隐藏
 */
+ (BOOL)getDeviceControllerShowSearchResult {
    return [HMDeviceConfig defaultConfig].deviceControllerShowSearchResult;
}

+ (void)setIsCOorHCHODetecterConnnecting:(BOOL)isCOorHCHODetecterConnnecting {
    [HMDeviceConfig defaultConfig].isCOorHCHODetecterConnnecting = isCOorHCHODetecterConnnecting;
}

+ (BOOL)isCOorHCHODetecterConnnecting {
    return [HMDeviceConfig defaultConfig].isCOorHCHODetecterConnnecting;
}


/**
 设置是否隐藏局域网搜索设备的alert
 
 @param searchResultAlertHidden NO 不隐藏  YES 隐藏
 */
+ (void)setSearchResultAlertHidden:(BOOL)searchResultAlertHidden {
     [HMDeviceConfig defaultConfig].searchResultAlertHidden = searchResultAlertHidden;
}


/**
 判断是否隐藏局域网搜索设备的alert
 
 @return NO 不隐藏  YES 隐藏
 */
+ (BOOL)getSearchResultAlertHidden {
    return [HMDeviceConfig defaultConfig].searchResultAlertHidden;

}


/**
 获取当前设备配置的设备发出ssid
 
 @return ssid
 */
+ (NSString *)getCurrentAPDeviceSSID {
   return [[HMDeviceConfig defaultConfig] getCurrentAPDeviceSSID];
}

/**
 *  搜索COCO
 */
+ (void)searchUnbindCOCO {
    [[HMDeviceConfig defaultConfig] searchUnbindCOCO];
}

/**
 *  搜索coco结果
 *
 *  @return
 */
+ (NSMutableArray *)getSearchCOCOResult {
   return  [[HMDeviceConfig defaultConfig] getSearchCOCOResult];
}

/**
 移除搜索到的设备
 */
+ (void)removeDeviceArray {
    [[HMDeviceConfig defaultConfig] removeDeviceArray];
}

/**
 判断是不是连接的ORVIBO的设备

 @return YES 是 NO 不是
 */
+ (BOOL)isORviboDeviceSSID {
   return  [[HMDeviceConfig defaultConfig] isORviboDeviceSSID];
}

/**
 *  请求WiFi列表
 */
+ (void)requestWifiListTimeOut:(NSTimeInterval)timeOut {
    [[HMDeviceConfig defaultConfig] requestWifiListTimeOut:timeOut];
}

/**
 *  刷新wifi
 */
+ (void)reFreshWiFiList {
    [[HMDeviceConfig defaultConfig] reFreshWiFiList];
}

/**
 *  停止请求wifi
 */
+ (void)stopRequestWiFi {
    [[HMDeviceConfig defaultConfig] stopRequestWiFi];
}

/**
 *  修改设备名称
 *
 *  @param deveceName
 */
+ (void)modifyDeviceName:(NSString *)deviceName {
    [[HMDeviceConfig defaultConfig] modifyDeviceName:deviceName];
}

/**
 *  停止连接
 */
+ (void)stopConnectToCOCO {
    [[HMDeviceConfig defaultConfig] stopConnectToCOCO];
}

/**
 *  判断是否连接到COCO
 *
 *  @return
 */
+ (BOOL)isConnectedToDevice {
   return  [[HMDeviceConfig defaultConfig] isConnectedToDevice];
}
/**
 *  绑定设备
 */
+ (void)startBindDevice {
    [[HMDeviceConfig defaultConfig] startBindDevice];
}

/**
 *  解绑设备,第一次调用这个方法需要给deleteDataDelegate赋值
 */
+ (void)startUnBindDevice {
    [[HMDeviceConfig defaultConfig] startUnBindDevice];
}

/**
 *  取消绑定
 */
+ (void)stopBindDevice {
    [[HMDeviceConfig defaultConfig] stopBindDevice];
}

/**
 *  配置设备wifi
 *
 *  @param ssid
 *  @param pwd
 */
+ (void)settingDevice:(NSString *)ssid pwd:(NSString *)pwd timeOut:(NSTimeInterval)timeOut {
    [[HMDeviceConfig defaultConfig] settingDevice:ssid pwd:pwd timeOut:timeOut];
}


/**
 *  获取wifi列表
 *
 *  @return wifi
 */
+ (NSMutableArray *)getOrderWifiList {
  return  [[HMDeviceConfig defaultConfig] getOrderWifiList];
}

/**
 *  获取默认SSID
 *
 *  @return 默认ssid
 */
+ (NSString *)getDefaultSSID {
   return  [[HMDeviceConfig defaultConfig] getDefaultSSID];
}
/**
 *  保存用户默认SSID
 */
+ (void)setDefaultSSID {
    [[HMDeviceConfig defaultConfig] setDefaultSSID];
}

/**
 *  判断设备和Wifi名称是否对应
 *
 *  @return
 */
+ (BOOL)isCOCOSsid {
    return [[HMDeviceConfig defaultConfig] isCOCOSsid];
}

/**
 *  获取手机正在连接的ssid
 *
 *  @return ssid
 */
+ (NSString *)currentConnectSSID {
    return [[HMDeviceConfig defaultConfig] currentConnectSSID];
}

/**
 *  断开设备连接
 */
+ (void)disConnect {
    [[HMDeviceConfig defaultConfig] disConnect];
}


/**
 *  连接设备
 */
+ (void)connetToHost {
    [[HMDeviceConfig defaultConfig] connetToHost];
}


/**
 *  绑定成功后，把返回的数据插入到数据库
 */
+ (void)insertToDataBase:(NSDictionary *)returnDic isSearch:(BOOL)isSearch {
    [[HMDeviceConfig defaultConfig] insertToDataBase:returnDic isSearch:isSearch];
}

/**
 *  甲醛、CO 本地测试模式
 *
 *  @param uid     设备uid
 *  @param cmdType 0：开始本地测量模式  1：结束本地测量模式
 */
+ (void)localMeasurementWithUid:(NSString *)uid cmdType:(int)cmdType {
    [[HMDeviceConfig defaultConfig] localMeasurementWithUid:uid cmdType:cmdType];
}


/**
 *  一段时间内都不允许再连接Host
 */
+ (void)dontConnectHostForAWhile:(NSTimeInterval)littleTime {
    [[HMDeviceConfig defaultConfig] dontConnectHostForAWhile:littleTime];
}

@end
