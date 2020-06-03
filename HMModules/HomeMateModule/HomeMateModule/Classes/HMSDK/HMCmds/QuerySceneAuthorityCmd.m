//
//  QuerySceneAuthorityCmd.m
//  HomeMateSDK
//
//  Created by liuzhicai on 2018/3/19.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "QuerySceneAuthorityCmd.h"

@implementation QuerySceneAuthorityCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_SCENE_AUTHORITY;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    
    return sendDic;
}

@end
