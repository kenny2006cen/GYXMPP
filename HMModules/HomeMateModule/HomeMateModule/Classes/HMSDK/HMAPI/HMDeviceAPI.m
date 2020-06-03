//
//  HMDeviceAPI.m
//  HomeMateSDK
//
//  Created by Air on 2017/5/2.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMDeviceAPI.h"
#import "HMDeviceBusinss.h"

@implementation HMDeviceAPI

+ (NSInteger)cameraType:(NSString *)uid {
    return  [HMDeviceBusinss cameraType:uid];
}

+ (BOOL)isHasAddedP2PCameraDid:(NSString *)did {
    return [HMDeviceBusinss isHasAddedP2PCameraDid:did];
}

+ (void)addP2PCameraChDID:(NSString *)chDID result:(KReturnValueBlock)block {
    [HMDeviceBusinss addP2PCameraChDID:chDID result:block];
}

+ (void)getAccessTokenFromYSWithPhoneNumber:(NSString *)phoneNumber result:(void (^)(NSString *))block{
   return [HMDeviceBusinss getAccessTokenFromYS:phoneNumber result:block];
}

+ (BOOL)isAddedYSCameraWithSerial:(NSString *)serial {
    return [HMDeviceBusinss isAddedYSCameraWithSerial:serial];
}

+ (void)addYSCameraWithDeviceSerial:(NSString *)serial verifyCode:(NSString *)code isSupportPTZ:(BOOL)isSupportPTZ result:(KReturnValueBlock)block {
    [HMDeviceBusinss addYSCameraWithDeviceSerial:serial verifyCode:code isSupportPTZ:isSupportPTZ result:block];
}

+ (void)deleteYSCameraWithDevice:(HMDevice *)device result:(KReturnValueBlock)block {
    [HMDeviceBusinss deleteYSCameraWithDevice:(HMDevice *)device result:(KReturnValueBlock)block];
}

+ (NSString *)onlineHostUid {
    return [HMDeviceBusinss onlineHostUid];
}

+ (void)controlClothesHangerWithDevice:(HMDevice *)device
                              ctrlType:(HMClothesHangerCtrlType)cType
                                result:(KReturnValueBlock)block {
    [HMDeviceBusinss controlClothesHangerWithDevice:device ctrlType:cType result:block];
}

+ (void)controlAlarmDevice:(HMDevice *)device isStartAlarm:(BOOL)isStartAlarm result:(KReturnValueBlock)block
{
    [HMDeviceBusinss controlAlarmDevice:device isStartAlarm:isStartAlarm result:block];
}

+ (void)setDeviceParmWithDevice:(HMDevice *)device paramId:(NSString *)paramId paramType:(int)paramType paramValue:(NSString *)paramValue completeBlock:(SocketCompletionBlock)completionBlock
{
    [HMDeviceBusinss setDeviceParmWithDevice:device paramId:paramId paramType:paramType paramValue:paramValue completeBlock:completionBlock];
}

+ (void)controlDevice:(HMDevice *)device
                order:(NSString *)order
               value1:(int)value1
               value2:(int)value2
               value3:(int)value3
               value4:(int)value4
        completeBlock:(SocketCompletionBlock)completionBlock {
    [self controlDevice:device order:order value1:value1 value2:value2 value3:value3 value4:value4 isIgnoreReport:0 completeBlock:completionBlock];
}

+ (void)controlDevice:(HMDevice *)device
                order:(NSString *)order
               value1:(int)value1
               value2:(int)value2
               value3:(int)value3
               value4:(int)value4
     isIgnoreReport:(int)isIgnoreReport
        completeBlock:(SocketCompletionBlock)completionBlock {
    [HMDeviceBusinss controlDevice:device order:order value1:value1 value2:value2 value3:value3 value4:value4 isIgnoreReport:isIgnoreReport completeBlock:completionBlock];
}

+ (void)colorLightThemeControlDevice:(HMDevice *)device
                      themeParameter:(NSDictionary *)themeParameter
                       completeBlock:(SocketCompletionBlock)completionBlock {
    [HMDeviceBusinss colorLightThemeControlDevice:device themeParameter:themeParameter completeBlock:completionBlock];
}
// 幻彩灯带主题设置
+ (void)themeSetingWithDeviceUid:(NSString *)uid
                         themeId:(NSString *)themeId
                 themeParameter:(NSDictionary *)themeParameter
                  completeBlock:(SocketCompletionBlock)completionBlock {
    [HMDeviceBusinss themeSetingWithDeviceUid:uid themeId:themeId themeParameter:themeParameter completeBlock:completionBlock];
}
    
+ (void)setLockSettingsWithArray:(NSArray<HMDeviceSettingModel *> *)array
                          device:(HMDevice *)device
                   completeBlock:(SocketCompletionBlock)completionBlock{
    [HMDeviceBusinss setLockSettingsWithArray:array device:device completeBlock:completionBlock];
}

+ (void)musicControlColorLightWithUid:(NSString *)uid lightValue:(int)lightValue changeTime:(int)changeTime lanCommonuicationKey:(NSString *)lanCommonuicationKey {
    [HMDeviceBusinss musicControlColorLightWithUid:uid lightValue:lightValue changeTime:changeTime lanCommonuicationKey:lanCommonuicationKey];
    
}

/**
 支持设备和设备组控制，以及两者的局域网控制
 灯组需要虚拟成 HMDevice 对象，deviceType = KDeviceTypeDeviceGroup
 局域网控制时，接口会自动查询灯组中的设备所在的主机，分别向各个主机发送控制指令
 */
+ (void)controlDevice:(HMDevice *)device cmd:(ControlDeviceCmd *)cmd completion:(commonBlockWithObject)completion
{
    [HMDeviceBusinss controlDevice:device cmd:cmd completion:completion];
}


/**
 支持设备和设备组控制，以及两者的局域网控制
 局域网控制时，接口根据传入的主机uidArray，分别向各个主机发送控制指令
 */
+ (void)controlDeviceWithCmd:(ControlDeviceCmd *)cmd uidArray:(NSArray *)uidArray completion:(commonBlockWithObject)completion{
    [HMDeviceBusinss controlDeviceWithCmd:cmd uidArray:uidArray completion:completion];
}

@end
