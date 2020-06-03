//
//  QueryUserNameCmd.m
//  HomeMate
//
//  Created by orvibo on 16/7/15.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "QueryUserNameCmd.h"

@implementation QueryUserNameCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_QUERY_USERNAME;
}

-(NSDictionary *)payload
{
    [sendDic setObject:self.accessTokenList forKey:@"accessTokenList"];
    
    return sendDic;
}



@end
