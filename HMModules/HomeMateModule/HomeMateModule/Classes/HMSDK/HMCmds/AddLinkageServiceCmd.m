//
//  AddLinkageServiceCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/2/9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "AddLinkageServiceCmd.h"

#import "HMLinkage.h"

@implementation AddLinkageServiceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_LINKAGE_SERVICE_CREATE;
}

-(BOOL)sendToServer{

    return YES;
}

-(BOOL)onlySendOnce{

    return YES;
}

- (NSDictionary *)payload {

    if(self.linkageName.length){
        [sendDic setObject:self.linkageName forKey:@"linkageName"];
    }
    if (self.linkageConditionList.count) {
        [sendDic setObject:self.linkageConditionList forKey:@"linkageConditionList"];
    }
    if (self.linkageOutputList.count) {
        [sendDic setObject:self.linkageOutputList forKey:@"linkageOutputList"];
    }
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.conditionRelation) {
        [sendDic setObject:self.conditionRelation forKey:@"conditionRelation"];
    }
    
    [sendDic setObject:@(self.type) forKey:@"type"];
    if (self.type == HMLinakgeTypeVoice) {
        [sendDic setObject:@(self.mode) forKey:@"mode"];
    }

    return sendDic;
}

@end
