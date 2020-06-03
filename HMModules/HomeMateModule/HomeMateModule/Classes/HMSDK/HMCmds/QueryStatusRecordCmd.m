//
//  QueryStatusRecordCmd.m
//  HomeMate
//
//  Created by liuzhicai on 16/6/30.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QueryStatusRecordCmd.h"
#import "HMConstant.h"

@implementation QueryStatusRecordCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_STATUS_RECORD;
}
-(NSDictionary *)payload
{
    if (self.deviceId) {
        [sendDic setObject:self.deviceId forKey:@"deviceId"];
    }
    
    // v3.6增加familyId字段，用于验证成员是否有家庭权限（如果已经退出家庭则返回错误码）
    if (userAccout().familyId) {
        [sendDic setObject:userAccout().familyId forKey:@"familyId"];
    }
    [sendDic setObject:@(self.minSequence) forKey:@"minSequence"];
    [sendDic setObject:@(self.maxSequence) forKey:@"maxSequence"];
    [sendDic setObject:@(self.readCount) forKey:@"readCount"];
    [sendDic setObject:@(self.type) forKey:@"type"];
    return sendDic;
}

@end
