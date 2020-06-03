//
//  HMFirmwareDownloadManager.m
//  HomeMate
//
//  Created by Feng on 2018/1/20.
//  Copyright © 2018年 Air. All rights reserved.
//

#import "HMFirmwareDownloadManager.h"
//#import "AFNetworking.h"
#import <CommonCrypto/CommonCrypto.h>



@implementation HMC1UpdateModel

- (void)setPercent:(int)percent {
    _percent = percent;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(removeSelfFromUpdateModels) withObject:nil afterDelay:120 inModes:@[NSRunLoopCommonModes]];
}

- (void)removeSelfFromUpdateModels {
    [[HMFirmwareDownloadManager manager] removeTemporaryStorageModelTimeOut:self.uid];
}

@end


@interface HMFirmwareDownloadManager ()
//@property (strong, nonatomic) AFHTTPSessionManager *afManager;
@property (nonatomic, strong) NSMutableArray * updateGateways;
@property (nonatomic, strong) NSMutableArray <HMC1UpdateModel *>* C1UpdateModels;
@end

@implementation HMFirmwareDownloadManager

+ (instancetype)manager {
    static HMFirmwareDownloadManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HMFirmwareDownloadManager alloc] init];
//        manager.afManager = [AFHTTPSessionManager manager];
        
    });
    return manager;
}

//- (instancetype)init {
//    if (self == [super init]) {
//
//        __block int count = 0;
//
//        NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//
//            count ++;
//
//            NSMutableDictionary * dict = [NSMutableDictionary dictionary];
//            [dict setObject:@"d178afca506d43ba8203de8d9bbcfb49" forKey:@"uid"];
//            [dict setObject:@[@"softwareVersion",@"mcuVersion"] forKey:@"typeList"];
//
//            if (count < 11) {//下载 wifi 固件下载
//                [dict setObject:@(5) forKey:@"stage"];
//                [dict setObject:@(count * 10) forKey:@"process"];
//                [dict setObject:@"softwareVersion" forKey:@"type"];
//
//                if (count * 10 == 100) { //wifi固件下载完成
//                    [dict setObject:@(6) forKey:@"stage"];
//                }
//
//            }else if(count == 12){//wifi固件正在重启
//                [dict setObject:@(2) forKey:@"stage"];
//                [dict setObject:@"softwareVersion" forKey:@"type"];
//
//            } else if(count < 60) {//wifi 固件正在重启
//
//            }else if(count == 60){//wifi固件升级完成
//                [dict setObject:@(3) forKey:@"stage"];
//                [dict setObject:@"softwareVersion" forKey:@"type"];
//            }else if(count < 71){//mcu 固件下载
//                [dict setObject:@(5) forKey:@"stage"];
//                [dict setObject:@"mcuVersion" forKey:@"type"];
//                [dict setObject:@(count-60) forKey:@"process"];
//
//            }else if(count < 251){//mcu固件传输
//                [dict setObject:@(1) forKey:@"stage"];
//                [dict setObject:@"mcuVersion" forKey:@"type"];
//                [dict setObject:@(10 + (90 * count)/250) forKey:@"process"];
//
//            }else if(count == 252){//mcu正在重启
//                [dict setObject:@(2) forKey:@"stage"];
//                [dict setObject:@"mcuVersion" forKey:@"type"];
//
//            }else if(count == 253){//mcu升级完成
//                [dict setObject:@(3) forKey:@"stage"];
//                [dict setObject:@"mcuVersion" forKey:@"type"];
//                [timer invalidate];
//            }
//
//            [self handleDeviceUpdatingData:dict];
//
//        }];
//
//        [timer fire];
//    }
//    return self;
//}

