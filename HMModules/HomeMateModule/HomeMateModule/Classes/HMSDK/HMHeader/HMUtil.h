//
//  HMAppUtil.h
//  HomeMate
//
//  Created by liuzhicai on 16/5/3.
//  Copyright © 2017年 Air. All rights reserved.
//

/**
 *
 *   作为key值的宏定义规则：
 *   HM前缀+模块名+功能名+Key后缀
 *   其他类型宏定义规则：
 *   HM前缀+模块名+功能名
 *
 */

#ifndef HMUtil_h
#define HMUtil_h
#import "HMConstant.h"

#define IOS8 ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0)
#define IOS9 ([[[UIDevice currentDevice]systemVersion]floatValue] >= 9.0)
#define IOS10 ([[[UIDevice currentDevice]systemVersion]floatValue] >= 10.0)
#define IOS11 ([[[UIDevice currentDevice]systemVersion]floatValue] >= 11.0)
/* @available(iOS 11.0, *) **/
//#define IOS11 @available(iOS 11.0, *)
// 判断是否是iPhone X
#define iPhoneX is_iPhoneX()

#define SCREEN_4_INCH ([[UIScreen mainScreen] bounds].size.height > 480.0)
#define IPHONE_4_OR_5 ([[UIScreen mainScreen] bounds].size.height <= 568)

#define LogFuncName() DLog(@"%@",NSStringFromSelector(_cmd)) // 打印函数名

//判断是否是中文环境
#define CHinese isZh_Hans()

// 数据库目录
#define kImagesDir [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Images"]]
#define kDBDIR [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches"]]
#define kNEWDBDIR [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents"]]


#pragma mark - RGB颜色相关

#define RGB(r, g, b)                        [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:a]

#define CGRGB(r, g, b)                      [[UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f] CGColor]

#define RGBCOLORV(rgbValue)                 [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)(rgbValue & 0x0000FF))/255.0 alpha:1.0]

#define RGBCOLORVA(rgbValue, a)             [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 blue:((float)(rgbValue & 0x0000FF))/255.0 alpha:(a)]

#define HomeMateDefaultThemeColor           RGBCOLORV(0xF18F00)

#define HMUserDefaults                    [NSUserDefaults standardUserDefaults]

#define TEST_HOST_NAME              @"www.baidu.com"

#define kGet_ServerIP_URL           @"https://lgs.orvibo.com/getHost?source=%@&idc=%d&country=%@&state=%@&city=%@&userName=%@&sysVersion=iOS"
#define kGet_DeviceDesc_URL         @"https://homemate.orvibo.com/getDeviceDesc?lastUpdateTime=%d&source=%@"
#define kGet_Logout_URL             @"https://homemate.orvibo.com/logout?token=%@"
#define kGet_APP_Factory_Data_URL   @"https://homemate.orvibo.com/getAppInfo?lastUpdateTime=%d&source=%@&userId=%@&familyId=%@"

#define kGet_OnlineStatus_URL       @"https://homemate.orvibo.com/getDeviceOnlineStatus?uid=%@"

#define kGet_MixPad_MusicServiceInfo_URL @"https://homemate.orvibo.com/music/statusList?uids=%@"

// 获取萤石token
#define GetYSAccessTokenUrl @"https://homemate.orvibo.com/getToken?familyId=%@"
// 注册萤石
#define RegisterToYSUrl @"https://homemate.orvibo.com/regist?phone=%@"

#define Get_Channel_token_Url @"https://homemate.orvibo.com/getOauthToken"
#define Get_Common_Channel_Url @"https://homemate2.orvibo.com/channel"

#define HM_CQCCN_ID_URL @"https://smart-app.orvibo.com"

// SERVER TCP 地址与端口
#define HM_DOMAIN_NAME @"homemate.orvibo.com"
#define HM_SERVER_PORT 10001


// UDP 发现端口与广播地址
#define HM_UDP_PORT 10000
#define HM_UDP_BROADCAST_ADDR @"255.255.255.255"

// MDNS 发现主机
#define MNDS_SERVICE_TYPE                   @"_smarthome._tcp"
#define MNDS_DOMAINNAME                     @"local"
#define MNDS_PORT                           8088


// WiFi设备ssid
#define COCOAPSSID                          @"alink_ORVIBO_LIVING_OUTLET_E10"
#define HomeMateAPSSID                      @"HomeMate_AP"

// 联想OEM ssid
#define LenovoAPSSID                        @"LenovoService_AP"

