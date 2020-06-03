//
//  ModifyHomeNameCmd.h
//  Vihome
//
//  Created by Ned on 1/26/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface ModifyHomeNameCmd : BaseCmd

@property (nonatomic, retain)NSString * homeName;
@property (nonatomic, retain)NSString * country;
@property (nonatomic, retain)NSString * countryCode;

@end
