//
//  WiFiAddRFDevice.h
//  HomeMateSDK
//
//  Created by peanut on 2016/12/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "WiFiAddDevice.h"

@interface WiFiAddRFDevice : WiFiAddDevice

/**
 *  RF创建子设备命令需要这个参数，传入RF主机对应device的appDeviceId
 */
@property (nonatomic, copy) NSNumber * appDeviceId;

@end
