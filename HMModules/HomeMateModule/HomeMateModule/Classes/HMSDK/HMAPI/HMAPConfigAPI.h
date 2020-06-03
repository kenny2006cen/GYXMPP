//
//  HMAPConfigAPI.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"
#import "HMAPConfigMsg.h"

@class HMDevice;
@class HMAPDevice;

typedef NS_ENUM(NSInteger,HmAPDeviceType) {
    HmAPDeviceTypeCOCO,//coco  非usb
    HmAPDeviceTypeLenovo,//Lenovo coco插线板
    HmAPDeviceTypeS20, //s20
    HmAPDeviceTypeZFC, //ZFC
    HmAPDeviceTypeB25, //B25
    HmAPDeviceTypeS30, // s30
    HmAPDeviceTypeS31, // s31
    HmAPDeviceTypeYiDong, // 一栋插座
    HmAPDeviceTypeFeiDiao, // 飞雕排插
    HmAPDeviceTypeXiaoE,  // 小E智能插座
    HmAPDeviceTypeHuaDingStrip,//华顶排插
    HmAPDeviceTypeHuaDingSocket,//华顶插座
    HmAPDeviceTypeAoboer,//奥博尔智能插座
    HmAPDeviceTypeLiangBaHanger, //晾霸晾衣架
    HmAPDeviceTypeORVIBOHanger, //ORVIBO晾衣架
    HmAPDeviceTypeORVIBOHanger_20w, //ORVIBO晾衣架（时尚版）
    HmAPDeviceTypeORVIBOHanger_30w, //ORVIBO晾衣架（旗舰版）
    HmAPDeviceTypeORVIBOHanger_a20, //ORVIBO晾衣架（新款豪华版）
    HmAPDeviceTypeZiChenHanger, //紫宸晾衣架
    HmAPDeviceTypeMaiRunHanger, //麦润晾衣架
    HmAPDeviceTypeBangHeHanger, //邦禾晾衣架
    HmAPDeviceTypeAoKeHanger,// 奥科晾衣架
    HmAPDeviceTypeYuShunHanger,// YUSHUN晾衣架
    HmAPDeviceTypeHomeMate,//统称类型
    HmAPDeviceTypeNeutral, //中性类型
    HmAPDeviceTypeAllone2, // allone2
    HmAPDeviceTypeAllone3, // allone3
    HmAPDeviceTypeCODetector,//CO探测器
    HmAPDeviceTypeHCHODetector,//甲醛探测器
    HmAPDeviceTypeWaterBar,//水吧
    HmAPDeviceTypeRF,//RF主机
    HmAPDeviceTypeWifiCurtain,//WIFI窗帘电机
    HmAPDeviceTypeAlarmHub,//报警主机
    HmAPDeviceTypeYiDongWFG3, // 一栋插座
    HmAPDeviceTypeWifiLEDLight, // Wifi 幻彩灯带
    HmAPDeviceTypeAriMonitor,//空气监测仪
    HmAPDeviceTypeUnkown = 100 //未知类型
};

typedef NS_ENUM(NSInteger, VhAPConfigResult) {
    
    VhAPConfigResult_Connected, // 连接设备成功
    VhAPConfigResult_getDeviceInfoFinish,//获取设备信息成功
    VhAPConfigResult_getOneWifi,// 获取一条wifi
    VhAPConfigResult_getWifiListFinish,// 获取wifi列表完成
    VhAPConfigResult_setDeviceFinish,// ap配置完成
    VhAPConfigResult_setDeviceFail,// ap配置失败
    VhAPConfigResult_unbindSuccess,// 解绑成功
    VhAPConfigResult_unbindFail,// 解绑失败
    VhAPConfigResult_bindSuccess,// 绑定成功
    VhAPConfigResult_bindFail,// 绑定失败
    VhAPConfigResult_bindDeviceOffLine,//绑定设备不在线
    
    VhAPConfigResult_modifyNameSuccess,//修改设备名字成功
    VhAPConfigResult_modifyNameFail,//修改设备名字失败
    
    VhAPConfigResult_getDeviceInfoTimeOut,
    VhAPConfigResult_setDeviceTimeOut,
    VhAPConfigResult_getWifiListTimeOut,
    VhAPConfigResult_StopConnectCOCO,
    
    VhAPConfigResult_Success,//通用成功
    VhAPConfigResult_Fail,//通用失败
    VhAPConfigResult_TimeOut,//通用超时
    
    VhAPConfigResult_CanNotConnectToDeviceWiFi,//当手机没有连接设备的WiFi返回这个错误码
    VhAPConfigResult_disconnectSocket, //断开socket连接
    
};


@protocol VhAPConfigDelegate <NSObject>

- (void)vhApConfigResult:(VhAPConfigResult)result;

@optional
/**
 *  3.4.64本地测量模式接口、3.6.23传感器数据上报接口、3.5.14 AP配置剩余时间上报接口 等 通过这个方法返回结果和数据
 *
 *  @param result    VhAPConfigResult_Success、VhAPConfigResult_Fail、VhAPConfigResult_TimeOut
 *  @param cmd       VhAPConfigCmd_LocalMeasurement,VhAPConfigCmd_SENSOR_DATA_REPORT,VhAPConfigCmd_REMAIN_TIME等
 */
