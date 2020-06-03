//
//  VihomeUserGatewayBind.h
//  Vihome
//
//  Created by Air on 15/7/24.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"
#import "HomeMateSDK.h"

@interface HMUserGatewayBind : HMBaseModel

@property (nonatomic, copy) NSString *            bindId;
@property (nonatomic, copy) NSString *            saveTime;
@property (nonatomic, assign)int                  userType;
//@property (nonatomic, strong) NSString *        familyId; //父类已定义
@property (nonatomic, copy)NSString *             model;
@property (nonatomic, assign,readonly) BOOL       wifiFlag;   // 0:ZigBee设备 1:WiFi设备 2:大主机 3:小主机 4:MixPad

// 非协议字段
@property (nonatomic, assign,readonly) BOOL       isVicenter; // 判断当前设备是否是主机


// 未使用，未保存字段
//@property (nonatomic, copy) NSString *            token;
//@property (nonatomic, copy) NSString *            longitude;
//@property (nonatomic, copy) NSString *            latotide;
//@property (nonatomic, copy) NSString *            country;
//@property (nonatomic, copy) NSString *            city;
//@property (nonatomic, copy) NSString *            state;
//@property (nonatomic, assign)int                  zoneOffset;
//@property (nonatomic, assign)int                  timeOffset;
//@property (nonatomic, copy) NSString *            userId; // 此字段已失效，查询绑定关系只需使用familyId即可



+(NSString *)modelTable; // userGatewayBind表本身不包含model字段，当需要查询model字段时，需要关联gateway表，此方法返回关联后的表
+(NSString *)uidStatement;



/**
 *  get 一个设备绑定信息
 *
 *  @param gateway 指定的设备
 */
+(HMUserGatewayBind *)bindWithGateway:(Gateway *)gateway;

+(HMUserGatewayBind *)bindWithHmGateway:(HMGateway *)gateway;

/**
 *  get 一个设备绑定信息
 *
 *  @param uid 指定设备的uid
 */

+(HMUserGatewayBind *)bindWithUid:(NSString *)uid;

/**
 *  根据uid和model生成一条设备的绑定关系
 *
 *  @param uid 指定设备的uid
 *
 *  @return HMUserGatewayBind
 */
+(HMUserGatewayBind *)bindWithUid:(NSString *)uid model:(NSString *)theModel;

/**
 *  根据 familyId 返回对应的绑定关系
 */
+(NSArray *)bindArrayWithFamilyId:(NSString *)familyId;



/**
 *  判断指定的uid是否是WIFI设备
 */
+(BOOL)isWifiDeviceWithUid:(NSString *)uid;

/**
 *  判断指定的uid是否是主机
 */
+(BOOL)isHostWithUid:(NSString *)uid;

/**
 *  返回widget需要的绑定关系字典
 */

-(NSDictionary *)widgetBindInfo;

/**
 是否绑定了某Uid
 */
+ (BOOL)isHasBindUid:(NSString *)uid;

// 返回主机的绑定信息数组
+(NSMutableArray<HMUserGatewayBind *> *)zigbeeHostBindArray;

// 所有设备的绑定信息
+(NSMutableArray<HMUserGatewayBind *> *)allDeviceBindArray;

// WiFi设备的绑定信息
+(NSMutableArray<HMUserGatewayBind *> *)wifiDeviceBindArray;

@end
