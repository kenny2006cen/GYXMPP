//
//  HMFirmwareModel.h
//  HomeMate
//
//  Created by Feng on 2017/12/25.
//  Copyright © 2017年 Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HMDevice;
@class HMGateway;

#define HMFirmwareUpdateCountDownTime 180 //wifi设备固件升级倒计时(3.6 - 设备管理 - 固件升级)

typedef NS_ENUM(NSUInteger, HMFirmwareUpdateStatus) {
    HMFirmwareUpdateStatusNormal,
    HMFirmwareUpdateStatusLoading,
    HMFirmwareUpdateStatusUpdating,
    HMFirmwareUpdateStatusDeviceReseting,
    HMFirmwareUpdateStatusSucceed,
    HMFirmwareUpdateStatusFailed,
    
    HMFirmwareUpdateStatus_T1_Downloading,
    HMFirmwareUpdateStatus_T1_Downloading_Failed,
    HMFirmwareUpdateStatus_T1_Updating,
    HMFirmwareUpdateStatus_T1_Updating_Failed,
};

@interface HMFirmwareModel : NSObject
@property (copy, nonatomic) NSString * type; //见24.网关信息表 gateway的hardwareVersion，softwareVersion，coordinatorVersion，systemVersion
@property (assign, nonatomic) int isForce; //0:不强制; 1: 强制
@property (copy, nonatomic) NSString * NewVersion;
@property (copy, nonatomic) NSString * md5;
@property (copy, nonatomic) NSString * downloadUrl;
@property (copy, nonatomic) NSString * desc;
@property (copy, nonatomic) NSURL * filePath;//T1门锁固件下载到本地的路径

//wifi设备固件升级需要的属性
@property (copy, nonatomic) NSString * size;
@property (strong, nonatomic) HMDevice * device;
@property (assign, nonatomic) CGFloat descHeight;
@property (assign, nonatomic) CGFloat nameHeight;
@property (assign, nonatomic) NSTimeInterval updateStartTime; //开始升级的时间,用来120s倒计时
@property (assign, nonatomic, readonly) NSTimeInterval updateLeftTime; //120倒计时剩下的时间
@property (assign, nonatomic) HMFirmwareUpdateStatus updateStatus;

//3.6版本设备管理固件升级
@property (copy, nonatomic) NSString *target;
@property (assign, nonatomic) int targetType; //0.针对zigbee设备升级;  1.针对主机和wifi设备升级
@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) NSString *modelId;
@property (assign, nonatomic) int upgradeTime; //更新时间的时间戳
@property (copy, nonatomic) NSString *upgradeTimeStr;
@property (strong, nonatomic) HMGateway *gateway;//主机
@property (copy, nonatomic) NSString *t1UpdatingStr;//T1门锁升级过程中的文案
@end
