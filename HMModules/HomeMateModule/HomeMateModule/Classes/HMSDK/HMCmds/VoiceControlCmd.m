//
//  VoiceControlCmd.m
//  HomeMateSDK
//
//  Created by Feng on 2017/7/31.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "VoiceControlCmd.h"

@implementation VoiceControlCmd
-(VIHOME_CMD)cmd
{
    return VIHOME_CMD_VOICE_CONTROL;
}

-(NSDictionary *)payload
{
    if (self.familyId) {
        [sendDic setObject:self.familyId forKey:@"familyId"];
    }
    if (self.token) {
        [sendDic setObject:self.token forKey:@"token"];
    }
    if (self.userId) {
        [sendDic setObject:self.userId forKey:@"userId"];
    }
    if (self.voice) {
        [sendDic setObject:self.voice forKey:@"voice"];
    }
    
    return sendDic;
}
@end
