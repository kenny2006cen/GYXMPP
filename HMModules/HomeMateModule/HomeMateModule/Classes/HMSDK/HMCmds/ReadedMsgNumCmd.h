//
//  ReadedMsgNumCmd.h
//  HomeMate
//
//  Created by liuzhicai on 15/8/20.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "BaseCmd.h"

@interface ReadedMsgNumCmd : BaseCmd

@property (nonatomic, assign)NSInteger num;

@property (nonatomic, copy)NSString *phoneToken;

+ (BOOL)toKenIsNull;
@end
