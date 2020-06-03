//
//  Gateway+Tcp.h
//  Vihome
//
//  Created by Air on 15-1-27.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "Gateway.h"

@interface Gateway (Tcp)

- (void)socketDidDisconnect:(GlobalSocket *)sock withError:(NSError *)err;

@end
