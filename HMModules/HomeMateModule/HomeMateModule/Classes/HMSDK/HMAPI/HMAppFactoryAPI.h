//
//  HMAppFactoryAPI.h
//  HomeMateSDK
//
//  Created by liqiang on 17/5/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseAPI.h"
#import <UIKit/UIKit.h>
#import "HomeMateSDK.h"


typedef void(^AppFactoryUpdateCallback)(BOOL appFactoryUpdate);

// 智能开关
static NSString * const addDeviceSwitchDefault = @"homemate://addDevice/switch/switchDefault";

// 智能照明
static NSString * const addDeviceLightDefault = @"homemate://addDevice/light/lightDefault";

// 智能调光模块
static NSString * const addSmartDimmerLightDefault = @"homemate://addDevice/light/dimmer_model";

// 智能门锁
static NSString * const addDeviceLockDefault = @"homemate://addDevice/smartlock/lockDefault";

// 智能音箱
static NSString * const addDeviceSoundDefault = @"homemate://addDevice/sound/soundDefault";

// 声必可智能音箱
static NSString * const addDeviceSoundAispeaker = @"homemate://addDevice/sound/soundAispeaker";

// 智能空气开关管理器
static NSString * const addDeviceDistboxDefault = @"homemate://addDevice/distbox/distboxDefault";

// 多功能控制盒
static NSString * const addDevicecOntrolboxDefault = @"homemate://addDevice/controlbox/controlboxDefault";

// 公子小白
static NSString * const addDeviceRobotDefault = @"homemate://addDevice/robot/robotDefault";

// coco
static NSString * const addDeviceSocketCoco = @"homemate://addDevice/socket/coco";

// s30
static NSString * const addDeviceSocketS30 = @"homemate://addDevice/socket/s30";
// s31
static NSString * const addDeviceSocketS31 = @"homemate://addDevice/socket/s31_us";

// s20
static NSString * const addDeviceSocketS20 = @"homemate://addDevice/socket/s20";
// s20c
static NSString * const addDeviceSocketS20c = @"homemate://addDevice/socket/s20c";
// s25
static NSString * const addDeviceSocketS25 = @"homemate://addDevice/socket/s25";

// b25
static NSString * const addDeviceSocketB25Aus = @"homemate://addDevice/socket/b25_aus";
// b25
static NSString * const addDeviceSocketB25Eu = @"homemate://addDevice/socket/b25_eu";
// b25
static NSString * const addDeviceSocketB25Uk = @"homemate://addDevice/socket/b25_uk";
// b25
static NSString * const addDeviceSocketB25Us = @"homemate://addDevice/socket/s25_us";


// b25
static NSString * const addDeviceSwitchDimmerEU = @"homemate://addDevice/switch/dimmer_switch_eu";
// b25
static NSString * const addDeviceSwitchDimmerUS = @"homemate://addDevice/switch/dimmer_switch_us";
// b25
static NSString * const addDeviceSwitchSceneUS = @"homemate://addDevice/switch/scene_switch_us";
// b25
static NSString * const addDeviceSwitchSmartOuletUS = @"homemate://addDevice/switch/smart_oulet_us";
// b25
static NSString * const addDeviceSwitchSmartOuletMeterUS = @"homemate://addDevice/switch/smart_outlet_meter_us";
// b25
static NSString * const addDeviceSwitchSmartSwitchEU = @"homemate://addDevice/switch/smart_switch_eu";
// b25
static NSString * const addDeviceSwitchSmartSwitchUS = @"homemate://addDevice/switch/smart_switch_us";

// Aurora Series Switch
static NSString * const addDeviceSwitchAuroraSeriesSwitch = @"homemate://addDevice/switch/aurora_series_switch";
// Bliss Series Switch
static NSString * const addDeviceSwitchBlissSeriesSwitch = @"homemate://addDevice/switch/bliss_series_switch";
// Geekrav Series Switch
static NSString * const addDeviceSwitchGeekravSeriesSwitch = @"homemate://addDevice/switch/geekrav_series_switch";
// Platium Series Switch
static NSString * const addDeviceSwitchPlatiumSeriesSwitch = @"homemate://addDevice/switch/platium_series_switch";
// Insert Module Relay
static NSString * const addDeviceSwitchInsertModuleRelay = @"homemate://addDevice/switch/insert_module_relay";