// 一栋OEM ssid
#define YDHomeAPSSID                        @"YDHome_AP"




/**
 *  公钥
 */
#define PUBLICAEC128KEY                     @"khggd54865SNJHGF"

#define DEFAULTSESSION                      @"00000000000000000000000000000000"

/** 每张表读取失败后的最大尝试次数 */
#define kReadTableMaxTryTimes               2
#define kReadTableTimeOut                   5 // 发出读表指令后 5秒内没有表数据返回就重发一次
#define kHeartBeatTime                      (3 * 60)     // 心跳包发送的时间间隔
#define kSearchMdnsTime                     1.2         // 查找mds服务的时间


// 可以被选择为 情景 和 联动 的输出设备的设备类型 (zigbee + wifi(小方下的遥控器 + coco + S30 + S31) + (RF主机 rf 设备)(RF: 77 78 52 RF34))
#define kSceneAndLinkageOutputDeviceType  @"0,1,2,3,4,5,6,7,8,9,10,19,29,32,33,34,35,36,37,38,39,40,41,42,43,52,57,58,59,60,64,70,73,74,75,76,77,78,102,104,105,106,108,109,110,111,112,116,118,119,120,126,127,10087,19999002"


// 可以被选择为 情景面板 输出设备的设备类型 包括wifi设备 与kSceneAndLinkageOutputDeviceType只差类型36（空调面板）
#define kSceneBoardDeviceType @"0,1,2,3,4,5,6,7,8,9,10,19,29,32,33,34,35,37,38,39,40,41,42,43,58,59,60,64,70,73,74,75,76,126,127,77,78,52,102,104,105,106,108,109,110,111,112,116,118,119,10087,19999002"

// 可以被选择为 小方联动(小方一键情景) 输出设备的设备类型  (小方下的遥控器)
#define kFilterMagicCubeType    @"5,6,7,30,32,33,58,59,60"

// 常用设备里不显示的类型
#define kFilterCommonDeviceType @"11,15,16,21,25,26,27,30,44,45,46,47,48,49,50,51"

// Zigbee 虚拟设备
#define kFilterZigbeeVirtualDeviceType @"6,32,33,5,115,128"

// 主机设备类型
#define kHostDeviceType @"44,45,113,114"

// 需要节能提醒的类型
#define kEnergyDeviceType       @"0,1,19,38,102,116"

// 安防设备类型 （首页的所有消息不显示这些设备的消息）
#define kSecurityDeviceType  @"25,26,27,28,46,47,48,49,54,55,56"

// 需要显示消息的消息类型
#define kNeedDisplayInfoType    @"0,1,11,12,13,14,15"

// 需要显示提醒设置的类型
#define kWifiDeviceTypeHasTimerTip         @"29,43,101,116"

// 旧门锁，用于保存时间和次数
#define kDateKey(obj) [NSString stringWithFormat:@"%@_%@_date",userAccout().userName,[obj isKindOfClass:[NSString class]] ? obj :NSStringFromClass([obj class])]
#define kCountKey(obj) [NSString stringWithFormat:@"%@_%@_count",userAccout().userName,[obj isKindOfClass:[NSString class]] ? obj :NSStringFromClass([obj class])]

// 用于保存上传到server的city，country，state信息
#define kLocationDictionaryKey              [NSString stringWithFormat:@"%@_%@",@"LocationDictionaryKey",userAccout().userId]

#define kOldDistBoxMainPoint 1  // 配电箱主控端点

#define kDistBoxAttributeDefaultValue -1   //  配电箱默认属性值为-1 则表示无数据

#pragma mark - 设备modelId

#define kMixPadName                           @"MixPad"

// 主机类
#define kViHomeModel                        @"VIH" // vicenter - 300 大主机
#define kHubModel                           @"Hub" // vicenter - 300 小主机
#define kNormalViHomeModel                  @"VIH004" // 中性 vicenter - 300 大主机

// wifi 类设备
#define kS20Model                           @"SOC0" // 一栋model SOC002
#define kCocoModel                          @"E10" // COCO 不带USB版本
#define kYSCameraModel                      @"CMR" // 萤石摄像头
#define kS20cModel                          @"S20" // S20c 的model
#define kCLHModel                           @"CLH" // 晾衣架
#define kHudingStripModel                   @"CoCo" //华顶排插，飞雕


/**
 *  萤石
 *
 */
#define YSAppKey                            @"0cf9e3adad02447f829f4af8d1226582"
#define YSAppSecret                         @"0c6ec40e1b99d4cf7f3800bb8c4286d3"
#define __YSCamera__


