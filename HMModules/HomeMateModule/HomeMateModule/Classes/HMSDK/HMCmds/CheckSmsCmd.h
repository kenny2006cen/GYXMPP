//
//  CheckSmsCmd.h
//  Vihome
//
//  Created by Air on 15-1-29.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface CheckSmsCmd : BaseCmd

@property (nonatomic, retain)NSString * authCode;
@property (nonatomic, retain)NSString * phoneNumber;
@property (nonatomic, retain)NSString * areaCode;

@end
