//
//  VihomeLinkageOutput.m
//  HomeMate
//
//  Created by Air on 15/8/17.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMLinkageOutput.h"
#import "HMDevice.h"
#import "HMConstant.h"


@interface HMLinkageOutput ()

// 下面两个变量记录初始值，bindOrder 与 delayTime 记录最新值
@property (nonatomic, retain)NSString *         initialOrder;
@property (nonatomic, assign)int                initialDelayTime;

@property (nonatomic, assign)int                initialValue1;

@property (nonatomic, assign)int                initialValue2;

@property (nonatomic, assign)int                initialValue3;

@property (nonatomic, assign)int                initialValue4;


@property (nonatomic, strong) NSString *        initialActionName;

@property (nonatomic, assign) int               initialFreq;

@property (nonatomic, assign) int               initialPluseNum;

@property (nonatomic, copy) NSString *          initialPluseData;

@property (nonatomic, strong) NSArray *         initialAuthList;

@property (nonatomic, assign)BOOL               isCalledIrLearn;

/**
 *  排序的权值
 */
@property (nonatomic, readonly)NSUInteger                weightedValue;

@end


@implementation HMLinkageOutput
@synthesize isLearnedIR = isLearnedIR;

+(NSString *)tableName
{
    return @"linkageOutput";
}


+ (NSArray*)columns
{
    return @[
             column("linkageOutputId","text"),
             column("uid","text"),
             column("linkageId","text"),
             column("deviceId","text"),
             column("bindOrder","text"),
             column("value1","integer"),
             column("value2","integer"),
             column("value3","integer"),
             column("value4","integer"),
             column("actionName","text"),
             column("pluseData","text"),
             column("freq","integer"),
             column("pluseNum","integer"),
             column("themeId","text"),
             column("outPutTag","integer"),
             column("outPutTagId","text"),
             column("delayTime","integer"),
             column("outputType","integer"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","Integer")
             ];
}

+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("outPutTag","integer"), column("outPutTagId","text"),];
}

+ (NSString*)constrains
{
    return @"UNIQUE (linkageOutputId) ON CONFLICT REPLACE";
}

- (void)prepareStatement
{
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }
    if (!self.actionName) {
        self.actionName = @"-1";
    }
    if (!self.pluseData) {
        self.pluseData = @"-1";
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}

- (BOOL)deleteObject
{
    NSMutableString * sql = [NSMutableString stringWithFormat:@"delete from linkageOutput where linkageOutputId = '%@'",self.linkageOutputId];
    
    if (self.uid) {
        [sql appendFormat:@" and uid = '%@'",self.uid];
    }
    
    
    BOOL result = [self executeUpdate:sql];
    return result;
}


+ (instancetype)bindObject:(FMResultSet *)rs
{
    HMLinkageOutput * object = [HMLinkageOutput object:rs];
    [object setBindProperty:rs];
    return object;
}

+ (instancetype)bindGroupObject:(FMResultSet *)rs {
    HMLinkageOutput * object = [HMLinkageOutput object:rs];

    object.deviceId = [rs stringForColumn:@"groupId"];
    object.deviceName = [rs stringForColumn:@"groupName"];
    object.deviceType = KDeviceTypeDeviceGroup;
    object.subDeviceType = [rs intForColumn:@"groupType"];
    object.roomId = [rs stringForColumn:@"roomId"];
    object.floorRoom = floorAndRoom([HMGroup deviceFromGroupId:object.deviceId]);
    object.selected = NO;
    object.outPutTag = 1;
    object.outPutTagId = object.deviceId;
    return object;
}

- (void)setBindWithDevice:(HMDevice *)device {
    self.deviceId = device.deviceId;
    self.deviceName = device.deviceName;
    self.deviceType = device.deviceType;
    self.subDeviceType = device.subDeviceType;
    self.appDeviceId = device.appDeviceId;
    self.extAddr = device.extAddr;
    self.endPoint = device.endpoint;
    self.model = device.model;
    self.company = device.company;
    self.uid = device.uid;
    self.roomId = device.roomId;
    if (device.deviceType == KDeviceTypeHopeBackgroundMusic) {
        self.floorRoom = floorAndRoom([HMDevice objectWithUid:self.uid]);
    }else if(device.deviceType == KDeviceTypeDeviceGroup) {
        self.outPutTagId = device.deviceId;
        self.outPutTag = 1;
        self.floorRoom = floorAndRoom(device);

    }else {
        self.floorRoom = floorAndRoom([HMDevice objectWithDeviceId:self.deviceId uid:self.uid]);

    }
    
    self.selected = NO;
}

