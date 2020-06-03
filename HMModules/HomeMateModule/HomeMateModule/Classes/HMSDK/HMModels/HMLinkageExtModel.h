//
//  HMLinkageExtModel.h
//  HomeMateSDK
//
//  Created by orvibo on 16/10/8.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMLinkageExtModel : HMBaseModel

@property (nonatomic, retain) NSString *linkageId;
@property (nonatomic, assign) int sequence;

+ (NSArray *)readAllLinkageArray;

+ (void)deleteObjectWithLinkageId:(NSString *)linkageId;

+ (HMLinkageExtModel *)objectWithLinakgeId:(NSString *)linkageId;

/**
 插入联动排序对象

 @param linkageId 联动 Id
 @param insertTail 是否插入到尾部（如果为NO，则插入到头部）
 */
- (void)insertObjectWithLinkageId:(NSString *)linkageId isInsertTail:(BOOL)insertTail;

@end
