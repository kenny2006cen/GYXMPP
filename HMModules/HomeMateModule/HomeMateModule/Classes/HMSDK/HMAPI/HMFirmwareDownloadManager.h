//
//  HMFirmwareDownloadManager.h
//  HomeMate
//
//  Created by Feng on 2018/1/20.
//  Copyright © 2018年 Air. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMConstant.h"


typedef NS_ENUM(NSInteger,C1UpdateProcess) {
    C1UpdateProcessUpdating,//升级中
    C1UpdateProcessDownLoadWifiFail,//下载wifi固件失败
    C1UpdateProcessDownLoadMCUFail,//下载mcu固件失败
    C1UpdateProcessWiFiUpdateFail,//wifi固件升级失败
    C1UpdateProcessMCUUpdateFail,//mcu固件升级失败
    C1UpdateProcessMCUTransmissionFail,//mcu传输失败
    C1UpdateProcessUpdateSuccess,//升级成功
    C1UpdateProcessUpdateFail,//升级失败
};

/**
 * 固件下载状态变化
 */
static NSString *const kNOTIFICATION_FIRMWAREDOWNLOADSTATUSCHANGE = @"kNOTIFICATION_FIRMWAREDOWNLOADSTATUSCHANGE";

typedef void(^completeBlock)(NSURL *filePath, NSError *error, HMFirmwareModel *firmware);


typedef NS_ENUM(NSUInteger, HMFirmwareDownloadManagerStatus) {
    HMFirmwareDownloadManagerStatusDownloading,
    HMFirmwareDownloadManagerStatusSucceed,
    HMFirmwareDownloadManagerStatusFailed,
    HMFirmwareDownloadManagerStatusMD5Failed,
};

typedef void(^C1UpdateProcessBlock)(NSString * uid, C1UpdateProcess process, int percent);


@interface HMC1UpdateModel : NSObject
@property (nonatomic, strong) NSTimer * c1UpdateTimer;
@property (nonatomic, assign) int timerRepeatTimes;
@property (nonatomic, strong) NSString * uid;
@property (nonatomic, assign) C1UpdateProcess updateProcess;
@property (nonatomic, assign) int percent;
@property (nonatomic, strong) NSString * type;
@end

@interface HMFirmwareDownloadManager : NSObject

@property (assign, nonatomic) BOOL isDownloading;
@property (strong, nonatomic) HMDevice *device;
@property (strong, nonatomic) C1UpdateProcessBlock updateProcess;

+ (instancetype)manager;
- (void)downloadFirmware:(HMFirmwareModel *)firmware completeBlock:(completeBlock)completeBlock;
- (void)downloadFirmwares:(NSArray <HMFirmwareModel *> *)firmwareArr device:(HMDevice *)device oneCompleteBlock:(completeBlock)oneCompleteBlock;

- (void)handleDeviceUpdatingData:(NSDictionary *)dict;
- (HMGateway *)getTemporaryStorageGateway:(NSString *)uid;
- (void)removeTemporaryStorageGateway:(NSString *)uid;
- (void)removeTemporaryStorageModelTimeOut:(NSString *)uid;
- (HMC1UpdateModel *)getUpdatingModel:(NSString *)uid;
@end