- (void)setBindWithScene:(HMScene *)scene {
    self.bindOrder = @"scene control";
    self.deviceId = scene.sceneNo;
    self.deviceName = scene.sceneName;
    self.value1 = scene.sceneId;
    self.deviceType = KDeviceTypeScene;
//    self.appDeviceId = device.appDeviceId;
//    self.extAddr = device.extAddr;
//    self.endPoint = device.endpoint;
//    self.model = device.model;
//    self.company = device.company;
    self.uid = @"";
    self.roomId = nil;
    self.floorRoom = nil;
    self.selected = NO;
}

- (void)setBindWithLinkage:(HMLinkage *)linkage {
    self.bindOrder = @"automation control";
    self.deviceId = linkage.linkageId;
    self.deviceName = linkage.linkageName;
    self.value1 = 0;
//    self.deviceType = KDeviceTypeScene;
    //    self.appDeviceId = device.appDeviceId;
    //    self.extAddr = device.extAddr;
    //    self.endPoint = device.endpoint;
    //    self.model = device.model;
    //    self.company = device.company;
    self.uid = @"";
    self.roomId = nil;
    self.floorRoom = nil;
    self.selected = NO;
}


-(void)setBindProperty:(FMResultSet *)rs
{
    self.deviceId = [rs stringForColumn:@"deviceId"];
    self.deviceName = [rs stringForColumn:@"deviceName"];
    self.deviceType = [rs intForColumn:@"deviceType"];
    self.subDeviceType = [rs intForColumn:@"subDeviceType"];
    self.appDeviceId = [rs intForColumn:@"appDeviceId"]; 
    self.extAddr = [rs stringForColumn:@"extAddr"];
    self.endPoint = [rs intForColumn:@"endPoint"];
    self.model = [rs stringForColumn:@"model"];
    self.company = [rs stringForColumn:@"company"];
    self.uid = [rs stringForColumn:@"uid"];
    self.roomId = [rs stringForColumn:@"roomId"];
   
    
    // rgb白光那路名称、房间采用rgb的
    if (self.deviceType == KDeviceTypeDimmerLight
        && [self.model isEqualToString:kChuangWeiRGBWModel]) {
        self.deviceName = [[HMDevice chuangweiRgbEndPointDeviceWithExtAddr:self.extAddr] deviceName];
       self.roomId = [[HMDevice chuangweiRgbEndPointDeviceWithExtAddr:self.extAddr] roomId];
    }else if (self.deviceType == KDeviceTypeOldDistBox && (self.endPoint != kOldDistBoxMainPoint)) { // 配电箱分控的房间Id需要从主控那里得来
        self.roomId = [[HMDevice mainDistBoxWithExtAddr:self.extAddr] roomId];
    }else if (self.deviceType == KDeviceTypeHopeBackgroundMusic) {
        self.floorRoom = floorAndRoom([HMDevice objectWithUid:self.uid]);

    } else if(self.deviceType == KDeviceTypeDeviceGroup) {
        self.outPutTag = 1;
        self.outPutTagId = self.deviceId;
    }else {
        self.floorRoom = floorAndRoom([HMDevice objectWithDeviceId:self.deviceId uid:self.uid]);
    }

    self.selected = NO;
}

+ (instancetype)deviceObject:(FMResultSet *)rs {
    HMLinkageOutput * object = [[HMLinkageOutput alloc] init];
    [object setBindProperty:rs];
    return object;
}

+ (instancetype)object:(FMResultSet *)rs {
    HMLinkageOutput *obj = [super object:rs];
    [obj copyInitialValue];
    return obj;
}

+ (instancetype)objectWithDevice:(HMDevice *)device {

    HMLinkageOutput * object = [[HMLinkageOutput alloc] init];
    [object setBindWithDevice:device];
    return object;
}

+ (instancetype)objectWithScene:(HMScene *)scene {
    HMLinkageOutput * object = [[HMLinkageOutput alloc] init];
    [object setBindWithScene:scene];
    return object;
}

