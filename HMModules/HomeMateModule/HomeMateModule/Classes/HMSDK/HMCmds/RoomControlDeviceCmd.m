//
//  RoomControlDeviceCmd.m
//  HomeMate
//
//  Created by JQ on 16/9/18.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "RoomControlDeviceCmd.h"

@implementation RoomControlDeviceCmd

- (VIHOME_CMD)cmd {
    
    return VIHOME_CMD_ROOM_CONTROL_DEVICE;
}

- (NSDictionary *)payload {
    
    if (self.userName) {
        [sendDic setObject:self.userName forKey:@"userName"];
    }
    if (self.uid) {
        [sendDic setObject:self.uid forKey:@"uid"];
    }
    if (self.roomId) {
        [sendDic setObject:self.roomId forKey:@"roomId"];
    }
    if (self.orderList) {
        [sendDic setObject:self.orderList forKey:@"orderList"];
    }
    
    return sendDic;
}



@end
