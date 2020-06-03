//
//  SearchFamilyInLanCmd.h
//  HomeMateSDK
//
//  Created by peanut on 2017/6/14.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

/**
 局域网搜索家庭
 */
@interface SearchFamilyInLanCmd : BaseCmd

/**
 客户端搜索到主机的uid，搜索不到主机的话带空值
 (必填)
 */
@property (nonatomic, strong) NSArray <NSString *>*uidList;
@end