+ (instancetype)objectWithLinkage:(HMLinkage *)linkage {
    HMLinkageOutput * object = [[HMLinkageOutput alloc] init];
    [object setBindWithLinkage:linkage];
    return object;
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dict
{
    HMLinkageOutput *obj = [super objectFromDictionary:dict];
    //[obj copyInitialValue];
    return obj;
}
-(void)copyInitialValue
{
    // 自定义通知
    if ([self.bindOrder isEqualToString:@"custom notification"]) {
        self.authList = [HMAuthority authorityWithObjectId:self.linkageOutputId authorityType:4 familyId:userAccout().familyId];
        return;
    }
    self.initialOrder = self.bindOrder;
    self.initialDelayTime = self.delayTime;
    self.initialValue1 = self.value1;
    self.initialValue2 = self.value2;
    self.initialValue3 = self.value3;
    self.initialValue4 = self.value4;
    self.initialFreq  = self.freq;
    self.initialPluseNum = self.pluseNum;
    self.initialPluseData = self.pluseData;
    self.initialActionName = self.actionName;
    self.initialAuthList = self.authList;
}
-(BOOL)changed
{
    
    if ([self.bindOrder isEqualToString:@"scene control"]) {// 联动输出情景 智能改延迟时间
        if (self.initialDelayTime != self.delayTime) {
            return YES;
        }else {
            return NO;
        }
    }
    
    if ((![self.initialOrder isEqualToString:self.bindOrder])       // 动作命令变化
        || (self.initialDelayTime != self.delayTime)                // 延时发生变化
        || (self.initialValue1 != self.value1)
        || (self.initialValue2 != self.value2)
        || (self.initialValue3 != self.value3)
        || (self.initialValue4 != self.value4)
            
        || (self.initialFreq != self.freq)
        || (self.initialPluseNum != self.pluseNum)
        || (![self.initialPluseData isEqualToString:self.pluseData])
        || (![self.initialActionName isEqualToString:self.actionName])
        /*|| (![self.initialAuthList isEqualToArray:self.authList])*/
        ) {
            
        return YES;
    }
    return NO;
}


- (id)copyWithZone:(NSZone *)zone
{
    HMLinkageOutput *copySelf = [[HMLinkageOutput alloc]init];
    copySelf.linkageOutputId = self.linkageOutputId;
    copySelf.uid = self.uid;
    copySelf.linkageId = self.linkageId;
    copySelf.deviceId = self.deviceId;
    copySelf.bindOrder = self.bindOrder;
    copySelf.value1 = self.value1;
    copySelf.value2 = self.value2;
    copySelf.value3 = self.value3;
    copySelf.value4 = self.value4;
    copySelf.delayTime = self.delayTime;
    copySelf.createTime = self.createTime;
    copySelf.initialOrder = self.bindOrder;
    copySelf.initialDelayTime = self.delayTime;
    copySelf.initialValue1 = self.value1;
    copySelf.initialValue2 = self.value2;
    copySelf.initialValue3 = self.value3;
    copySelf.initialValue4 = self.value4;
    
    copySelf.initialFreq  = self.freq;
    copySelf.initialPluseNum = self.pluseNum;
    copySelf.initialPluseData = self.pluseData;
    copySelf.initialActionName = self.actionName;
    
    copySelf.deviceName = self.deviceName;
    copySelf.deviceType = self.deviceType;
    copySelf.subDeviceType = self.subDeviceType;
    copySelf.floorRoom = self.floorRoom;
    copySelf.selected = self.selected;
    copySelf.appDeviceId = self.appDeviceId;
    copySelf.model = self.model;
    copySelf.company = self.company;
    copySelf.extAddr = self.extAddr;
    copySelf.endPoint = self.endPoint;
    copySelf.roomId = self.roomId;
    
    copySelf.actionName = self.actionName;
    copySelf.pluseData = self.pluseData;
    copySelf.freq = self.freq;
    copySelf.pluseNum = self.pluseNum;
    copySelf.authList = self.authList;
    copySelf.outPutTag = self.outPutTag;
    copySelf.outPutTagId = self.outPutTagId;
    return copySelf;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"name:%@ deviceId:%@ order:%@ delayTime:%d selected:%d",self.deviceName,self.deviceId,self.bindOrder,self.delayTime,self.selected];
}
- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    return dic;
}

