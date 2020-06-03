//
//  QueryUserGatewayBindCmd.h
//  HomeMateSDK
//
//  Created by orvibo on 2018/1/20.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface QueryUserGatewayBindCmd : BaseCmd

@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *familyId;

@end
