//
//  ThirdPlatfromForwardCmd.m
//  HomeMate
//
//  Created by orvibo on 2019/9/26.
//  Copyright © 2019 Air. All rights reserved.
//

#import "ThirdPlatfromForwardCmd.h"

@implementation ThirdPlatfromForwardCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_THIRD_PLATFORM;
}

-(NSDictionary *)payload
{
    if (self.request) {
        [sendDic setObject:self.request forKey:@"request"];
    }
    return sendDic;
}
@end
