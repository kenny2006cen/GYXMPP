//
//  QueryFamilyDevicesFirmwareVersionCmd.h
//  HomeMateSDK
//
//  Created by Feng on 2018/9/6.
//  Copyright © 2018年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface QueryFamilyDevicesFirmwareVersionCmd : BaseCmd
@property (copy  , nonatomic) NSString * familyId;
@property (strong, nonatomic) NSArray  * deviceVersionArray;
@end
