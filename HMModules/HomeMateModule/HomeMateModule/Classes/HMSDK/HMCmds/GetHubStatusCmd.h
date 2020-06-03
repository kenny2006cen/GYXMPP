//
//  GetHubStatusCmd.h
//  HomeMateSDK
//
//  Created by Feng on 2017/6/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface GetHubStatusCmd : BaseCmd

@property (nonatomic, copy)NSString *familyId;
@property (nonatomic, copy)NSString *userId;

@end
