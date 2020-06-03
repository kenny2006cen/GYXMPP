//
//  HMFamily.h
//  HomeMateSDK
//
//  Created by user on 17/1/13.
//  Copyright © 2017年 orvibo. All rights reserved.

//


#import <UIKit/UIKit.h>

typedef  void(^GetLocalImage)(UIImage *  _Nonnull image);


#import "HMBaseModel+Extension.h"

@interface HMFamily : HMBaseModel

//@property (nonatomic, copy) NSString *familyId; // 父类已定义
@property (nonatomic, strong) NSString * _Nullable familyName;
@property (nonatomic, strong) NSString * _Nullable pic;
@property (nonatomic, strong) NSString * _Nonnull  creator;
@property (nonatomic, strong) NSString * _Nonnull  email;
@property (nonatomic, strong) NSString * _Nullable phone;
@property (nonatomic, strong) NSString * _Nullable userName;
@property (nonatomic, strong) NSString * _Nonnull  userId;


//家庭位置

//地理围栏
@property (nonatomic, strong) NSString * _Nullable  geofence;
//家庭位置
@property (nonatomic, strong) NSString * _Nullable  position;
//经度 服务器上已经有了longitude字段表示定时所需的经纬度，所以为了跟服务器保持一致 这里加了一个N
@property (nonatomic, assign) float   longitudeN;
//纬度
@property (nonatomic, assign) float  latotideN;

//0 非智家365（默认） 1 智家365
@property (nonatomic, assign) int  familyType;



@property (nonatomic, assign) int  showIndex;
@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, assign) int  userType;
@property (nonatomic, assign) float  radius;
+ (instancetype _Nonnull)familyWithId:(NSString *_Nonnull)familyId;
+ (instancetype _Nonnull)familyWithFamilyId:(NSString *_Nonnull)familyId userId:(NSString *_Nonnull)userId;

+ (NSMutableArray *_Nullable)familysWithUserId:(NSString *_Nonnull)userId;
+ (nullable NSMutableArray <HMFamily*>*)readAllFamilys;

+ (BOOL)updateFamilyName:(NSString *_Nonnull)familyName byFamilyId:(NSString *_Nonnull)familyId;
+ (HMFamily *_Nullable)defaultFamily;
+ (BOOL)deleteFamilyId:(NSString *_Nonnull)familyId ofUserId:(NSString *_Nonnull)userId;
+ (void )loadPicFromDataBaseWithFamily:(HMFamily *_Nonnull)family callBack:(GetLocalImage _Nonnull )localImage;

// 返回当前用户的家庭数量
+ (NSUInteger)familyCount;

@end
