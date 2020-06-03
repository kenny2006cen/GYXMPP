//
//  HMGroupStatus.m
//  HomeMateSDK
//
//  Created by Feng on 2019/9/27.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMGroupStatus.h"
#import "HMDevice.h"
#import "HMGroupMember.h"

@implementation HMGroupStatus

+ (HMGroupStatus *)groupStatusForGroupDeviceId:(NSString *)deviceId {
    
    HMDevice * device = [[HMDevice alloc] init];
    device.deviceId = deviceId;
    
    return [self groupStatusForGroupDevice:device];
}

+ (HMGroupStatus *)groupStatusForGroupDevice:(HMDevice *)device {
    
    NSArray <HMDeviceStatus *> * statusArray = [HMGroupMember groupMemberStatusForGroupId:device.deviceId];
    //在线并且开
    NSPredicate * pre1 = [NSPredicate predicateWithFormat:@"self.online = 1 and self.value1 = 0"];
    NSArray * openOnlineArray = [statusArray filteredArrayUsingPredicate:pre1];
    
    //在线并且关
    NSPredicate * pre2 = [NSPredicate predicateWithFormat:@"self.online = 1 and self.value1 = 1"];
    NSArray * closeOnlineArray = [statusArray filteredArrayUsingPredicate:pre2];
    
    //离线
    NSPredicate * pre3 = [NSPredicate predicateWithFormat:@"self.online = 0"];
    NSArray * offlineArray = [statusArray filteredArrayUsingPredicate:pre3];
    
    HMGroupStatus * groupStatus = [[HMGroupStatus alloc] init];

    HMDeviceStatus * status = [HMDeviceStatus objectWithDeviceId:device.deviceId uid:nil];
    if (status) {
        groupStatus.deviceId = status.deviceId;
        groupStatus.value1 = status.value1;
        groupStatus.value2 = status.value2;
        groupStatus.value3 = status.value3;
        groupStatus.value4 = status.value4;
        groupStatus.statusId = status.statusId;
    }else {
        groupStatus.statusId = device.deviceId;
        groupStatus.deviceId = device.deviceId;
        groupStatus.value2 = 128;
        groupStatus.value3 = 262;
    }
    if (openOnlineArray.count) {
        groupStatus.online = 1;
        groupStatus.value1 = 0;
    }else if(closeOnlineArray.count) {
        groupStatus.online = 1;
        groupStatus.value1 = 1;
    }else if(offlineArray.count) {
        groupStatus.online = 0;
        pre1 = [NSPredicate predicateWithFormat:@"self.value1 = 0"];
        NSArray * openOnlineArray = [statusArray filteredArrayUsingPredicate:pre1];
        if(openOnlineArray.count) {
            groupStatus.value1 = 0;
        }else {
            groupStatus.value1 = 1;
        }
        
    }
    
    return groupStatus;
    
}

@end
