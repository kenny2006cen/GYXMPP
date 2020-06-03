//
//  HMAppFactoryAPI.m
//  HomeMateSDK
//
//  Created by liqiang on 17/5/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMAppFactoryAPI.h"

@implementation HMAppFactoryAPI

+(NSArray *)localConfigSQL {
    return [HMAppFactoryConfig localConfigSQL];
}

+ (BOOL)nativeAppFactoryData {
    return [[HMAppFactoryConfig appFactory] nativeAppFactoryData];
}

+(BOOL)localConfigDataChange {
    return [HMAppFactoryConfig localConfigDataChange];
}


+ (BOOL)supportPhone {
    return  [[HMAppFactoryConfig appFactory] supportPhone];
    
}
+ (BOOL)supportEmail {
    return  [[HMAppFactoryConfig appFactory] supportEmail];
    
}

+ (BOOL)supportValueAddService {
    return [[HMAppFactoryConfig appFactory] supportValueAddedService];
}

+ (void)reset {
    [[HMAppFactoryConfig appFactory] reset];
}

/**
 是否校验邮箱注册验证码
 
 @return YES  校验  NO 不校验
 */
+ (BOOL)checkEmailRegisterCode {
  return  [[HMAppFactoryConfig appFactory] checkEmailRegisterCode];

}

/**
 获取appid 用于用户评分
 
 @return
 */
+ (NSString *)appId {
    return  [[HMAppFactoryConfig appFactory] appId];

}


/**
 *  判断首页是否显示二维码
 *
 *  @return YES 显示  NO 不显示
 */
+ (BOOL)scanBarEnable {
   return  [[HMAppFactoryConfig appFactory] scanBarEnable];
}


/**
 *  获取版本介绍
 *
 *  @return
 */
+ (NSString *)updateHistoryUrl {
    return [[HMAppFactoryConfig appFactory] updateHistoryUrl];

}
    
    
    /**
     *  获取建议反馈URL
     *
     *  @return
     */
+ (NSString *)adviceUrl {
    return [[HMAppFactoryConfig appFactory] adviceUrl];

}
    
    
    

/**
 *  获取sourceUrl
 *
 *  @return
 */
+ (NSString *)sourceUrl {
    return [[HMAppFactoryConfig appFactory] sourceUrl];

}
/**
 *  获取用户协议
 *
 *  @return
 */
+ (NSString *)agreementUrl {
    return [[HMAppFactoryConfig appFactory] agreementUrl];
}


/**
 *  隐私协议
 *
 *  @return
 */
+ (NSString *)privacyUrl {
    return [[HMAppFactoryConfig appFactory] privacyUrl];
}

/**
 *  获取商店Url
 *
 *  @return
 */
+ (NSString *)shopUrl {
    return [[HMAppFactoryConfig appFactory] shopUrl];

}
    

    

/**
 *  获取商店名称
 *
 *  @return
 */
+ (NSString *)shopName {
    return [[HMAppFactoryConfig appFactory] shopName];

}

/**
 *  获取app名称
 *
 *  @return
 */
+ (NSString *)appName {
    return [[HMAppFactoryConfig appFactory] appName];

}

/**
 获取 App 软件工厂信息
 */
+ (void)getAppFactoryDataFromServer:(AppFactoryUpdateCallback)callBack {
    [HMAppFactoryConfig getAppFactoryDataFromServer:callBack];
}

/**
 *  获取微博授权码
 *
 *  @return
 */
+ (NSString *)weiboAuth {
    return [[HMAppFactoryConfig appFactory] weiboAuth];

}

//'我的' 页面的 (帮助中心 和 关于)
+ (NSMutableArray *)settingConfigItems {
    return [[HMAppFactoryConfig appFactory] settingConfigItems];
}

+ (NSMutableArray *)myCenterItemsContainShop:(BOOL)containShop {
    return [[HMAppFactoryConfig appFactory] myCenterItemsContainShop:containShop];
}

/**
 *  获取QQ授权码
 *
 *  @return
 */
+ (NSString *)qqAuth {
    return [[HMAppFactoryConfig appFactory] qqAuth];
}

/**
 *  获取微信授权码
 *
 *  @return
 */
+ (NSString *)wechatAuth {
    return [[HMAppFactoryConfig appFactory] wechatAuth];
}


/**
 *  获取微信token
 *
 *  @return
 */
+ (NSString *)wechatAuthToken{
    return [[HMAppFactoryConfig appFactory] wechatAuthToken];
}

