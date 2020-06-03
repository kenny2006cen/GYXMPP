//
//  OrviboLockQueryBindingCmd.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/7.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "OrviboLockQueryBindingCmd.h"

@implementation OrviboLockQueryBindingCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_ORVIBO_LOCK_QUERY_BINDING;
}

-(NSDictionary *)payload
{
    
    return sendDic;
}
@end
