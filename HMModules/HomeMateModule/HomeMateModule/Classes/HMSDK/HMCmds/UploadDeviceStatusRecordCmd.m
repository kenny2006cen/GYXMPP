//
//  uploadDeviceStatusRecord.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "UploadDeviceStatusRecordCmd.h"

@implementation UploadDeviceStatusRecordCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ORVIBO_UPLOAD_DEVICE_STATUS;
}
-(NSDictionary *)payload
{
    if (self.uploadDeviceId.length) {
        [sendDic setObject:self.uploadDeviceId forKey:@"deviceId"];
    }
    
    [sendDic setObject:@(self.uploadDeviceType) forKey:@"deviceType"];
    [sendDic setObject:@(self.uploadTPage) forKey:@"tPage"];
    [sendDic setObject:@(self.uploadPageIndex) forKey:@"pageIndex"];
    [sendDic setObject:@(self.uploadCount) forKey:@"count"];

    if (self.allList) {
        [sendDic setObject:self.allList forKey:@"allList"];
    }
    
    
    return sendDic;
}
@end
