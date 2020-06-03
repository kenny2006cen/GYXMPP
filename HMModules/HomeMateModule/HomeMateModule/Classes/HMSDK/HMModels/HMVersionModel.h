//
//  VersionModel.h
//  HomeMate
//
//  Created by Air on 15/8/25.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@interface HMVersionModel : HMBaseModel

@property (nonatomic,assign) NSInteger versionId;
@property (nonatomic,strong) NSString *dbVersion;

+ (BOOL)saveCurrentDbVersion;

+ (HMVersionModel *)oldVersion;


@end
