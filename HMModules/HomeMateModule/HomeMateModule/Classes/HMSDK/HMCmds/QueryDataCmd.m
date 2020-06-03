//
//  QueryData.m
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "QueryDataCmd.h"

@implementation QueryDataCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QD;
}

-(NSDictionary *)payload
{
    [sendDic setObject:@(self.LastUpdateTime) forKey:@"lastUpdateTime"];
    [sendDic setObject:self.TableName forKey:@"tableName"];
    [sendDic setObject:@(self.PageIndex) forKey:@"pageIndex"];
    [sendDic setObject:self.dataType forKey:@"dataType"];
    
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    
    if (self.extAddr) {
        [sendDic setObject:self.extAddr forKey:@"extAddr"];
    }
    
    return sendDic;
}

@end
