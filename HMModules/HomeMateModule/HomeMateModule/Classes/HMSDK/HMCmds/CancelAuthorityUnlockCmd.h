//
//  CancelAuthorityUnlockCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/23.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"
@interface CancelAuthorityUnlockCmd : BaseCmd
@property(nonatomic,copy)NSString * deviceId;
@property(nonatomic,assign)int userId;

@end