// S20c
#define kS20cModelId                        @"56d124ba95474fc98aafdb830e933789"


#define kS30ModelId                         @"62f1da0474434509923b2dc947a0f14c"
#define kS31ModelId                         @"e08553a4ac694effbee945307655d9dc"
#define kS31YDModelId                       @"46e8c4e5595546268d2d7fed853bf085"


// 海外版S20c 即S25
#define kS20cFriModelId                     @"f8b11bed724647e98bd07a66dca6d5b6"

//一栋
#define kYDModelId                          @"9cddfe4851ee47348e6e2df06fb9e945"
#define kYDWFGModelId                       @"c33a2a0f781d4822ac1ccd7e7ca12ae7"

//萤石摄像头model
#define kYSCameraModelId                    @"d3bf4822f3ed41d7a8b7e154ddc46ffa"
#define kYTYSCameraModelId                  @"46a2523b3a0d472ba73bad0e868f6531"

//汇泰龙门锁的ID
#define kHTLDoorModelID                     @"9fbf0f1fc370403aae30886c2fcc6cf1"//远程授权
#define kHTLSecondDoorModelID               @"569a0cf195154c4f8282ef931265d33c"
#define kHTLThirdDoorModelID                @"120cbaca18a54675ab501a696d469805"
#define kHTLFourthDoorModelID               @"5834462077cb41fdbea80c8b071e1e24"

//霸陵门锁的ID
#define kBLDoorModelId                      @"9f1b8a92e78d49b4ab8742a30b04e2c3"//远程授权
#define kBLThirdDoorModelId                 @"6e2f218bd0684a75886b2f9b543186b0"
#define kBLFourthDoorModelId                @"cf31218e11c547179c9c9ade6a492799"//霸陵中性门锁

//霸陵门锁新加坡版
#define kBLSecondDoorModelId                @"87f2c4c4623149b6a96cdbed54445596"//本地授权

//9113升级门锁
#define k9113DoorModelId                    @"444d25f1e5824f0e949339e2bb8b9da0"

//欧瑞博中性门锁
#define kOrviboDoorModelId                  @"447f09f2bcf04b5d8d5696c56ae5dc95"//直接开锁

// 爱而福德门锁
#define kAierFuDeDoorModelId                @"2d560e57434b4e1390b705f72a239b55"



// 汉枫COCO 32位model  （这个是乐鑫的coco）
#define kHanFengCocoModelId                 @"2a9131f335684966a86c54ca784520d7"
// 飞雕插排
#define kFeiDiaoModelId                     @"22a70be5d60944f7b50d26b78eeebf01"

// 华顶插座
#define kHuaDingSocket                      @"0f85bfab9f1f4f50a7254639880dacbc"
// 华顶排插
#define kHuaDingStrip                       @"5fadd264c93544f8bd5556f11709e7aa"

// ORVIBO智能云晾衣机(豪华版)
#define kORVIBOCLHModel                     @"8eb0af1a277d4134a465662984fd35f6"
// ORVIBO智能云晾衣机（时尚版）
#define kORVIBOCLHModel_20w                 @"d89ab860e8134b8ba39a9bb25c4a1542"
// ORVIBO智能云晾衣机（旗舰版）
#define kORVIBOCLHModel_30w                 @"82bde3e16563441ab0f9bbc7d2eb4a71"
// ORVIBO智能云晾衣机（新款豪华版）model和旗舰版一致
#define kORVIBOCLHModel_a20                 kORVIBOCLHModel_30w

// YUSHUN智能云晾衣机
#define kYuShunCLHModel                     @"94895bb583964b2780460a35d18a8768"

// 邦禾云智能云晾衣机
#define kBangHeCLHModel                     @"de55d589998440e98e86088b10a7f282"

// 麦润智能云晾衣机
#define kMaiRunCLHModel                     @"6c1f4ae70bfa495c902204ab7b6dab0d"

// 晾霸智能云电动晾衣机
#define kLiangBaCLHModel                    @"d4c7d528472e46edb694289300fa6fbb"

// 紫程晾衣架
#define kZiChengCLHModel                    @"5e9ccae98b1b47f6935072d8c6e36be3"

//奥科晾衣架
#define kAoKeCLHModel                       @"68bb3f1a74284e2189227bc0259d3363"

// 四键随意贴的model
#define k4KeySceneBoardModelID              @"3c4e4fc81ed442efaf69353effcdfc5f"
#define k4KeySceneBoardModelID2             @"51725b7bcba945c8a595b325127461e9"
#define k4NVCKeySceneBoardModelID2          @"ff79f9de706240269103bb6314eb2e7e"

