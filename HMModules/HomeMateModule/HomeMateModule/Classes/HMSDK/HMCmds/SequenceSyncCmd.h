//
//  SequenceSyncCmd.h
//  HomeMateSDK
//
//  Created by orvibo on 2017/12/18.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "BaseCmd.h"

@interface SequenceSyncCmd : BaseCmd

@property (nonatomic, copy) NSString *tableName;

// 跟父类中的data属性冲突，故使用dataList代替data
//@property (nonatomic, strong) NSArray *data;

@property (nonatomic, strong) NSArray *dataList;

@end
