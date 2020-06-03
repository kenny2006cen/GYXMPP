//
//  VhDeviceBind.m
//  HomeMate
//
//  Created by Orvibo on 15/8/12.
//  Copyright © 2017年 Orvibo. All rights reserved.
//

#import "HMDeviceBind.h"
#import "HMDeviceConfig.h"
#import "BLUtility.h"
#import "DeviceUnbindCmd.h"
#import "HMConstant.h"
#import "DeviceUnbindCmd.h"

@interface HMDeviceBind ()
@property (assign, nonatomic)int serialNumber;
@end

@implementation HMDeviceBind


/**
 *  解绑设备
 *
 *  @param device
 */
- (void)unBindDevice:(HMAPDevice *)device callback:(BindCallback)callback {
    
    DLog(@"一直解绑");
    if (self.isStop) {
        DLog(@"---------------绑定成功，停止解绑----------------");

        return;
    }
    
    DeviceUnbindCmd *deviceUnbind = [DeviceUnbindCmd object];
    if (self.serialNumber == 0) {
        self.serialNumber = [BLUtility getTimestamp];
    }
    
    // 固定流水号，多次发送时只缓存一个指令
    deviceUnbind.serialNo = self.serialNumber;
    
    DLog(@"---------------发送解绑命令 serialNumber  %d----------------",self.serialNumber);

    
    if (device.mac.length) {
        deviceUnbind.uid = device.mac;
    }else {
        deviceUnbind.uid = @"";
        DLog(@"解绑Uid 为空");

    }
    deviceUnbind.sendToServer = YES;
    DLog(@"-------------------ap 解绑 发送解绑命令--------------------------");
    sendCmd(deviceUnbind, ^(KReturnValue returnValue, NSDictionary *returnDic){
        if (returnValue == KReturnValueSuccess){
            self.serialNumber = 0;
            DLog(@"-------------------ap 解绑成功 直接发送绑定命令--------------------------");
            [HMAPConfigAPI startBindDevice];
            DLog(@"解绑成功");
            
        }else if (returnValue == KReturnValueMainframeDisconnect
                  || returnValue == KReturnValueConnectError) {
            DLog(@"解绑网络不存在，再次发送解绑命令");
            sleep(1);
            [self unBindDevice:device callback:callback];
            
        }else {
            callback(KReturnValueServerUnbindFail,returnDic);
        }
    });

}
/**
 *  绑定设备
 *
 *  @param device
 *  @param callback
 */
- (void)bindDevice:(HMAPDevice *)device callback:(BindCallback)callback {
    
    DLog(@"-----------解绑成功，开始绑定-------------");
    
    
    [self bindWifiDevice:device callback:callback];

    
    
}
- (void)bindWifiDevice:(HMAPDevice *)device callback:(BindCallback)callback {
    
    DeviceBindCmd * cmd  = [[DeviceBindCmd alloc] init];
    cmd.bindUID = device.mac ?: @"";
    cmd.ssid = [HMDeviceConfig defaultConfig].ssid;
    
    [self sendBindCmd:cmd callback:callback];

}


- (void)sendBindCmd:(DeviceBindCmd *)cmd callback:(BindCallback)callback {
    
    DLog(@"-----------解绑成功，发送绑定命令-------------");

    
    sendCmd(cmd, ^(KReturnValue returnValue, NSDictionary *returnDic) {
        callback(returnValue, returnDic);
 
    });
}

/**
 *  是否取消绑定
 *
 *  @param isStop
 */
- (void)stopBindDevice:(BOOL)isStop {
    self.isStop = isStop;
}
@end
