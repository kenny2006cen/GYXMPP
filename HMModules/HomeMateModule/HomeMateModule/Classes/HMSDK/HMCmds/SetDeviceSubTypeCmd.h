//
//  SetDeviceSubTypeCmd.h
//  HomeMateSDK
//
//  Created by Feng on 2017/3/10.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface SetDeviceSubTypeCmd : BaseCmd

@property (nonatomic, strong)NSString * deviceId;
@property (nonatomic, assign)int subDeviceType;

@end
