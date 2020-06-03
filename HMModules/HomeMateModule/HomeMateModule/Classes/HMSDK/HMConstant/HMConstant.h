//
//  ABB
//
//  Created by orvibo on 14-3-7.
//  Copyright (c) 2014年 orvibo. All rights reserved.
//

#ifndef HMConstant_h
#define HMConstant_h

#import "HomeMateSDK.h"
#import "HMDevice.h"
#import "DeleteDeviceCmd.h"
#import "HMDeviceStatus.h"
#import "NSObject+MJKeyValue.h"
#import "HMStorage.h"
#import "Gateway.h"

#if HOMEMATE_RELEASE

#define sendCmd(cmd,completion)\
        hm_sendCmd((char *)__FUNCTION__,__LINE__,(char *)__FILE__,cmd,completion)

#define sendLCmd(cmd,loading,completion)\
        hm_sendLCmd((char *)__FUNCTION__,__LINE__,(char *)__FILE__,cmd,loading,completion)

#else

void sendCmd(BaseCmd *cmd,SocketCompletionBlock completion);

void sendLCmd(BaseCmd *cmd,BOOL loading,SocketCompletionBlock completion);

#endif

#define kDbVersion                          hmDbVersion()

#import "AccountSingleton.h"

/** 网络判断 */
BOOL isEnable3G(void);
BOOL isEnableWIFI(void);
BOOL isNetworkAvailable(void);


/** 通过mdns 查找网关 */
void searchGatewaysAndPostResult(void);
void searchGatewaysWtihCompletion(SearhMdnsBlock completion);

/** 返回当前账号信息 */
AccountSingleton *userAccout(void);

BOOL isValidString(NSString *string,NSString *regex);   // 给定的字符串是否符合对应的正则
BOOL isValidUID(NSString *uid);                         // 是否是合法的网关UID
Gateway *getGateway(NSString *uid);                     // 根据网关UID获取网关信息
void removeDevice(NSString *uid);                       // 根据uid 移除内存中的设备信息（退出登录时调用）
NSNumber *getLastUpdateTime(NSString *key);             // 根据uid/familyId获取 主机/家庭 数据的上次最大更新时间
NSMutableData *stringToData(NSString*str ,int len);     // 字符串转成data
NSString *asiiStringWithData(NSData *data);             // data转成string
NSData *stringAsciiData(NSString*hexString,int length); //把字符串中的字符为对应的 asii码 data


NSString *currentTime(void);//获取系统当前时间，精确到微秒，格式：yyyy-MM-dd HH:mm:ss
NSString *currentDay(void);//获取系统当前日期，精确到天
NSString *getCurrentTime(NSString *dateFormat);//按指定格式获取当前时间

/** 上报deviceToken到服务器 */
void postToken(void);

/** 返回md5值 */
NSString* md5WithStr(NSString *input);


/** 发送指令（本地和远程都会尝试，指定发送到server的除外）*/
/** 简单调用方法见顶部宏定义 */
void hm_sendCmd(char *func,int line,char *file,BaseCmd *cmd,SocketCompletionBlock completion);

/**  发送指令,可以指定是否loading【loading 规则为，如果0.5s指令未响应，则调用delegate 的 displayLoading 方法】 */
void hm_sendLCmd(char *func,int line,char *file,BaseCmd *cmd,BOOL loading,SocketCompletionBlock completion);

/** 打印指令 [时间][文件-->行][调用函数-->被调用函数]*/
void hm_printCmd(char *func,char *sendFunc,int line,char *file,BaseCmd *cmd);

/** 返回设备状态,此方法Zigbee设备没有离线状态 */
HMDeviceStatus *statusOfDevice(HMDevice *device);

/** 返回本地设备真实状态 */
HMDeviceStatus *realStatusOfDevice(HMDevice *device);

/** 清除网关相关的所有数据，设备删除、解绑、检测到网关被重置时调用 */
void cleanDeviceData(NSString *uid);

/** 新增coco等设备时，添加一份本地的绑定关系，作为数据同步的依据。添加设备成功时调用 */
void addDeviceBind(NSString *uid,NSString *model);

/** 获取网关/server返回数据的crc校验值 */
unsigned int getCrcValue(NSData *data);

/** 根据uid读取指定的表数据，可能是远程也可能是本地 */
void readTable(NSString *tableName,NSString *uid,commonBlock completion);

/* 获得iPhoned的设备型号 */
NSString *getCurrentDeviceModel(void);

/** 获得当前uid上次更新的key值 */
NSString *lastUpdateTimeKey(NSString *uid);
NSString *lastUpdateTimeSecKey(NSString *uid);

/** 判断是不是规则的手机号 */
BOOL isPhoneNumber(NSString *phoneNum);

/** 是否处于远程（非本地）模式，必须登录成功之后，而且包含有主机才能调用此方法  */
BOOL isRemoteMode(NSString *uid);



