//
//  VoiceEndCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2017/7/31.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "VoiceEndCmd.h"

@implementation VoiceEndCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_END_VOICE_CONTROL;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.token) {
        [sendDic setObject:self.token forKey:@"token"];
    }

    return sendDic;
}
@end
