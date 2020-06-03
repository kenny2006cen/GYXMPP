//
//  HMDeleteGroupCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2019/9/20.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "HMDeleteGroupCmd.h"

@implementation HMDeleteGroupCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_DELETE_GROUP;
}

-(NSDictionary *)payload
{
   
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if(self.groupId) {
        [sendDic setObject:self.groupId forKey:@"groupId"];
    }
    
    return sendDic;
}
@end
