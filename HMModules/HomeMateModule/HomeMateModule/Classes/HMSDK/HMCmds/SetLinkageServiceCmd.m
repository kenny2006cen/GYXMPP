//
//  SetLinkageServiceCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/2/14.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "SetLinkageServiceCmd.h"

@implementation SetLinkageServiceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_LINKAGE_SERVICE_SET;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.linkageId forKey:@"linkageId"];
    [sendDic setObject:@(self.type)forKey:@"type"];
    
    if (self.linkageName.length) {
        [sendDic setObject:self.linkageName forKey:@"linkageName"];
    }
    if (self.linkageConditionAddList) {
        [sendDic setObject:self.linkageConditionAddList forKey:@"linkageConditionAddList"];
    }
    if (self.linkageConditionModifyList) {
        [sendDic setObject:self.linkageConditionModifyList forKey:@"linkageConditionModifyList"];
    }
    if (self.linkageConditionDeleteList) {
        [sendDic setObject:self.linkageConditionDeleteList forKey:@"linkageConditionDeleteList"];
    }
    if (self.linkageOutputAddList) {
        [sendDic setObject:self.linkageOutputAddList forKey:@"linkageOutputAddList"];
    }
    if (self.linkageOutputModifyList) {
        [sendDic setObject:self.linkageOutputModifyList forKey:@"linkageOutputModifyList"];
    }
    if (self.linkageOutputDeleteList) {
        [sendDic setObject:self.linkageOutputDeleteList forKey:@"linkageOutputDeleteList"];
    }
    if (self.conditionRelation) {
        [sendDic setObject:self.conditionRelation forKey:@"conditionRelation"];
    }
    if (self.uid) {
        [sendDic setObject:self.uid forKey:@"uid"];
    }
    return sendDic;
}


-(BOOL)sendToServer{

    return YES;
}

-(BOOL)onlySendOnce{

    return YES;
}

@end
