//
//  UpdateGatewayPassword.h
//  HomeMateSDK
//
//  Created by liqiang on 2017/12/11.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface UpdateGatewayPassword : BaseCmd
@property (nonatomic, strong)NSString * password;
@property (nonatomic, strong)NSString * blueExtAddr;
@end
