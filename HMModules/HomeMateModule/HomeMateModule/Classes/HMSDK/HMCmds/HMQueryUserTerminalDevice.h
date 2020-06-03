//
//  HMQueryUserTerminalDevice.h
//  HomeMateSDK
//
//  Created by liqiang on 2018/8/30.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface HMQueryUserTerminalDevice : BaseCmd
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *familyId;
@end
