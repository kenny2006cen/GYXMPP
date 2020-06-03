//
//  ModifySceneAuthorityCmd.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2018/3/19.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "ModifySceneAuthorityCmd.h"

@implementation ModifySceneAuthorityCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_MODIFY_SCENE_AUTHORITY;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if(self.authorityType != -1) {//新的协议修改，在dataList里添加authorityType 字段，外面不用在传
       [sendDic setObject:@(self.authorityType) forKey:@"authorityType"];
    }
    
    
    if (self.dataList) {
        [sendDic setObject:self.dataList forKey:@"dataList"];
    }
    
    return sendDic;
}

@end
