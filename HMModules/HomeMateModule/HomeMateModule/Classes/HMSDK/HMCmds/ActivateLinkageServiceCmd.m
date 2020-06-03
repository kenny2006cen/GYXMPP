//
//  ActivateLinkageServiceCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2017/2/21.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "ActivateLinkageServiceCmd.h"

@implementation ActivateLinkageServiceCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_LINKAGE_SERVICE_ACTIVE;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.linkageId forKey:@"linkageId"];
    [sendDic setObject:@(self.isPause) forKey:@"isPause"];
    return sendDic;
}

-(BOOL)sendToServer{

    return YES;
}

-(NSString *)uid{

    return nil;
}

-(BOOL)onlySendOnce{

    return YES;
}

@end