/** vicenter - 300 大主机的modelID集合 */
NSSet *VIHModelIDArray(void);

/** 小主机的modelID集合 */
NSSet *HubModelIDArray(void);

/**大，小主机的modelID总集合 */
NSSet *AllZigbeeHostModel(void);

/** MixPad的modelID数组*/
NSSet *MixPadModelIDArray(void);

/** AlarmHost的modelID数组 */
NSSet *AlarmHostModelIDArray(void);

/** modelID 字符串，用来查询一个设备的model是否是小主机的model */
NSString *MiniHubModelIDs(void);

/** modelID 字符串，用来查询一个设备的model是否是主机的model */
NSString *HostModelIDs(void);

/** modelID 字符串，用来查询一个设备的model是否是大主机的model */
NSString *ViHomeModelIDs(void);

/** 判断是否主机类型，不包括MixPad */
BOOL isHostDeviceType(KDeviceType deviceType);

/** 判断当前的model 是否是主机，兼容最新的modelID */
BOOL isHostModel(NSString *model);

/** 根据model 返回主机的类型，小主机 kDeviceTypeMiniHub 或大主机 kDeviceTypeViHCenter300 */
KDeviceType HostType(NSString *model);




/** 根据model 返回设备的类型，主要用在wifi类设备 */
KDeviceType deviceTypeWithModel(NSString *model);

/** 是否是wifi设备的model */
BOOL isWifiDeviceModel(NSString *model);

/** 是否是wifi设备的uid */
BOOL isWifiDeviceUid(NSString *uid);

/** 晾衣架的modelID数组 */
NSArray *CLHModelIDArray(void);

/** coco的modelID  */
NSArray *COCOModelIDArray(void);

/** S20c 的modelID */
NSArray *S20cModelIDArray(void);

/** Allone2 的modelID */
NSArray *Allone2ModelIDArray(void);

/** AllonePro的modelID */
NSArray *AlloneProModelIDArray(void);

/** 所有wifi设备的model */
NSSet *allWifiDeviceModel(void);

/** modelID 字符串，用来查询一个设备的model是否是WIFI设备的model */
NSString *wifiDeviceModelIDs(void);

BOOL S30ModelId(NSString *model);
BOOL S20ModelId(NSString *model);
BOOL isSocketSpportPowerStatistics(NSString *model); // 插座是否支持电量统计
BOOL AlloneProModelId(NSString *model);
BOOL Allone2ModelId(NSString *model);



/** 删除设备命令： wifi设备、zigbee设备不同 */
DeleteDeviceCmd *deleteCmdWithDevice(HMDevice *device);

/** 延时执行，gcd实现 */
void executeAfterDelay(NSTimeInterval delay,VoidBlock block);

/** 全局队列异步执行，gcd实现 */
void executeAsync(VoidBlock block);

/** 通过gcd创建一个会重复执行的timer，gcd实现 */
dispatch_source_t gcdRepeatTimer(NSTimeInterval interval , BOOL(^shouldStop)(void) , VoidBlock block);

/** 判断一个字符串中是否包含另一个字符串，兼容iOS 8.0 以下系统 */
BOOL stringContainString(NSString *source,NSString *target);


/** 返回当前是不是汉语环境 */
BOOL isZh_Hans(void);

/** 返回当前是不是繁体汉语环境 */
BOOL isZh_Hant(void);

/** 返回当前是不是韩语环境 */
BOOL isLan_Ko(void);

/** 返回当前是不是德语环境 */
BOOL isLan_De(void);

/** 返回当前是不是日语环境 */
BOOL isLan_Ja(void);

/** 返回当前是不是法语环境 */
BOOL isLan_Fr(void);

/** 返回当前是不是葡萄牙语环境 */
BOOL isLan_Pt(void);

/** 返回当前是不是西班牙语环境 */
BOOL isLan_Es(void);

/** 返回当前是不是英语语环境*/
BOOL isLan_En(void);

/** 返回当前系统语言标识 zh_TW,zh,en,de,fr,ru,ko,ja,pt,es 之一 */
NSString *language(void);

/** 判断手机是不是iPhoneX */
BOOL is_iPhoneX(void);

/** 判断是不是空字符串 */
BOOL isBlankString(NSString * string);

/** 根据时间字符串得到date对象，默认格式：yyyy-MM-dd HH:mm:ss*/
NSDate *dateWithString(NSString *string);

/** 将字符串格式的日期转为现在到1970年的秒数 */
int secondWithString(NSString *string);

/** 根据秒数返回日期字符串 */
NSString *dateStringWithSec(NSString *second);

/** 设备显示顺序 */
NSArray *orderOfDeviceType(void);


/** 是否是RGBW灯的白光那路 */
BOOL isWhiteLightEndPoint(HMDevice *device);

/** 是否是RGBW灯的rgb那路 */
BOOL isRGBLightEndPoint(HMDevice *device);