// 中性主机的model
#define kNormalGatewayModelID               @"e019ff119e5f4567a0c3f5868b566253"

// 慧眼摄像头model
#define kP2PCameraModelID                   @"bcec7653260b4e98b0e653e0a79d83db"

// 小方 model
#define kAllone2ModelID                     @"ffd65d82eae248a8a8bc08a2cb688a2b"


// 创维空调面板/WIFI空调 model
#define kSkyworthModelID                    @"81dc0561b6dc496781b6cf69971a96c8"

// （亿林）空调面板/orvibo model
#define kWifiAirconditionerModelID          @"9eca5b60791f40549e7059ae6771c2f4"

// VRV中央空调控制器
#define KVRVAirConditionControlModelID      @"75469dee575c4ba2a2d42592cc89498d"

// VRV中央空调面板
#define KVRVAirConditionPanelModelID        @"bf571aa9578d4e2d8519096ecd24085e"

// Airmaster-pro
#define KVRVAirmasterProModelID             @"b74dc613d57047ddad609b7b3d36e01c"

// Airmaster-pro 面板
#define KVRVAirmasterProPanelModelID        @"4f48acfc97314363b3ff55460a9a8255"

// 创维rgbW灯
#define kChuangWeiRGBWModel                  @"e1b7b3a1a82b4beda41481a3943d941d"

// 创维rgb 灯
#define kChuangWeiRgbModel                  @"68c8441256624539bb71c10e0b8a0402"

// Skyworth智能灯
#define kChuangWeiOrdinaryLightModel        @"cdf36cb86b964b47855f0c188d79dbdf"

// Skyworth智能调光灯
#define kChuangWeiDimmerLightModel          @"1f7c51362dee4578bca9bd53d64a06fd"

// Skyworth调光调色灯
#define kChuangWeiColorTempLightModel       @"a9259fc37aad447ea6633a23f07bec7b"

// 奥科对开电机
#define kAoKeCurtainModel                   @"093199ff04984948b4c78167c8e7f47e"

// 瑞翔/创明交流百叶帘B40E-旧协议
#define kRuixiangBlindsModel                @"d87f64b6918e40b79055e9d0fce26005"

//小欧智能摄像机（无云台，未获取到modelId时填这个model）
#define KXiaoOuModel                        @"ea8c697055e545c2bc49709617655ca0"

// 向往背景音乐的model
#define KHopeMusicModel                     @"6103cb9215e34ed5a19d224ec13ab9cb"

// 配电箱model
#define KSmartBoxModel                      @"e7a200d68db04c78b6d3230794306d5b"

//欧普照明股份有限公司
//欧普一键情景面板
#define KOPPLE1KeySceneBoardModelID         @"91b88b7a6c42442c81dad4a3ff628555"
//欧普二键情景面板
#define KOPPLE2KeySceneBoardModelID         @"1320135b2b5e4b529f5e00deca474434"
//欧普四键情景面板
#define KOPPLE4KeySceneBoardModelID         @"4c41fe0468764c32a32e71a49962390d"
//欧普五键情景面板
#define KOPPLE5KeySceneBoardModelID         @"5cf48979c057400ea42915b7f2765d3e"
//欧普一路执行器
#define KOPPLELightModelID                  @"800f4a72aed842a88f0b007fa9561354"

// 甲醛探测仪
#define KHCHODetectorModelID                @"740ea51b9b014df68850f61843f8818b"

// 一氧化碳探测仪
#define KCODetectorModelID                  @"33abb25852a6470d81143696b4ed9294"

// 人体光照传感器
#define KHumanLightSensorModelID            @"de894c7bf0314ea0bce8f375df97f06c"

// 俄罗斯版本的人体光感
#define KHumanLightSensorModelIDHOMMYN      @"84780a9533b64db29050e3d226e7ffbe"

// 美标计量插座
#define KAmericanStandardSocketModelID      @"b0032863607d4dac80809d39ce36261e"

// RF主机
#define KRFModelID                          @"32bede904a0f4b7a90f3d034e26fefb3"


// WiFi开合帘 -- 高端智能窗帘电机
#define KWiFiEleMachineCurtainModelID       @"cbf2ad4b5fd24f568ecabec7f07b0531"

// WiFi开合帘 -- v3.7新增窗帘model适配 -- 大白电机
#define KWiFiEleMachineCurtainModelID2       @"079d0aef983d4ee796769c8ed663a651"

