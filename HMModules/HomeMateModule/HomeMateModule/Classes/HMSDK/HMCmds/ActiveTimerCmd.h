//
//  ActiveTimerCmd.h
//  Vihome
//
//  Created by Ned on 3/25/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface ActiveTimerCmd : BaseCmd
//@property (nonatomic,retain)NSString * deviceId;
@property (nonatomic,retain)NSString * timingId;
@property (nonatomic,assign)int isPause;


@end