/** 指定URL和超时时间，发起一个 http/https 请求 */
void requestURL(NSString *URL,NSTimeInterval delayTime, HMRequestBlock block);


/** 判断当前设备是否是Ember方案的mini主机，Ember Hub 支持一些新功能，NXP 方案的Hub不支持 */
BOOL isEmberHub(NSString *uid);

/** 判断当前账号是否存在ember网关，Ember Hub 支持一些新功能，NXP 方案的Hub不支持 */
BOOL hasEmberHub(void);

/** 是否是霸陵门锁的model */
BOOL isBaLingModel(NSString *model);

/**
 当数据库表字段有更新（增删改）时，增加此version值
 此值改变时可以从server或者gateway中获取数据的表会重新建立，lastupdatetime key值也会跟着变化
 升级时，首次会把所有数据全部重读一遍，后面恢复正常
 */
NSString* hmDbVersion(void);


/** 晾衣架类型 */
kClothesHorseType clothesType(HMDevice *device);

/**
 返回默认的 AP配置ssid
 早期: @"alink_ORVIBO_LIVING_OUTLET_E10"
 后期: @"HomeMate_AP"
 OEM: @"LenovoService_AP"/ @"YDHome_AP"
 */
NSString *connectSSid(void);

/**
 *  楼层房间信息，因含有字符串资源，所以需要SDK的delegate来实现，
 *  此方法调用SDK 的delegate实现的方法 +(NSString *)floorAndRoom:(HMDevice *)device;
 */

/** 返回该设备楼层&房间拼接后的字符串 */
NSString *floorAndRoom(HMDevice *device);

/** 主机从3.2版本开始支持自动化，情景支持多个zigbee设备 */
BOOL hubVersionGreaterThanV32(NSString *uid);

BOOL hubVersionGreaterThanV40(NSString *uid);

/** 返回设备是否是汇泰龙智能门锁，这些设备功能相同，model不同 */
BOOL isHTLDoorLock(HMDevice *device);

/** 返回设备是否是霸陵智能门锁，这些设备功能相同，model不同 */
BOOL isBLDoorLock(HMDevice *device);

/** 返回设备是否是智能门锁，智能门锁采取授权开锁，非智能门锁App直接控制开锁 */
BOOL isSmartDoorLock(HMDevice *device);

/** t1门锁专用，内部调用 cleanDeviceData 清除数据之外，多清除了其他数据 */
void cleanDeviceDataWithDevice(HMDevice * device);

BOOL hasSuportT1LockEmber(void);
BOOL isSppportT1EmberHub(NSString *uid);

/** 配电箱是否支持漏电自检 */
BOOL distBoxIsSupportLeakageDetect(HMDevice *device);

/** 异步查询设备在线状态 */
void queryDeviceStatus(NSString *uid,NSTimeInterval delayTime,commonBlockWithObject block);

/**
 *  把字符串对象组成的数组转化为每个字符串对象带单引号的字符串
 *  例如 @[a,b,c]; ==> "'a','b','c'";
 */
NSString * stringWithObjectArray(NSArray *objectArray);

/** 有主机或者有支持T1门锁的主机时候，去查询主机的在线状态 */
void checkHubOnlineStatus(void);

/** 判断设备是否是多功能控制盒 */
BOOL isControlBox(HMDevice *device);

/** 判断多功能控制盒所在的主机是否支持自定义类型 */
BOOL isSppportControlBoxCustomType(NSString *uid);

BOOL deviceIsT1CLock(HMDevice * device);

/** 获取手机唯一标识 */
NSString *phoneIdentifier(void);

/** 获取设备自定义的名字 */
NSString *terminalDeviceName(void);

/** 判断是否是VRV空调控制器 */
BOOL isVRVAirConditionController(HMDevice * device);

/** Allone/小方支持的虚拟设备类型 */
NSArray *alloneVirtualDeviceType(void);

/** Allone Pro/RF主机支持的虚拟设备类型 */
NSArray *alloneProVirtualDeviceType(void);

/** Zigbee红外转发器支持的虚拟设备类型 */
NSArray *zigbeeIrVirtualDeviceType(void);

/** 判断手机是否支持自定义捷径 */
BOOL isSupportSiriShortcuts(void);

/** MixPad App版本号 >= 传入的版本号, 以支持某个特定功能 */
BOOL isMixpadAppVersionHigherThanVersion(HMDevice *mixpad,NSString *supportVersion);

/** 从字符串中提取数字 */
NSString *getNumberFromStr(NSString *str);

/** 字符串解密（匿名秘钥） */
NSString *decryptTheString(NSString *encryptedString);

/** 字符串加密 （匿名秘钥）*/
NSString *encryptTheString(NSString *originSting);

BOOL appVersionLowerThanVersion(NSString * version);

/**
 处理动态域名的URL
 */
NSString *dynamicDomainURL(NSString *url);
#endif
