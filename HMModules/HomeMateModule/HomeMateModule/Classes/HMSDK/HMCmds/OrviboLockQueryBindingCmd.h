//
//  OrviboLockQueryBindingCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/7.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface OrviboLockQueryBindingCmd : BaseCmd
//针对T1门锁是蓝牙mac地址
@property(nonatomic,strong)NSString * extAddr;
@end