/**
 *  获取taobao授权码
 *
 *  @return
 */
+ (NSString *)taobaoAuth {
    return [[HMAppFactoryConfig appFactory] taobaoAuth];
}

/**
 *  彩生活授权码
 *
 *  @return
 */
+ (NSString *)caiShengHuoAuth {
    return [[HMAppFactoryConfig appFactory] taobaoAuth];
}

/**
 *  获取大拿授权码
 *
 *  @return
 */
+ (NSString *)daNaAppKey {
    return [[HMAppFactoryConfig appFactory] daNaAppKey];
}


/**
 *  获取高德地图key
 *
 *  @return
 */
+ (NSString *)gaodeMapKey {
    return [[HMAppFactoryConfig appFactory] gaodeMapKey];

}


/**
 *  获取controller的背景颜色
 *
 *  @return UIColor 默认透明
 */
+ (UIColor *)controllerBgColor {
    return [[HMAppFactoryConfig appFactory] controllerBgColor];
}



/**
 *  获取彩色字体颜色
 *
 *  @return UIColor 默认透明
 */
+ (UIColor *)appFontColor {
    return [[HMAppFactoryConfig appFactory] appFontColor];

}

+ (UIColor *)appFontColorAlpha:(CGFloat)alpha {
    return [[HMAppFactoryConfig appFactory] appFontColorAlpha:alpha];

}


/**
 获取主题颜色的hex字符串
 
 @return颜色的hex字符串
 */
+ (NSString *)appTopicColorString {
    return [[HMAppFactoryConfig appFactory] appTopicColorString];

}

/**
 *  获取app主题颜色
 *
 *  @return UIColor 默认透明
 */
+ (UIColor *)appTopicColor {
    return [[HMAppFactoryConfig appFactory] appTopicColorAlpha:1];

}





/**
 *  获取app主题颜色
 *
 *  alpha 透明度
 *
 *  @return UIColor 默认透明
 */
+ (UIColor *)appTopicColorAlpha:(CGFloat)alpha {
    return [[HMAppFactoryConfig appFactory] appTopicColorAlpha:alpha];

}


/**
 *  获取安防颜色
 *
 *  @return UIColor 默认透明
 */
+ (UIColor *)secuityBgColor {
    return [[HMAppFactoryConfig appFactory] secuityBgColor];

}



/**
 *  获取tabbarItem
 *
 *  @return NSArray 包含HMAppNaviTab对象
 */
+ (NSArray <HMAppNaviTab *> *)tabBarItems {

    return [[HMAppFactoryConfig appFactory] tabBarItems];
}


/**
 获取声音的item
 
 @return 声音的Item
 */
+ (HMAppNaviTab *)voicetabBarItem {

    return [[HMAppFactoryConfig appFactory] voicetabBarItem];

}

+ (HMAppNaviTab *)scenetabBarItem {
    return [[HMAppFactoryConfig appFactory] scenetabbarItem];
}

/**
 *  获取添加设备列表的一级目录
 *
 *  @return NSArray 包含HMAppProductType对象
 */
+ (NSArray <HMAppProductType *> *)addDeviceFirstLevel {
    return [[HMAppFactoryConfig appFactory] addDeviceFirstLevel];
}


/**
 *  获取添加设备列表的二级目录
 *
 *  preProductTypeId 父目录Id
 *
 *  @return NSArray 包含HMAppProductType对象
 */
+ (NSArray <HMAppProductType *>*)addDeviceSecondLevel:(NSString *)preProductTypeId {
    return [[HMAppFactoryConfig appFactory] addDeviceSecondLevel:preProductTypeId];
}

/**
 个人中心的位置
 
 @return
 */
+ (NSUInteger)personTabBarItemIndex {
    return [[HMAppFactoryConfig appFactory] personTabBarItemIndex];
}

/**
 获取app设置表
 
 @return
 */
+ (HMAppSettingLanguage *)appSettingLanguageModel {
    return [[HMAppFactoryConfig appFactory] appSettingLanguageModel];
}

/**
 *  根据ViewUrl获取PAppProductType
 *
 *  @return  HMAppProductType对象 有可能为nil
 */
+ (HMAppProductType *)getAppProductTypeWithViewUrl:(NSString *)viewUrl {
    return [[HMAppFactoryConfig appFactory] getAppProductTypeWithViewUrl:viewUrl];

}

@end
