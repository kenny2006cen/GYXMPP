//
//  HMQueryUserGeofenceCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2018/9/6.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface HMQueryUserGeofenceCmd : BaseCmd
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *identifier;
@end
