//
//  HMBluetoothCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBluetoothCmd.h"

@implementation HMBluetoothCmd
- (instancetype)init {
    if (self = [super init]) {
        self.serial = [BLUtility getRandomNumber:0 to:10000];//0~2^16的随机数（协议有2字节，所以最大为2^16）
        self.frameCommand = 0;
        self.ACKFlag = 0;
        self.ACKRequire = 1;
        self.EncryptKey = 1;
        self.timeoutSeconds = 5;
        self.retransmissionTimes = MaxRetransmissionTimes;
    }
    return self;
}

@end