-(void)setSelected:(BOOL)selected
{
    if (selected && self.isLearnedIR) {
        _selected = YES;
    }else{
        _selected = NO;
    }
}
-(BOOL)isLearnedIR
{
    if (self.isCalledIrLearn) {
        return isLearnedIR;
    }
    HMLinkageOutput *bind = self;
    __block BOOL _isLearnedIR = NO;
    // 在线，但是未学习过红外码，专指虚拟的红外设备
    // 小方属于 WiFi 设备，需要单独处理
    if (Allone2ModelId(bind.model)) {
        
        // 只有copy的设备需要学习
        if ([bind.company isEqualToString:@"-1"]) {
            
            NSString *sql = [NSString stringWithFormat:@"select count() as count from kkIr where deviceId = '%@' and delFlag = 0 and length(pluse) > 0",bind.deviceId];
            queryDatabase(sql, ^(FMResultSet *rs) {
                
                _isLearnedIR = ([rs intForColumn:@"count"] >0);
            });
            
        }else{
            _isLearnedIR = YES;
        }
        
    }else{
        // 在线，但是未学习过红外码，专指虚拟的红外设备
        if (bind.deviceType == KDeviceTypeAirconditioner        // 空调
            || bind.deviceType == KDeviceTypeTV                 // 电视
            || bind.deviceType == KDeviceTypeCustomerInfrared   // 自定义红外
            || bind.deviceType == KDeviceTypeSTB) {             // 机顶盒
            
            // WIFI空调不学习红外码
            if ([bind.model isEqualToString:kSkyworthModelID]
                || [bind.model isEqualToString:kWifiAirconditionerModelID]
                || bind.appDeviceId == KDeviceWifiDevice) {
                
                _isLearnedIR = YES;
                
            }else{
                
                NSString *sql = [NSString stringWithFormat:@"select count() as count from deviceIr where uid = '%@' and delFlag = 0 and deviceId = '%@'  and length(ir) > 0",bind.uid,bind.deviceId];
                
                queryDatabase(sql, ^(FMResultSet *rs) {
                    
                    _isLearnedIR = ([rs intForColumn:@"count"] >0);
                });
            }
        }else{
            // 非红外设备，将此值置为 YES ，不然会导致无法选择设备
            _isLearnedIR = YES;
        }
    }
    
    isLearnedIR =_isLearnedIR;
    
    self.isCalledIrLearn = YES;
    
    return isLearnedIR;
}


-(NSUInteger)weightedValue
{
    NSUInteger weightedValue = [orderOfDeviceType() indexOfObject:@(self.deviceType)];
    return weightedValue;
}

// 自定义通知，有权限查看的成员
-(NSString *)authMember
{
    if (self.authList) {
        NSArray *memberList = [self.authList valueForKey:@"showName"];
        NSString *authMemberString = [memberList componentsJoinedByString:(CHinese || isZh_Hant())? @"，":@","];
        return authMemberString;
    }
    return @"";
}

+ (void)deleteOutputWithDeviceId:(NSString *)deviceId
{
    if (!deviceId || [deviceId isEqualToString:@""]) {
        return ;
    }
    NSString *sql = [NSString stringWithFormat:@"delete from linkageOutput where deviceId = '%@'",deviceId];
    [self executeUpdate:sql];
}

+ (void)deleteObjectWithLinkageOutputId:(NSString *)linkageOutputId {

    NSString *sql = [NSString stringWithFormat:@"delete from linkageOutput where linkageOutputId = '%@'",linkageOutputId];
    [self executeUpdate:sql];
}

-(void)updateAuthList:(NSArray *)list
{
    self.authList = list;
    self.initialAuthList = list;
}

-(NSArray *)removeExitMemberList:(NSArray *)exitMembers
{
    NSMutableArray *exitMemberList = [@[] mutableCopy];
    if (exitMembers.count) {
        
        [exitMemberList setArray:[self.authList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId in %@",exitMembers]]];
        
        NSPredicate *moveMemberPred = [NSPredicate predicateWithFormat:@"NOT (userId in %@)",exitMembers];
        self.authList = [self.authList filteredArrayUsingPredicate:moveMemberPred];
        self.initialAuthList = [self.initialAuthList filteredArrayUsingPredicate:moveMemberPred];
    }
    
    return exitMemberList;
}

@end