// 一栋
static NSString * const addDeviceSocketYidong = @"homemate://addDevice/socket/yidong";
// 林肯
static NSString * const addDeviceSocketLincoln = @"homemate://addDevice/socket/lincoln";
// 小E
static NSString * const addDeviceSocketXiaoE = @"homemate://addDevice/socket/xiaoe";
// ZFC
static NSString * const addDeviceSocketZFC = @"homemate://addDevice/socket/zfcstrip";
// 其他插座
static NSString * const addDeviceSocketOtheroutlet = @"homemate://addDevice/socket/otheroutlet";
// 博顿插座
static NSString * const addDeviceSocketBoton = @"homemate://addDevice/socket/boton";





// 小方
static NSString * const addDeviceRemoteXiaoF = @"homemate://addDevice/remote/xiaofang";
// 小圆
static NSString * const addDeviceRemoteXiaoY = @"homemate://addDevice/remote/allone3";
// all one
static NSString * const addDeviceRemoteZigbeeAllone = @"homemate://addDevice/remote/zigbeeallone";
// 智能遥控器
static NSString * const addDeviceRemoteRemotecontrol = @"homemate://addDevice/remote/remotecontrol";



// 门磁
static NSString * const addDeviceSensorDoorsensor = @"homemate://addDevice/sensor/doorsensor";
//人体红外
static NSString * const addDeviceSensorMotionsensor = @"homemate://addDevice/sensor/motionsensor";
// 人体光照
static NSString * const addDeviceSensorMotionlight = @"homemate://addDevice/sensor/motionlight";
// CO监测
static NSString * const addDeviceSensorCO = @"homemate://addDevice/sensor/co";
// 甲醛监测
static NSString * const addDeviceSensorHcho = @"homemate://addDevice/sensor/hcho";
// 烟雾报警器
static NSString * const addDeviceSensorHmsmoke = @"homemate://addDevice/sensor/hmsmoke";
// CO报警器
static NSString * const addDeviceSensorHmco = @"homemate://addDevice/sensor/hmco";
// 可燃气体报警器
static NSString * const addDeviceSensorHmburn = @"homemate://addDevice/sensor/hmburn";
// 水浸探测器
static NSString * const addDeviceSensorHmwater = @"homemate://addDevice/sensor/hmwater";
// 温湿度探测器
static NSString * const addDeviceSensorHmtemp = @"homemate://addDevice/sensor/hmtemp";
// 紧急按钮
static NSString * const addDeviceSensorHmButton = @"homemate://addDevice/sensor/hmbutton";
// 信号输入模块
static NSString * const addDeviceSensorSormodule = @"homemate://addDevice/sensor/sensormodule";




// 萤石摄像机
static NSString * const addDeviceCameraYingshi = @"homemate://addDevice/camera/yingshi";
// 小欧摄像机
static NSString * const addDeviceCameraXiaoou = @"homemate://addDevice/camera/xiaoou";
// 云台摄像机
static NSString * const addDeviceCameraYuntai = @"homemate://addDevice/camera/yuntai";
// 云台摄像机(S30PT)
static NSString * const addDeviceCameraSC30PT = @"homemate://addDevice/camera/sc30pt";

// p2p摄像机
static NSString * const addDeviceCameraP2P = @"homemate://addDevice/camera/p2p";



// ORVIBO晾衣机
static NSString * const addDeviceHangerOrvibo = @"homemate://addDevice/hanger/orvibo";

//ORVIBO晾衣架（时尚版）
static NSString * const addDeviceHangerOrvibo_20w = @"homemate://addDevice/hanger/orvibo_ly20w";

//ORVIBO晾衣架（旗舰版）
static NSString * const addDeviceHangerOrvibo_30w = @"homemate://addDevice/hanger/orvibo_ly30w";

//ORVIBO晾衣架（新豪华版）
static NSString * const addDeviceHangerOrvibo_a20 = @"homemate://addDevice/hanger/orvibo_a20";

// 晾霸晾衣机
static NSString * const addDeviceHangerLingBa = @"homemate://addDevice/hanger/liangba";
// 紫宸晾衣机
static NSString * const addDeviceHangerZichen = @"homemate://addDevice/hanger/zicheng";
// 奥科晾衣机
static NSString * const addDeviceHangerAoke = @"homemate://addDevice/hanger/aoke";
// 麦润晾衣机
static NSString * const addDeviceHangerMairun = @"homemate://addDevice/hanger/mairun";
// 帮和晾衣机
static NSString * const addDeviceHangerBanghe = @"homemate://addDevice/hanger/banghe";
// Yushun晾衣机
static NSString * const addDeviceHangerYushun = @"homemate://addDevice/hanger/yushun";


// 智能主机
static NSString * const addDeviceHostHostDefault = @"homemate://addDevice/host/hostDefault";
//all One pro
static NSString * const addDeviceRemoteAllonePro = @"homemate://addDevice/remote/rfallone";

