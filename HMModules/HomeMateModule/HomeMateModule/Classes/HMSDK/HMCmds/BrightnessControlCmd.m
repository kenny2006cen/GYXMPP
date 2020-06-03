//
//  BrightnessControlCmd.m
//  HomeMate
//
//  Created by orvibo on 16/8/10.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "BrightnessControlCmd.h"

@implementation BrightnessControlCmd

- (VIHOME_CMD)cmd {

    return VIHOME_CMD_BRIGHTNESS_ADJUST;
}

- (NSDictionary *)payload {

    [sendDic setObject:self.userName forKey:@"userName"];
    [sendDic setObject:self.uid forKey:@"uid"];
    [sendDic setObject:self.deviceId forKey:@"deviceId"];
    [sendDic setObject:[NSNumber numberWithInt:self.brightness] forKey:@"brightness"];
    [sendDic setObject:[NSNumber numberWithInt:self.delayTime] forKey:@"delayTime"];
    return sendDic;
}

@end
