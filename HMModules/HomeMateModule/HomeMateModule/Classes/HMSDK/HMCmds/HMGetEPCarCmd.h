//
//  HMGetEPCarCmd.h
//  HomeMateSDK
//
//  Created by orvibo on 2018/7/28.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface HMGetEPCarCmd : BaseCmd

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *openid;

@end