- (void)vhApConfigResult:(VhAPConfigResult)result cmd:(VhAPConfigCmd)cmd returnObj:(id)returnObj;


- (void)hmAPSettingUserInfoCallback:(NSDictionary *)message;

@end



@interface HMAPConfigAPI : HMBaseAPI

/// 设置ap配置的回调
/// @param delegate 代理
+ (void)setAPConfigDelegate:(id<VhAPConfigDelegate>)delegate;


/**
 获取配置成功后HMDevice对象
 */
+ (HMDevice*)getAPConfigHMDevice;


/**
 获取正在配置的HMAPDevice对象
 */
+ (HMAPDevice *)getHMAPDevice;


///  设置ap配置设备类型
/// @param apDeviceType apDeviceType
+ (void)setHmAPDeviceType:(HmAPDeviceType)apDeviceType;


/// 获取ap配置类型
+ (HmAPDeviceType)getHmAPDeviceType;


/**
 连接成功之后是否获取wifi列表

 @param autoRequestWifiList YES 获取 NO 不获取
 */
+ (void)setAutoRequestWifiList:(BOOL)autoRequestWifiList;


/**
 页面是否需要隐藏搜索结果的提示

 @param deviceControllerShowSearchResult YES 不隐藏 NO 隐藏
 */
+ (void)setDeviceControllerShowSearchResult:(BOOL)deviceControllerShowSearchResult;



/**
 判断是否要隐藏局域网搜索结果

 @return YES 不隐藏 NO 隐藏
 */
+ (BOOL)getDeviceControllerShowSearchResult;


/**
 设置是否隐藏局域网搜索设备的alert
 
 @param searchResultAlertHidden NO 不隐藏  YES 隐藏
 */
+ (void)setSearchResultAlertHidden:(BOOL)searchResultAlertHidden;


/**
 判断是否隐藏局域网搜索设备的alert

 @return NO 不隐藏  YES 隐藏
 */
+ (BOOL)getSearchResultAlertHidden;

/**
 设置 CO／HCHO监测仪是否正在连接

 @param isCOorHCHODetecterConnnecting YES 正在连接  NO 不在连接
 */
+ (void)setIsCOorHCHODetecterConnnecting:(BOOL)isCOorHCHODetecterConnnecting;


/**
 判断 CO／HCHO监测仪是否正在连接

 @return YES 是 NO否
 */
+ (BOOL)isCOorHCHODetecterConnnecting;


/**
 获取当前设备配置的设备发出ssid

 @return ssid
 */
+ (NSString *)getCurrentAPDeviceSSID;


/**
 *  搜索COCO
 */
+ (void)searchUnbindCOCO;


/**
 *  搜索coco结果
 */
+ (NSMutableArray *)getSearchCOCOResult;

/**
 移除搜索到的设备
 */
+ (void)removeDeviceArray;

/**
 判断是不是连接的ORVIBO的设备
 
 @return YES 是 NO 不是
 */
+ (BOOL)isORviboDeviceSSID;

/**
 *  刷新wifi
 */
+ (void)reFreshWiFiList;

/**
 *  停止请求wifi
 */
+ (void)stopRequestWiFi;

/**
 *  修改设备名称
 */
+ (void)modifyDeviceName:(NSString *)deviceName;

/**
 *  停止连接
 */
+ (void)stopConnectToCOCO;


/**
 *  判断是否连接到COCO
 */
+ (BOOL)isConnectedToDevice;

/**
 *  绑定设备
 */
+ (void)startBindDevice;


/**
 *  解绑设备,第一次调用这个方法需要给deleteDataDelegate赋值
 */
+ (void)startUnBindDevice;


/**
 *  取消绑定
 */
+ (void)stopBindDevice;

/**
 *  配置设备wifi
 */
+ (void)settingDevice:(NSString *)ssid pwd:(NSString *)pwd timeOut:(NSTimeInterval)timeOut;


/**
 *  请求WiFi列表
 */
+ (void)requestWifiListTimeOut:(NSTimeInterval)timeOut;

/**
 *  获取wifi列表
 *
 *  @return wifi
 */
+ (NSMutableArray *)getOrderWifiList;

/**
 *  获取默认SSID
 *
 *  @return 默认ssid
 */
+ (NSString *)getDefaultSSID;

/**
 *  保存用户默认SSID
 */
+ (void)setDefaultSSID;

/// 判断设备和Wifi名称是否对应
+ (BOOL)isCOCOSsid;


/**
 *  获取手机正在连接的ssid
 *
 *  @return ssid
 */
+ (NSString *)currentConnectSSID;

/**
 *  断开设备连接
 */
+ (void)disConnect;


/**
 *  连接设备
 */
+ (void)connetToHost;


/**
 *  绑定成功后，把返回的数据插入到数据库
 */
+ (void)insertToDataBase:(NSDictionary *)returnDic isSearch:(BOOL)isSearch;



/**
 *  甲醛、CO 本地测试模式
 *
 *  @param uid     设备uid
 *  @param cmdType 0：开始本地测量模式  1：结束本地测量模式
 */
+ (void)localMeasurementWithUid:(NSString *)uid cmdType:(int)cmdType;


/**
 *  一段时间内都不允许再连接Host
 */
+ (void)dontConnectHostForAWhile:(NSTimeInterval)littleTime;


@end
