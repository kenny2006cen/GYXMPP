//
//  HMDeviceBusinss.h
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseBusiness.h"

@interface HMDeviceBusinss : HMBaseBusiness


+ (NSInteger)cameraType:(NSString *)uid;


/**
 判断p2p摄像头是否已被添加

 @param did 摄像头did
 */
+ (BOOL)isHasAddedP2PCameraDid:(NSString *)did;


/**
 添加p2p摄像头

 @param chDID 摄像头DID
 @param block 回调添加结果
 */
+ (void)addP2PCameraChDID:(NSString *)chDID result:(KReturnValueBlock)block;

/**
 获取萤石token

 @param phoneNumber 电话号码
 @param block 回调
 */
+ (void)getAccessTokenFromYS:(NSString *)phoneNumber result:(void(^)(NSString *token))block;

/**
 是否已添加萤石摄像头
 
 @param serial 设备序列号
 @return BOOL
 */
+ (BOOL)isAddedYSCameraWithSerial:(NSString *)serial;

/**
 添加萤石摄像头
 
 @param serial 设备序列号
 @param code 设备验证码
 @param isSupportPTZ 是否支持云台
 @param block 回调
 */
+ (void)addYSCameraWithDeviceSerial:(NSString *)serial verifyCode:(NSString *)code isSupportPTZ:(BOOL)isSupportPTZ result:(KReturnValueBlock)block;

/**
 删除萤石摄像头

 @param device 萤石device
 @param block 回调
 */
+ (void)deleteYSCameraWithDevice:(HMDevice *)device result:(KReturnValueBlock)block;

/**
 获取一个在线的主机uid

 @return 主机uid
 */
+ (NSString *)onlineHostUid;

+ (void)controlClothesHangerWithDevice:(HMDevice *)device
                              ctrlType:(HMClothesHangerCtrlType)cType
                                result:(KReturnValueBlock)block;

+ (void)controlAlarmDevice:(HMDevice *)device isStartAlarm:(BOOL)isStartAlarm result:(KReturnValueBlock)block;
+ (void)setDeviceParmWithDevice:(HMDevice *)device paramId:(NSString *)paramId paramType:(int)paramType paramValue:(NSString *)paramValue completeBlock:(SocketCompletionBlock)completionBlock;

// isIgnoreReport: 0表示不忽略属性报告 1表示忽略返回属性报告
+ (void)controlDevice:(HMDevice *)device
                order:(NSString *)order
               value1:(int)value1
               value2:(int)value2
               value3:(int)value3
               value4:(int)value4
       isIgnoreReport:(int)isIgnoreReport
        completeBlock:(SocketCompletionBlock)completionBlock;

// 幻彩灯带主题控制
+ (void)colorLightThemeControlDevice:(HMDevice *)device
                      themeParameter:(NSDictionary *)themeParameter
                       completeBlock:(SocketCompletionBlock)completionBlock;
// 幻彩灯带主题设置
+ (void)themeSetingWithDeviceUid:(NSString *)uid
                         themeId:(NSString *)themeId
                 themeParameter:(NSDictionary *)themeParameter
                  completeBlock:(SocketCompletionBlock)completionBlock;

+ (void)setLockSettingsWithArray:(NSArray<HMDeviceSettingModel *> *)array
                          device:(HMDevice *)device
                   completeBlock:(SocketCompletionBlock)completionBlock;

+ (void)musicControlColorLightWithUid:(NSString *)uid lightValue:(int)lightValue changeTime:(int)changeTime lanCommonuicationKey:(NSString *)lanCommonuicationKey;

/**
 支持设备和设备组控制，以及两者的局域网控制
 灯组需要虚拟成 HMDevice 对象，deviceType = KDeviceTypeDeviceGroup
 局域网控制时，接口会自动查询灯组中的设备所在的主机，分别向各个主机发送控制指令
 */
+ (void)controlDevice:(HMDevice *)device cmd:(ControlDeviceCmd *)cmd completion:(commonBlockWithObject)completion;

/**
 支持设备和设备组控制，以及两者的局域网控制
 局域网控制时，接口根据传入的主机uidArray，分别向各个主机发送控制指令
 使用场景：widget中不保存数据库，无法自动查询灯组中的设备所在的主机，需要外部主动传入uid数据
 */
+ (void)controlDeviceWithCmd:(ControlDeviceCmd *)cmd uidArray:(NSArray *)uidArray completion:(commonBlockWithObject)completion;

@end
