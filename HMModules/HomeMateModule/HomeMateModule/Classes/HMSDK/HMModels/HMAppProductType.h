//
//  HMAppProductType.h
//  HomeMateSDK
//
//  Created by orvibo on 2017/4/28.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel.h"

@interface HMAppProductType : HMBaseModel

@property (nonatomic, strong) NSString *productTypeId;
@property (nonatomic, strong) NSString *preProductTypeId;
@property (nonatomic, assign) int verCode;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *factoryId;
@property (nonatomic, assign) int sequence;
@property (nonatomic, assign) int level;
@property (nonatomic, strong) NSString *productNameId;
@property (nonatomic, strong) NSString *customName;
@property (nonatomic, strong) NSString *smallIconUrl;
@property (nonatomic, strong) NSString *detailIconUrl;
@property (nonatomic, strong) NSString *viewUrl;
@property (nonatomic, strong) NSString *manualUrl;




/**
 如果customName不为空 则填写customName 否则根据productNameId 去appProductTypeLanguage 表里去查
 */
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *smallIconActrueUrl;
@property (nonatomic, strong) NSString *deviceType;

@end
