//
//  GetEmailCodeCmd.h
//  CloudPlatform
//
//  Created by orvibo on 15/6/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface GetEmailCodeCmd : BaseCmd

@property (nonatomic, copy) NSString *email;
@property (nonatomic, assign) int    type;

@end
