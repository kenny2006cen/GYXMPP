//
//  QueryFirmwareVersionCmd.h
//  HomeMateSDK
//
//  Created by Feng on 2017/12/25.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface QueryFirmwareVersionCmd : BaseCmd
@property (strong, nonatomic) NSArray *typeArr;
@property (nonatomic,copy) NSString * deviceId;
@property (nonatomic,copy) NSString * language;
@end