// WiFi开合帘 -- v3.9新增窗帘model适配 -- 与大白电机功能一致，外观略有差别
#define KWiFiEleMachineCurtainModelID3       @"47f265ad94444080b63d6f13c17db1c3"

//WiFi开合帘  对开窗帘电机
#define KWiFiOpenCloseCurtainModelID        @"41654594ee0a44838e94c1818d3f564b"

//WiFi卷帘 卷帘电机 瑞翔/创明卷帘
#define KWiFiRollerCurtainModelID           @"5ada958e51094db480eb2fa52964cdd0"

//WiFi开合帘（中性） 对开窗帘电机
#define KWiFiOpenCloseNeturalCurtainModelID @"7bf71c67d8494a78977d659043284a52"

//WiFi卷帘（中性）--管状电机
#define KWiFiEleMachineRollerModelID        @"5f92953cb8414fc59de51d269443d0a9"


//Zigbee窗帘（中性）--外接电源，新协议 -- v3.1
#define KZigebeeCurtainMotorModelID        @"8dc51527d99547a1a0fb5fed993ca01d"

//Zigbee窗帘（中性）--电池，新协议 -- v3.1
#define KZigebeeCurtainBatteryMotorModelID  @"c8daea86aa9c415aa524365775b1218c"


//p3水吧
#define KWiFiP3WaterBarModelID        @"847d7a23c3234e978e57e446d7bf917d"
//Q7水吧
#define KWiFiQ7WaterBarModelID        @"fd3da8115bc3465aa6282e1f3f220b1c"

// zigbee 红外转发器（黑色飞碟）
#define kZigbeeInfraredTranspondModelId     @"b2bec459ed3641d5949880d7d6905832"
#define kZigbeeInfraredTranspondModelId_BODUN @"728fe393e8a84a459f71f2a81c1359fa"   // 伯顿
#define kZigbeeInfraredTranspondModelId_ADDYMAN @"30f79ee7d61b44c5996e1ce3b032a854" // ADDYMAN
#define kZigbeeInfraredTranspondModelId_NORMAL     @"83697ad4ba0c4bb385247b9ae84718a7"  // 中性


// P3活水吧
#define kP3WaterBarModelId     @"847d7a23c3234e978e57e446d7bf917d"


// Q7活水吧
#define kQ7WaterBarModelId     @"fd3da8115bc3465aa6282e1f3f220b1c"

//T1 model
#define kT1Model               @"b2f6fbb9a8b44d1c98f2b8f385bb848b"

//两款1080p摄像头
#define kSC11Model               @"bd8e0c174f614d15bcfa73535d3cd41a"
#define kSC31PTModel             @"62886a601bbd4dc6a613d1e2eef0f044"

/*
1、新增智能门锁T1 C，T1 C有两个版本：
1）第一个版本使用T1的物料
Model ID为：c5a37087a84c4110a998bff61a4a3527

2）第二个版本会更换MCU型号，Model ID为：
77d7db0814894e96b14062f71c508c3a*/

#define kT1C1ModelId          @"c5a37087a84c4110a998bff61a4a3527"
#define kT1C2ModelId          @"77d7db0814894e96b14062f71c508c3a"

#define kHuanCaiModelId          @"3416274456fe4d59b3344c539053b0f0"

#define kDefaultRoomId       [NSString stringWithFormat:@"kDefaultRoomId%@",userAccout().userId]//默认房间的roomId

#define kLastSelectRoomId    [NSString stringWithFormat:@"%@_currentRoomID",userAccout().familyId]//首页上次选择的roomId

#define kDeviceRoomSetRoomId    [NSString stringWithFormat:@"%@_deviceRoomSetRoomId",userAccout().familyId]//设备选择的roomId

#define kLastSceneRoomId     [NSString stringWithFormat:@"%@_selectRoomID",userAccout().familyId]//情景上次选择的roomId

#define CurrentFamilyIDKey   [NSString stringWithFormat:@"CurrentFamilyIDKey_%@",userAccout().userId]//当前userId选中的家庭

#define isFahrenheit         [NSString stringWithFormat:@"%@is℉",userAccout().userId]//是否是华氏度

/**
 *  刷新安防记录按钮的小红点,YES显示小红点，NO隐藏小红点
 */
#define KNOTIFICATIONREFRESHSECURITYRECORDREDDOT @"refreshSecurityRecordButtonRedDot"


#define APPID @"1002853448" //ituns connect 中的 AppId

#pragma mark -



#endif /* HMUtil_h */
