//
//  HMQueryUserGeofenceCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2018/9/6.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "HMQueryUserGeofenceCmd.h"

@implementation HMQueryUserGeofenceCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_USER_GEOFENCE;
}

-(NSDictionary *)payload
{
    if(self.userId){
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if(self.identifier.length) {
        [sendDic setObject:self.identifier forKey:@"identifier"];
        
    }else {
        [sendDic setObject:@"" forKey:@"identifier"];

    }
    return sendDic;
}
@end
