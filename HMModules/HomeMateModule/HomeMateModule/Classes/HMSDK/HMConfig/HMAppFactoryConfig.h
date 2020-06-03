//
//  HMAppFactoryConfig.h
//  HomeMateSDK
//
//  Created by PandaLZMing on 2017/4/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMAppNaviTab;
@class HMAppProductType;
@class HMAppSettingLanguage;
@class HMAppService;

@interface HMAppFactoryConfig : NSObject


+ (instancetype)appFactory;


+(NSArray *)localConfigSQL;


+(BOOL)localConfigDataChange;


- (BOOL)supportPhone;


- (BOOL)supportEmail;



/**
 是否支持增值服务
 */
- (BOOL)supportValueAddedService;

- (BOOL)scanBarEnable;

- (NSString *)appSource;


/**
 是否校验邮箱注册验证码

 @return YES  校验  NO 不校验
 */
- (BOOL)checkEmailRegisterCode;

/**
 获取 App 软件工厂信息
 */
+ (void)getAppFactoryDataFromServer:(void(^)(BOOL appFactoryUpdate))callBack;



-(BOOL)nativeAppFactoryData;

//'我的' 页面的 (帮助中心 和 关于)
- (NSMutableArray *)settingConfigItems;
- (NSMutableArray *)myCenterItemsContainShop:(BOOL)containShop;


/**
 获取appid 用于用户评分
 
 @return appid
 */
- (NSString *)appId;


- (void)reset;


/**
 *  获取版本介绍
 */
- (NSString *)updateHistoryUrl;

    
- (NSString *)adviceUrl;
    

/**
 *  获取sourceUrl
 */
- (NSString *)sourceUrl;


/**
 *  获取用户协议
 */
- (NSString *)agreementUrl;

/**
 *  隐私协议
 *
 */
- (NSString *)privacyUrl;

/**
 *  获取商店Url
 */
- (NSString *)shopUrl;

/**
 *  获取商店名称
 */
- (NSString *)shopName;

/**
 *  获取app名称
 *
 */
- (NSString *)appName;

/**
 *  获取QQ授权码
 *
 */
- (NSString *)qqAuth;


/**
 *  获取微博授权码
*/
- (NSString *)weiboAuth;

/**
 *  获取微信授权码
 */
- (NSString *)wechatAuth;


/**
 *  获取高德地图key
 */
- (NSString *)gaodeMapKey;


/**
 *  获取微信token
 */
- (NSString *)wechatAuthToken;
/**
 *  获取淘宝授权配置
 */
- (NSString *)taobaoAuth;
/**
 *  彩生活授权码
 */
- (NSString *)caiShengHuoAuth;

/**
 *  获取大拿AppKey
 */
- (NSString *)daNaAppKey;


/**
 *  获取controller的背景颜色
 *
 *  @return UIColor 默认透明
 */
- (UIColor *)controllerBgColor;


/**
 获取主题颜色的hex字符串
 
 @return颜色的hex字符串
 */
- (NSString *)appTopicColorString;


/**
 *  获取彩色字体颜色
 *
 *  @return UIColor 默认透明
 */
- (UIColor *)appFontColor;
- (UIColor *)appFontColorAlpha:(CGFloat)alpha;



/**
 *  获取app主题颜色
 *
 *  @return UIColor 默认透明
 */
- (UIColor *)appTopicColorAlpha:(CGFloat)alpha;


/**
 *  获取安防颜色
 *
 *  @return UIColor 默认透明
 */
- (UIColor *)secuityBgColor;


/**
 *  获取tabbarItem
 *
 *  @return NSArray 包含HMAppNaviTab对象
 */
- (NSArray <HMAppNaviTab *> *)tabBarItems;


/**
 获取声音的item
 
 @return 声音的Item
 */
- (HMAppNaviTab *)voicetabBarItem;

/**
 获取情景的item
 
 @return 情景的Item
 */
- (HMAppNaviTab *)scenetabbarItem;

/**
 *  获取添加设备列表的一级目录
 *
 *  @return NSArray 包含HMAppProductType对象
 */
- (NSArray <HMAppProductType *>*)addDeviceFirstLevel;


/**
 *  根据ViewUrl获取PAppProductType
 *
 *  @return  HMAppProductType对象 有可能为nil
 */
- (HMAppProductType *)getAppProductTypeWithViewUrl:(NSString *)viewUrl;


/**
 *  获取添加设备列表的二级目录
 *
 *  preProductTypeId 父目录Id
 *
 *  @return NSArray 包含HMAppProductType对象
 */
- (NSArray <HMAppProductType *>*)addDeviceSecondLevel:(NSString *)preProductTypeId;

/**
 返回服务列表的二维数组
 */
- (NSArray <HMAppService *>*)appServiceItemsArr;

/**
 服务的组名： 比如设备服务
 @param groupId 组Id
 */
- (NSString *)appServiceGroupNameWithGroupId:(NSString *)groupId;

/**
 个人中心的位置
 */
- (NSUInteger)personTabBarItemIndex;


/**
 获取app设置表
 */
- (HMAppSettingLanguage *)appSettingLanguageModel;


/**
 判断是否正在下载数据

 @return YES 正在下载 NO 没有下载
 */
- (BOOL)appFactoryGetAppFactoryDataFromServer;



/**
 设置是否正在下载

 @param getData YES 正在下载  NO 没有正在下载
 */
- (void)appFactorySetAppFactoryDataFromServer:(BOOL)getData;

/**
 获取保存获取数据的回调
 
 */
- (NSDictionary *)appFactoryGetAppFactoryDataCallBack;

/**
 设置保存获取数据的回调
  */
- (void)appFactorySetAppFactoryDataCallBack:(NSDictionary *)dict;
@end