- (void)downloadFirmware:(HMFirmwareModel *)firmware completeBlock:(completeBlock)completeBlock {
    
    if (!firmware.downloadUrl.length) {
        NSError *error = [NSError errorWithDomain:@"HMFirmwareDownloadManager" code:123 userInfo:@{NSLocalizedDescriptionKey : @"下载地址为空"}];
        completeBlock(nil, error, firmware);
    }
    
    //路径
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"firmware"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *fileName = firmware.NewVersion;
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    //校验文件是否已经存在,如果存在且md5校验失败,就要删除, 因为下面这种下载方法AF不会覆盖下载
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (data) {
        if ([[self md5String:data] isEqualToString:firmware.md5]) {
            if (completeBlock) {
                completeBlock([NSURL fileURLWithPath:filePath isDirectory:NO], nil, firmware);
                return;
            }
        }else {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
            DLog(@"下载前文件已经存在, 且MD5校验失败:%@, 删除之error = %@",firmware, error);
        }
    }
    
    //请求
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:firmware.downloadUrl]];
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (completeBlock) {
             NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            if(location){
                DLog(@"将文件移动到目的路径，系统路径：%@ 目的路径：%@",location,fileURL);
                NSError *moveError = nil;
                if (![[NSFileManager defaultManager] moveItemAtURL:location toURL:fileURL error:&moveError]) {
                    DLog(@"移动文件出错,error：%@",moveError);
                };
            }else {
                DLog(@"将文件移动到目的路径，系统路径：%@ 出错",location);
            }
             completeBlock(fileURL, error, firmware);
            
        }
    }];
    
    [task resume];
}

- (void)downloadFirmwares:(NSArray <HMFirmwareModel *> *)firmwareArr device:(HMDevice *)device oneCompleteBlock:(completeBlock)oneCompleteBlock {
    
    __block NSMutableArray *successArr = [NSMutableArray array];
    __block NSMutableArray *countArr = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    self.isDownloading = YES;
    self.device = device;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_FIRMWAREDOWNLOADSTATUSCHANGE object:nil userInfo:@{@"status":@(HMFirmwareDownloadManagerStatusDownloading)}];
    
    for (HMFirmwareModel *firmware in firmwareArr) {
        [self downloadFirmware:firmware completeBlock:^(NSURL *filePath, NSError *error, HMFirmwareModel *firmware) {
            
            if (oneCompleteBlock) {
                oneCompleteBlock(filePath, error, firmware);
            }
            
            //检查下载任务是否全部返回
            [countArr addObject:firmware];
            if (countArr.count == firmwareArr.count) {
                weakSelf.isDownloading = NO;
            }
            
            if (!error) {
                
                firmware.filePath = filePath;
                NSData *data = [NSData dataWithContentsOfURL:filePath];
                if ([[weakSelf md5String:data] isEqualToString:firmware.md5]) {
                    [successArr addObject:firmware];
                }else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_FIRMWAREDOWNLOADSTATUSCHANGE object:nil userInfo:@{@"status":@(HMFirmwareDownloadManagerStatusMD5Failed)}];
                    [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
                    DLog(@"MD5校验失败:%@",firmware);
                }
                if (successArr.count == firmwareArr.count) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_FIRMWAREDOWNLOADSTATUSCHANGE object:nil userInfo:@{@"status":@(HMFirmwareDownloadManagerStatusSucceed)}];
                    DLog(@"固件下载成功");
                    
                    if ([HMBluetoothLockAPI bluetoothOpen] && [HMBluetoothLockAPI bluetoothConnectToBlueMac:self.device.blueExtAddr]) {
                        [HMBluetoothLockAPI startFirmwareUpdateDevice:self.device filesArrays:successArr];
                    }else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_T1UPLOADBLURTOOTHBREAK object:nil];
                    }
                    
                }
            }else {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_FIRMWAREDOWNLOADSTATUSCHANGE object:nil userInfo:@{@"status":@(HMFirmwareDownloadManagerStatusFailed)}];
                DLog(@"固件下载失败:%@, err = %@",firmware, error);
            }
        }];
    }
}

- (NSString *)md5String:(NSData *)data
{
    const char *str = [data bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)data.length, result);
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02X", result[i]];
    }
    
    return [hash lowercaseString];
}


