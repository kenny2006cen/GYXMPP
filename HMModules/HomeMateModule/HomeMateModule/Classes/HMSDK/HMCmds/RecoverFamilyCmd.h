//
//  RecoverFamilyCmd.h
//  HomeMateSDK
//
//  Created by liuzhicai on 2017/12/19.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface RecoverFamilyCmd : BaseCmd

@property (nonatomic, copy)NSString * userId;
@property (nonatomic, copy)NSString * familyId;


@end
