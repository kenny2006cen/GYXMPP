//
//  FirmwareVersionUploadCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2018/2/1.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "FirmwareVersionUploadCmd.h"

@implementation FirmwareVersionUploadCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_FIRMWARE_VERSION_UPLOAD;
}

-(NSDictionary *)payload
{
    if (self.hardwareVersion.length) {
        [sendDic setObject:self.hardwareVersion forKey:@"hardwareVersion"];
    }
    if (self.softwareVersion.length) {
        [sendDic setObject:self.softwareVersion forKey:@"softwareVersion"];
    }
    if (self.systemVersion.length) {
        [sendDic setObject:self.systemVersion forKey:@"systemVersion"];
    }
    if (self.coordinatorVersion.length) {
        [sendDic setObject:self.coordinatorVersion forKey:@"coordinatorVersion"];
    }
    if (self.uid.length) {
        [sendDic setObject:self.uid forKey:@"uid"];
    }
    if (self.versionID) {
        [sendDic setObject:@(self.versionID) forKey:@"versionID"];
    }
    if (self.hostUid.length) {
        [sendDic setObject:self.hostUid forKey:@"hostUid"];
    }
    return sendDic;
}
@end
