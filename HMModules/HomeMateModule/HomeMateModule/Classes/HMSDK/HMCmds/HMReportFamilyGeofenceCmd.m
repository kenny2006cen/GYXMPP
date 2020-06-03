//
//  HMReportFamilyGeofenceCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2018/9/6.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMReportFamilyGeofenceCmd.h"

@implementation HMReportFamilyGeofenceCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_REPORT_FAMILY_GEOFENCE;
}

-(NSDictionary *)payload
{
    if(self.userId){
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if(self.dataList.count) {
        [sendDic setObject:self.dataList forKey:@"data"];

    }
    return sendDic;
}
@end
