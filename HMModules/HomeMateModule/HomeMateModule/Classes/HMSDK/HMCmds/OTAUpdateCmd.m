//
//  OTAUpdateCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2018/8/20.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "OTAUpdateCmd.h"

@implementation OTAUpdateCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_FU;
}

-(NSDictionary *)payload
{
    
    [sendDic setObject:@(self.type) forKey:@"type"];
    
    if (self.url.length) {
        [sendDic setObject:self.url forKey:@"url"];
    }
    if (self.md5.length) {
        [sendDic setObject:self.md5 forKey:@"md5"];
    }
    
    [sendDic setObject:@(self.size) forKey:@"size"];
    [sendDic setObject:@(self.isServerResponse) forKey:@"isServerResponse"];
    
    return sendDic;
}

@end
