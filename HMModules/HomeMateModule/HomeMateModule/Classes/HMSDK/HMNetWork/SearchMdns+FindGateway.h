//
//  SearchMdns+FindGateway.h
//  HomeMate
//
//  Created by Air on 16/6/30.
//  Copyright © 2017年 Air. All rights reserved.
//
#import "SearchMdns.h"
#import "HMTypes.h"

@interface SearchMdns (Findc)

// 自动发现网关
-(void)autoFindGateway:(commonBlockWithObject)completion;

@end
