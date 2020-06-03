//
//  QueryUpdateProgressCmd.h
//  HomeMateSDK
//
//  Created by Feng on 2018/9/6.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface QueryUpdateProgressCmd : BaseCmd
@property (assign, nonatomic) int targetType;
@property (assign, nonatomic) int type;
@property (copy  , nonatomic) NSString * target;
@end
