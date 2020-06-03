//
//  AlarmMuteCmd.m
//  HomeMate
//
//  Created by orvibo on 16/8/10.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "AlarmMuteCmd.h"

@implementation AlarmMuteCmd

- (VIHOME_CMD)cmd {

    return VIHOME_CMD_ALARMVOICE_QUIET;
}

- (NSDictionary *)payload {

    [sendDic setObject:self.userName forKey:@"userName"];
    [sendDic setObject:self.uid forKey:@"uid"];
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:[NSNumber numberWithInt:self.muteStatus] forKey:@"muteStatus"];
    [sendDic setObject:[NSNumber numberWithInt:self.delayTime] forKey:@"delayTime"];
    return sendDic;
}

@end
