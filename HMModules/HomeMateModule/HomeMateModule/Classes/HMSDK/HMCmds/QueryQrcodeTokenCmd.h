//
//  QueryQrcodeTokenCmd.h
//  HomeMateSDK
//
//  Created by liuzhicai on 2018/3/27.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface QueryQrcodeTokenCmd : BaseCmd

@property (nonatomic, copy)NSString *userId;
@property (nonatomic, copy)NSString *token;

@end