- (void)handleDeviceUpdatingData:(NSDictionary *)dict {
    
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    int cmd = [[dict objectForKey:@"cmd"] intValue];
    if (cmd == 76) {
        DLog(@"这里不处理76命令");
        return;
    }
    
    NSMutableDictionary * mdict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    NSString * uid = [mdict objectForKey:@"uid"];
    HMDevice * device = [HMDevice objectWithUid:uid];
    if (device == nil || !device.isC1Lock) {
        return;
    }
    
    [self temporaryStorageGatewayVersion:uid];
    
    HMC1UpdateModel * updateModel = [self getCurrentUpdateModel:uid];
    
    NSString * typeListString = [mdict objectForKey:@"typeList"];
    NSMutableArray * typeList = nil;
    if ([typeListString isKindOfClass:[NSString class]]) {//这里为了兼容门锁上报的格式不规范
        typeList = [NSMutableArray array];
        if ([typeListString containsString:@"softwareVersion"] && [typeListString containsString:@"mcuVersion"]) {
            [typeList addObject:@"softwareVersion"];
            [typeList addObject:@"mcuVersion"];
        }else if ([typeListString containsString:@"softwareVersion"]) {
            [typeList addObject:@"softwareVersion"];

        }else if ([typeListString containsString:@"mcuVersion"]) {
            [typeList addObject:@"mcuVersion"];
        }
        [mdict setObject:typeList forKey:@"typeList"];
    }else if([typeListString isKindOfClass:[NSArray class]]) {
        typeList = [[mdict objectForKey:@"typeList"] mutableCopy];
    }
    
    if(![typeList isKindOfClass:[NSArray class]]) {
        return;
    }
    NSString * type = [mdict objectForKey:@"type"];
    updateModel.type = type;
    if([typeList containsObject:@"mcuVersion"] && [typeList containsObject:@"softwareVersion"]){//说明有wifi固件也有mcu固件
        
        
        if ([type isEqualToString:@"softwareVersion"]) {//正在升级wifi固件
            int stage = [[mdict objectForKey:@"stage"] intValue];
            if (stage == 5) {//正在下载固件
                int percent = [[mdict objectForKey:@"process"] intValue];//设备上报下载进度按100%上报，app按10%处理，所以这个要转换一下
                int appPercent = percent/10;
                [self updateProcessUid:uid process:C1UpdateProcessUpdating percent:appPercent];

            }else if(stage == 6) {//下载固件完成 进度10
                [self updateProcessUid:uid process:C1UpdateProcessUpdating percent:10];

            }else if(stage == 2){//正在重启，开始倒计时查询是否升级成功
                [self stopUpdateTimer:updateModel];
                NSTimeInterval space = 60/10.0;
                NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:mdict];
                [userInfo setObject:@"wifiProcess" forKey:@"timerFun"];
                updateModel.c1UpdateTimer = [NSTimer timerWithTimeInterval:space target:self selector:@selector(c1UpdateTimerHanle:)  userInfo:userInfo repeats:YES];
                [[NSRunLoop currentRunLoop] addTimer:updateModel.c1UpdateTimer forMode:NSRunLoopCommonModes];
                [updateModel.c1UpdateTimer fire];
            }else if(stage == 3){//升级完成，要停掉timer，进度20
                [self stopUpdateTimer:updateModel];
                [self updateProcessUid:uid process:C1UpdateProcessUpdating percent:20];
                
            }else if(stage == 7) {//固件下载失败
                [self updateProcessUid:uid process:C1UpdateProcessDownLoadWifiFail percent:0];
                
            }else if(stage == 8) {//固件升级失败
                [self updateProcessUid:uid process:C1UpdateProcessWiFiUpdateFail percent:0];

            }else if(stage == 4) {//固件校验失败
                [self updateProcessUid:uid process:C1UpdateProcessWiFiUpdateFail percent:0];
            }
            
        }else if([type isEqualToString:@"mcuVersion"]) {//正在升级mcu固件
            int stage = [[mdict objectForKey:@"stage"] intValue];
            if (stage == 5 || stage == 1) {//正在下载固件和正在传输固件
                [self stopUpdateTimer:updateModel];
                int percent = [[mdict objectForKey:@"process"] intValue];//设备上报下载进度按100%上报，app按设备进度处理
                [self updateProcessUid:uid process:C1UpdateProcessUpdating percent:20 + percent * 0.8];

            }else if(stage == 3 || stage == 2){//完成，开始倒计时查询版本号
                
                [self stopUpdateTimer:updateModel];
                
                NSTimeInterval space = 2;
                NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:mdict];
                [userInfo setObject:@"checVersion" forKey:@"timerFun"];
                updateModel.c1UpdateTimer = [NSTimer scheduledTimerWithTimeInterval:space target:self selector:@selector(c1UpdateTimerHanle:) userInfo:userInfo repeats:YES];
                [updateModel.c1UpdateTimer fire];
            } else if(stage == 7) {//固件下载失败
                [self updateProcessUid:uid process:C1UpdateProcessDownLoadMCUFail percent:0];

            }else if(stage == 8) {//固件升级失败
                [self updateProcessUid:uid process:C1UpdateProcessMCUUpdateFail percent:0];

            }else if(stage == 9) {//固件传输失败
                [self updateProcessUid:uid process:C1UpdateProcessMCUTransmissionFail percent:0];

            }else if(stage == 4) {//固件校验失败
                [self updateProcessUid:uid process:C1UpdateProcessMCUUpdateFail percent:0];
            }
        }
        
    }else if ([typeList containsObject:@"softwareVersion"]) {//说明只有wifi固件
        
        int stage = [[mdict objectForKey:@"stage"] intValue];
        if (stage == 5) {//正在下载固件
            [self stopUpdateTimer:updateModel];
            int percent = [[mdict objectForKey:@"process"] intValue];//设备上报下载进度按100%上报，app按50%处理，所以这个要转换一下
            int appPercent = percent/2;
            [self updateProcessUid:uid process:C1UpdateProcessUpdating percent:appPercent];

        }else if(stage == 6) {//下载固件完成,进度 50
            [self updateProcessUid:uid process:C1UpdateProcessUpdating percent:50];

        }else if(stage == 2 || stage == 3){//正在重启，开始倒计时查询是否升级成功
            [self stopUpdateTimer:updateModel];
            NSTimeInterval space = 60/50.0;
            updateModel.c1UpdateTimer = [NSTimer timerWithTimeInterval:space target:self selector:@selector(c1UpdateTimerHanle:)  userInfo:mdict repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:updateModel.c1UpdateTimer forMode:NSRunLoopCommonModes];
            [updateModel.c1UpdateTimer fire];
        }else if(stage == 7) {//固件下载失败
            [self updateProcessUid:uid process:C1UpdateProcessDownLoadWifiFail percent:0];

            
        }else if(stage == 8) {//固件升级失败
            [self updateProcessUid:uid process:C1UpdateProcessWiFiUpdateFail percent:0];

        }else if(stage == 4) {//固件校验失败
            [self updateProcessUid:uid process:C1UpdateProcessWiFiUpdateFail percent:0];
        }
        
    }else if ([typeList containsObject:@"mcuVersion"]) {//说明只有mcu固件，这是按设备上报的进度处理
        [self stopUpdateTimer:updateModel];
        int stage = [[mdict objectForKey:@"stage"] intValue];
        if (stage == 5 || stage == 1) {//正在下载固件和正在传输固件
            int percent = [[mdict objectForKey:@"process"] intValue];//设备上报下载进度按100%上报，app按设备进度处理
            [self updateProcessUid:uid process:C1UpdateProcessUpdating percent:percent];

        }else if(stage == 7) {//固件下载失败
            [self updateProcessUid:uid process:C1UpdateProcessDownLoadMCUFail percent:0];

        }else if(stage == 8) {//固件升级失败
            [self updateProcessUid:uid process:C1UpdateProcessMCUUpdateFail percent:0];

        }else if(stage == 9) {//固件传输失败
            [self updateProcessUid:uid process:C1UpdateProcessMCUTransmissionFail percent:0];
        }else if(stage == 4) {//固件校验失败
            [self updateProcessUid:uid process:C1UpdateProcessMCUUpdateFail percent:0];
        }else if(stage == 3 || stage == 2) {//完成，开始倒计时查询版本号
            [self stopUpdateTimer:updateModel];
            NSTimeInterval space = 2;
            updateModel.c1UpdateTimer = [NSTimer timerWithTimeInterval:space target:self selector:@selector(c1UpdateTimerHanle:)  userInfo:mdict repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:updateModel.c1UpdateTimer forMode:NSRunLoopCommonModes];
            [updateModel.c1UpdateTimer fire];
        }
    }
    
    
}