// wifi电机
static NSString * const addDeviceCurtainmotorWifi = @"homemate://addDevice/curtainmotor/wifi";
//zigbee电机
static NSString * const addDeviceCurtainZigebee = @"homemate://addDevice/curtainmotor/zigebee";

//水吧
static NSString * const addDeviceWaterBarWifi = @"homemate://addDevice/water/water_purification";


static NSString * const addDeviceT1Lock = @"homemate://addDevice/smartlock/t1";

//报警主机
static NSString * const addDeviceAlarmHost = @"homemate://addDevice/host/alarmHost";

//MixPad
static NSString * const addDeviceMixPad = @"homemate://addDevice/mixpad/mixpadDefault";


//YiDongWFG3
static NSString * const addDeviceYiDongWFG3 = @"homemate://addDevice/socket/yidong_wfg3";

//WifiLEDLight
static NSString * const addDeviceWifiLEDLight = @"homemate://addDevice/light/wifiledlight";


//AirMaster
static NSString * const addDeviceAirMaster = @"homemate://addDevice/hvac/AirMaster";

//AirMasterPro
static NSString * const addDeviceAirMasterPro = @"homemate://addDevice/hvac/AirMaster_pro";

//中央空调面板（水机）
static NSString * const addDeviceShuiJi = @"homemate://addDevice/hvac/ts20w5lz";

//中央空调面板（水暖）
static NSString * const addDeviceShuiNuan = @"homemate://addDevice/hvac/t10w1";


//C1门锁
static NSString * const addDeviceC1 = @"homemate://addDevice/smartlock/c1";

//SC11
static NSString * const addDeviceSC11 = @"homemate://addDevice/camera/sc11";

//SC31PT
static NSString * const addDeviceSC31PT = @"homemate://addDevice/camera/sc31pt";

//SC12
static NSString * const addDeviceSC12 = @"homemate://addDevice/camera/sc12";

//空气监测仪
static NSString * const addDeviceAriMonitor = @"homemate://addDevice/sensor/airmonitor";

//添加H1
static NSString * const addDeviceH1 = @"homemate://addDevice/smartlock/h1";

//添加随意贴
static NSString * const addSticker = @"homemate://addDevice/switch/sticker";

//隐藏式智能开关（单火版）
static NSString * const addSingleFired = @"homemate://addDevice/switch/r21w2z";

//隐藏式智能开关（零火版）
static NSString * const addZeroFireSwitch = @"homemate://addDevice/switch/r30w3z";

// 智慧光源
static NSString * const addDeviceWisdomLightDefault = @"homemate://addDevice/light/downlight";


//4.2
// 烟雾报警器
static NSString * const addDeviceSensorHmsmoke2 = @"homemate://addDevice/sensor/hmsmoke2";
// 可燃气体报警器
static NSString * const addDeviceSensorHmburn2 = @"homemate://addDevice/sensor/hmburn2";
// 水浸探测器
static NSString * const addDeviceSensorHmwater2 = @"homemate://addDevice/sensor/hmwater2";
// 温湿度探测器
static NSString * const addDeviceSensorHmtemp2 = @"homemate://addDevice/sensor/hmtemp2";
// 紧急按钮
static NSString * const addDeviceSensorHmButton2 = @"homemate://addDevice/sensor/hmbutton2";

//4.2 迭代2
// 门磁传感器
static NSString * const addDeviceSensorDoorsensor2 = @"homemate://addDevice/sensor/doorsensor2";
// 人体传感器
static NSString * const addDeviceSensorMotionsensor2 = @"homemate://addDevice/sensor/motionsensor2";
// 摄像头 SC32pt
static NSString * const addDeviceCameraSC32PT = @"homemate://addDevice/camera/sc32pt";

// mixswitch
static NSString * const addDeviceMixswitch = @"homemate://addDevice/switch/mixswitch";

@interface HMAppFactoryAPI : HMBaseAPI

/**
 获取appid 用于用户评分
 */
+ (NSString *)appId;


/**
 *  重置app配置信息
 */
+ (void)reset;


/**
 *  获取本地数据库SQL语句
 */
+ (NSArray *)localConfigSQL;

/**
 *  判断本地app配置信息数据库是否有变化
 *
 *  @return YES 有变化  NO无变化
 */
+ (BOOL)localConfigDataChange;

/**
 *  判断本地是否有app配置表
 *
 *  @return YES 有  NO 没有
 */
+ (BOOL)nativeAppFactoryData;

/**
 *  判断app是否支持电话账号
 *
 *  @return YES 支持  NO 不支持
 */
