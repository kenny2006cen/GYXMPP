//
//  QueryDataFromMixPadCmd.m
//  HomeMateSDK
//
//  Created by orvibo on 2019/1/5.
//  Copyright © 2019 orvibo. All rights reserved.
//

#import "QueryDataFromMixPadCmd.h"

@implementation QueryDataFromMixPadCmd

-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_FORWARD_MIXPAD_APP;
}

-(NSDictionary *)payload
{
    self.isTransparent = YES;
    [sendDic setObject:self.dataDic forKey:@"data"];
    return sendDic;
}

@end
