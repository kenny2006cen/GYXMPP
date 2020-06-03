//
//  OrviboLockEditUserCmd.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/17.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface OrviboLockEditUserCmd : BaseCmd
@property (nonatomic, strong) NSString *extAddr;
@property (nonatomic, assign) int authorizedId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *familyId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *fp1;
@property (nonatomic, strong) NSString *fp2;
@property (nonatomic, strong) NSString *fp3;
@property (nonatomic, strong) NSString *fp4;
@property (nonatomic, strong) NSString *pwd1;
@property (nonatomic, strong) NSString *pwd2;
@property (nonatomic, strong) NSString *rf1;
@property (nonatomic, strong) NSString *rf2;
@property (nonatomic, assign) int delFlag;
@property (nonatomic, assign) int userUpdateTime;

@end
