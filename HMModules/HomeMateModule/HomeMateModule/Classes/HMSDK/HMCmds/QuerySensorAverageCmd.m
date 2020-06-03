//
//  QuerySensorAverageCmd.m
//  HomeMate
//
//  Created by JQ on 16/8/19.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QuerySensorAverageCmd.h"

@implementation QuerySensorAverageCmd

- (VIHOME_CMD)cmd {
    
    return VIHOME_CMD_QUERY_SENSOR_AVERAGE;
}

- (NSDictionary *)payload {
    
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    [sendDic setObject:@(self.dataType) forKey:@"dataType"];

    return sendDic;
}


@end
