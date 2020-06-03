//
//  QueryRoomAuthority.h
//  HomeMateSDK
//
//  Created by peanut on 2017/6/20.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface QueryRoomAuthorityCmd : BaseCmd
/**
 familyId和userId必填
 */
@property (nonatomic, copy) NSString * familyId;
@property (nonatomic, copy) NSString * userId;

@end
