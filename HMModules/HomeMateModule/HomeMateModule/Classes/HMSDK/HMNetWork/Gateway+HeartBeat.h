//
//  Gateway+HeartBeat.h
//  Vihome
//
//  Created by Air on 15-3-16.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "Gateway.h"

@interface Gateway (HeartBeat)

-(void)beginSendHeartbeat;
-(void)stopHeartbeat;

@end
