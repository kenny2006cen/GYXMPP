//
//  OrviboLockAddUser.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/13.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface OrviboLockAddUserCmd : BaseCmd
@property (nonatomic, strong)NSString * extAddr;
@property (nonatomic, strong)NSString * userId;
@property (nonatomic, assign)int  authorizedId;
@property (nonatomic, strong)NSString * familyId;
@property (nonatomic, strong)NSString * name;
@property (nonatomic, assign)int userUpdateTime;
@end
