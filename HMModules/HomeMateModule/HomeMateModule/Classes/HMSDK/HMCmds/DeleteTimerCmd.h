//
//  DeleteTimerCmd.h
//  Vihome
//
//  Created by Ned on 3/25/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface DeleteTimerCmd : BaseCmd

@property (nonatomic,retain)NSString * deviceId;
@property (nonatomic,retain)NSString * timingId;

@end