+ (BOOL)supportPhone;

/**
 *  判断app是否支持邮箱账号
 *
 *  @return YES 支持  NO 不支持
 */
+ (BOOL)supportEmail;


/**
 判断是否支持增值服务
 */
+ (BOOL)supportValueAddService;

/**
 *  判断首页是否显示二维码
 *
 *  @return YES 显示  NO 不显示
 */
+ (BOOL)scanBarEnable;

/**
 是否校验邮箱注册验证码
 
 @return YES  校验  NO 不校验
 */
+ (BOOL)checkEmailRegisterCode;

/**
 获取 App 软件工厂信息
 */
+ (void)getAppFactoryDataFromServer:(AppFactoryUpdateCallback)callBack;

//'我的' 页面的 (帮助中心 和 关于)
+ (NSMutableArray *)settingConfigItems;

+ (NSMutableArray *)myCenterItemsContainShop:(BOOL)containShop;


/**
 *  获取版本介绍
 */
+ (NSString *)updateHistoryUrl;
    

/**
 获取建议反馈URL
 */
+ (NSString *)adviceUrl;

/**
 *  获取sourceUrl
 */
+ (NSString *)sourceUrl;


/**
 *  获取QQ授权码
 */
+ (NSString *)qqAuth;


/**
 *  获取用户协议
 */
+ (NSString *)agreementUrl;


/**
 *  获取高德地图key
 */
+ (NSString *)gaodeMapKey;

/**
 *  隐私协议
 */
+ (NSString *)privacyUrl;

/**
 *  获取商店Url
 */
+ (NSString *)shopUrl;

/**
 *  获取商店名称
 */
+ (NSString *)shopName;

/**
 *  获取app名称
 */
+ (NSString *)appName;


/**
 *  获取微博授权码
 */
+ (NSString *)weiboAuth;

/**
 *  获取微信授权码
 */
+ (NSString *)wechatAuth;


/**
 *  获取微信token
 */
+ (NSString *)wechatAuthToken;

/**
 *  获取taobao授权码
 */
+ (NSString *)taobaoAuth;

/**
 *  彩生活授权码
 */
+ (NSString *)caiShengHuoAuth;

/**
 *  获取大拿授权码
 */
+ (NSString *)daNaAppKey;




/**
 *  获取controller的背景颜色
 *
 *  @return UIColor 默认透明
 */
+ (UIColor *)controllerBgColor;



/**
 *  获取彩色字体颜色
 *
 *  @return UIColor 默认透明
 */
+ (UIColor *)appFontColor;




/**
 获取主题颜色的hex字符串
 
 @return颜色的hex字符串
 */
+ (NSString *)appTopicColorString;


/**
 *  获取app主题颜色
 *
 *  @return UIColor 默认透明
 */
+ (UIColor *)appTopicColor;


+ (UIColor *)appFontColorAlpha:(CGFloat)alpha;

/**
 *  获取app主题颜色
 *
 *  alpha 透明度
 *
 *  @return UIColor 默认透明
 */
+ (UIColor *)appTopicColorAlpha:(CGFloat)alpha;


/**
 *  获取安防颜色
 *
 *  @return UIColor 默认透明
 */
+ (UIColor *)secuityBgColor;


/**
 *  获取tabbarItem
 *
 *  @return NSArray 包含HMAppNaviTab对象
 */
+ (NSArray <HMAppNaviTab *> *)tabBarItems;



/**
 获取声音的item

 @return 声音的Item
 */
+ (HMAppNaviTab *)voicetabBarItem;

/**
 获取情景的item
 
 @return 情景的Item
 */
+ (HMAppNaviTab *)scenetabBarItem;


/**
 *  获取添加设备列表的一级目录
 *
 *  @return NSArray 包含HMAppProductType对象
 */
+ (NSArray <HMAppProductType *> *)addDeviceFirstLevel;


/**
 *  获取添加设备列表的二级目录
 *
 *  preProductTypeId 父目录Id
 *
 *  @return NSArray 包含HMAppProductType对象
 */
+ (NSArray <HMAppProductType *>*)addDeviceSecondLevel:(NSString *)preProductTypeId;

/**
 个人中心的位置
  */
+ (NSUInteger)personTabBarItemIndex;

/**
 获取app设置表
  */
+ (HMAppSettingLanguage *)appSettingLanguageModel;


/**
 *  根据ViewUrl获取PAppProductType
 *
 *  @return  HMAppProductType对象 有可能为nil
 */
+ (HMAppProductType *)getAppProductTypeWithViewUrl:(NSString *)viewUrl;


@end
