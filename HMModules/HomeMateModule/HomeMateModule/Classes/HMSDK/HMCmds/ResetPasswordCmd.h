//
//  ResetPasswordCmd.h
//  CloudPlatform
//
//  Created by orvibo on 15/7/8.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface ResetPasswordCmd : BaseCmd

@property (nonatomic, copy) NSString *password;

@end