- (void)c1UpdateTimerHanle:(NSTimer *)timer {
    
    NSDictionary * dict = timer.userInfo;
    
    if(dict == nil && ![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString * uid = [dict objectForKey:@"uid"];
    
    DLog(@"C1门锁执行timer userInfo = %@",dict);

    
    HMC1UpdateModel * updateModel = [self getCurrentUpdateModel:uid];
    
    NSArray * typeList = [dict objectForKey:@"typeList"];
    if([typeList containsObject:@"mcuVersion"] && [typeList containsObject:@"softwareVersion"]){//说明有wifi固件也有mcu固件
        
        NSString * timerFun = [dict objectForKey:@"timerFun"];
        if ([timerFun isEqualToString:@"wifiProcess"]) {
            
            updateModel.timerRepeatTimes ++; //相当于 （60/10.0）秒 加1
            if (updateModel.timerRepeatTimes * (60/10) > 60) {//说明倒计时已经结束
                [self stopUpdateTimer:updateModel];
                [self updateProcessUid:updateModel.uid process:C1UpdateProcessWiFiUpdateFail percent:0];
            }else {
                [self updateProcessUid:updateModel.uid process:C1UpdateProcessUpdating percent:10 + updateModel.timerRepeatTimes];
            }
            

            
        }else if([timerFun isEqualToString:@"checVersion"]) {
            updateModel.timerRepeatTimes ++; //2秒 加1；
            HMGateway * tempGateway = [[HMFirmwareDownloadManager manager] getTemporaryStorageGateway:updateModel.uid];
            HMGateway * currentGateway = [HMGateway objectWithUid:updateModel.uid];
            
            DLog(@"升级mcuVersion、softwareVersion完成，开始查询是否升级成功，保存的mcuVersion = %@，softwareVersion = %@",tempGateway.systemVersion,tempGateway.softwareVersion);
            DLog(@"升级mcuVersion、softwareVersion完成，开始查询是否升级成功，当前的mcuVersion = %@，softwareVersion = %@",currentGateway.systemVersion,currentGateway.softwareVersion);

            if (![tempGateway.softwareVersion isEqualToString:currentGateway.softwareVersion] && ![tempGateway.systemVersion isEqualToString:currentGateway.systemVersion]) {//当wifi固件版本、mcu固件版本号跟旧的都不同时就认为成功
                [self stopUpdateTimer:updateModel];
                [self updateProcessUid:updateModel.uid process:C1UpdateProcessUpdateSuccess percent:0];

            }else {
                
                if(updateModel.timerRepeatTimes > 30) {
                    [self stopUpdateTimer:updateModel];
                    if([tempGateway.systemVersion isEqualToString:currentGateway.systemVersion] && [tempGateway.softwareVersion isEqualToString:currentGateway.softwareVersion]) {
                        [self updateProcessUid:updateModel.uid process:C1UpdateProcessUpdateFail percent:0];

                    }else if([tempGateway.softwareVersion isEqualToString:currentGateway.softwareVersion]) {
                        [self updateProcessUid:updateModel.uid process:C1UpdateProcessWiFiUpdateFail percent:0];

                    }else if([tempGateway.systemVersion isEqualToString:currentGateway.systemVersion]) {
                        [self updateProcessUid:updateModel.uid process:C1UpdateProcessMCUUpdateFail percent:0];

                    }
                }else {//继续查询
                    [self updateProcessUid:updateModel.uid process:C1UpdateProcessUpdating percent:100];

                }
            }
        }
        
    }else if ([typeList containsObject:@"softwareVersion"]) {//说明只有wifi固件
        updateModel.timerRepeatTimes ++; //相当于 （60/50.0）秒 加1
        HMGateway * tempGateway = [[HMFirmwareDownloadManager manager] getTemporaryStorageGateway:updateModel.uid];
        HMGateway * currentGateway = [HMGateway objectWithUid:updateModel.uid];
        DLog(@"升级softwareVersion完成，开始查询是否升级成功，保存的softwareVersion = %@",tempGateway.softwareVersion);
        DLog(@"升级softwareVersion完成，开始查询是否升级成功，当前的softwareVersion = %@",currentGateway.softwareVersion);
        if (![tempGateway.softwareVersion isEqualToString:currentGateway.softwareVersion]) {//说明升级成功
            [self stopUpdateTimer:updateModel];
            //提示升级成功
            [self updateProcessUid:updateModel.uid process:C1UpdateProcessUpdateSuccess percent:50 + updateModel.timerRepeatTimes];

        }else {//说明没有升级成功
            if (updateModel.timerRepeatTimes * (60/50) >= 60) {//说明倒计时已经结束
                [self stopUpdateTimer:updateModel];
                [self updateProcessUid:updateModel.uid process:C1UpdateProcessWiFiUpdateFail percent:0];//提示升级失败

            }else {//说明倒计时没有结束，更新进度
                [self updateProcessUid:updateModel.uid process:C1UpdateProcessUpdating percent:50 + updateModel.timerRepeatTimes];

            }
        }
        
    }else if ([typeList containsObject:@"mcuVersion"]) {//说明只有mcu固件，查询是否升级成功
        updateModel.timerRepeatTimes ++; //2秒 加1；
        HMGateway * tempGateway = [[HMFirmwareDownloadManager manager] getTemporaryStorageGateway:updateModel.uid];
        HMGateway * currentGateway = [HMGateway objectWithUid:updateModel.uid];
        DLog(@"升级mcuVersion完成，开始查询是否升级成功，保存的mcuVersion = %@",tempGateway.systemVersion);
        DLog(@"升级mcuVersion完成，开始查询是否升级成功，当前的mcuVersion = %@",currentGateway.systemVersion);
        if (![tempGateway.systemVersion isEqualToString:currentGateway.systemVersion]) {//当wifi固件版本、mcu固件版本号跟旧的都不同时就认为成功
            [self stopUpdateTimer:updateModel];
            [self updateProcessUid:updateModel.uid process:C1UpdateProcessUpdateSuccess percent:0];
            
        }else {
            
            if(updateModel.timerRepeatTimes > 30) {
                [self stopUpdateTimer:updateModel];
                [self updateProcessUid:updateModel.uid process:C1UpdateProcessMCUUpdateFail percent:0];
            }else {//继续查询,显示 进度 100
                [self updateProcessUid:updateModel.uid process:C1UpdateProcessUpdating percent:100];
            }
        }
        
    }
    
    
}

- (void)stopUpdateTimer:(HMC1UpdateModel *)updateModel {
    [NSObject cancelPreviousPerformRequestsWithTarget:updateModel];
    [updateModel.c1UpdateTimer invalidate];
    updateModel.c1UpdateTimer = nil;
    updateModel.timerRepeatTimes = 0;
}

- (HMC1UpdateModel *)getCurrentUpdateModel:(NSString *)uid {
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.uid = %@",uid];
    NSArray * array = [self.C1UpdateModels filteredArrayUsingPredicate:pre];
    if (array.count) {
        return array.firstObject;
    }
    
    HMC1UpdateModel * model = [[HMC1UpdateModel alloc] init];
    model.uid = uid;
    [self.C1UpdateModels addObject:model];
    return model;
    
}

- (void)temporaryStorageGatewayVersion:(NSString *)uid {
    //先在数组里面找，找到就不存，找不到就存
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.uid = %@",uid];
    NSArray * searchArray = [self.updateGateways filteredArrayUsingPredicate:pre];
    if (searchArray.count == 0) {
        HMGateway * gateway = [HMGateway objectWithUid:uid];
        DLog(@"第一次gateway的mcuVersion = %@，softwareVersion = %@ ,uid = %@",gateway.systemVersion,gateway.softwareVersion,uid);
        if (gateway) {
            [self.updateGateways addObject:gateway];
        }
    }
}

- (HMGateway *)getTemporaryStorageGateway:(NSString *)uid {
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.uid = %@",uid];
    NSArray * searchArray = [self.updateGateways filteredArrayUsingPredicate:pre];
    if (searchArray.count) {
        HMGateway * gateway = searchArray.firstObject;
        return gateway;
    }
    return nil;
}

- (void)removeTemporaryStorageGateway:(NSString *)uid {
    
    HMGateway * gateway = [self getTemporaryStorageGateway:uid];
    if (gateway) {
        [self.updateGateways removeObject:gateway];
    }
    
}

- (void)removeTemporaryStorageModelTimeOut:(NSString *)uid {
    
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.uid = %@",uid];
    NSArray * array = [self.C1UpdateModels filteredArrayUsingPredicate:pre];
    if (array.count) {
        HMC1UpdateModel * updateModel = array.firstObject;
        [NSObject cancelPreviousPerformRequestsWithTarget:updateModel];//要把这个对象的进度超时时间取消
        [self.C1UpdateModels removeObject:updateModel];
        if (self.updateProcess) {
            DLog(@"uid = %@ type = %@ 超时两分钟没有更新数据进度，报失败",uid,updateModel.type);
            if ([updateModel.type isEqualToString:@"mcuVersion"]) {
              self.updateProcess(uid, C1UpdateProcessMCUUpdateFail, 0);
            }else if([updateModel.type isEqualToString:@"softwareVersion"]){
              self.updateProcess(uid, C1UpdateProcessWiFiUpdateFail, 0);
            }else {
              self.updateProcess(uid, C1UpdateProcessUpdateFail, 0);

            }
            
        }
    }
    
}

- (NSMutableArray *)updateGateways {
    
    if (_updateGateways == nil) {
        _updateGateways = [NSMutableArray array];
    }
    
    return _updateGateways;
    
}

- (NSMutableArray<HMC1UpdateModel *> *)C1UpdateModels {
    
    if (_C1UpdateModels == nil) {
        _C1UpdateModels = [NSMutableArray array];
    }
    
    return _C1UpdateModels;
    
}

- (HMC1UpdateModel *)getUpdatingModel:(NSString *)uid {
    
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.uid = %@",uid];
    NSArray * array = [self.C1UpdateModels filteredArrayUsingPredicate:pre];
    if (array.count) {
        HMC1UpdateModel * model = array.firstObject;
        if (model.updateProcess == C1UpdateProcessUpdating) {
            return model;
        }
    }
    return nil;
    
}

- (void)updateProcessUid:(NSString *)uid process:(C1UpdateProcess)process percent:(int)percent {
    
    if(process != C1UpdateProcessUpdating) {//只要不是升级中，其他状态都要把旧的gateway从暂存数据中清除
        [self removeTemporaryStorageGateway:uid];
        
        NSPredicate * pre = [NSPredicate predicateWithFormat:@"self.uid = %@",uid];
        NSArray * array = [self.C1UpdateModels filteredArrayUsingPredicate:pre];
        if (array.count) {
            HMC1UpdateModel * updateModel = array.firstObject;
            [NSObject cancelPreviousPerformRequestsWithTarget:updateModel];//要把这个对象的进度超时时间取消
            [self stopUpdateTimer:updateModel];
            [self.C1UpdateModels removeObject:updateModel];
        }
        
    }else {
        HMC1UpdateModel * updateModel = [self getCurrentUpdateModel:uid];
        updateModel.updateProcess = process;
        updateModel.percent = percent;
    }
    if (percent > 100) {
        percent = 100;
    }else if(percent < 0){
        percent = 0;
    }
    if (self.updateProcess) {
        self.updateProcess(uid, process, percent);
    }
}

@end
