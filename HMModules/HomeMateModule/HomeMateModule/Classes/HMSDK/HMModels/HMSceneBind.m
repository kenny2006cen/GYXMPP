//
//  VihomeSceneBind.m
//  Vihome
//
//  Created by Ned on 1/16/15.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMSceneBind.h"


@interface HMSceneBind ()

// 下面两个变量记录初始值，bindOrder 与 delayTime 记录最新值
@property (nonatomic, retain)NSString *         initialOrder;
@property (nonatomic, assign)int                initialDelayTime;

@property (nonatomic, assign)int                initialValue1;

@property (nonatomic, assign)int                initialValue2;

@property (nonatomic, assign)int                initialValue3;

@property (nonatomic, assign)int                initialValue4;

@property (nonatomic, assign)BOOL               isCalledIrLearn;

@property (nonatomic, assign) int               initialFreq;

@property (nonatomic, assign) int               initialPluseNum;

@property (nonatomic, copy) NSString *          initialPluseData;

@property (nonatomic, strong) NSString *         initialActionName;

@property (nonatomic, strong) NSArray *         initialAuthList;

@end
@implementation HMSceneBind
@synthesize isLearnedIR = isLearnedIR;

+(NSString *)tableName
{
    return @"sceneBind";
}

+ (NSArray*)columns
{
    return @[
             
             column("sceneBindId","text"),
             column("uid","text"),
             column("sceneNo","text"),
             column("deviceId","text"),
             column("bindOrder","text"),
             column("value1","integer"),
             column("value2","integer"),
             column("value3","integer"),
             column("value4","integer"),
             column("delayTime","integer"),
             column("freq","integer"),
             column("pluseNum","integer"),
             column("pluseData","text"),
             column("actionName","text"),
             column("themeId","text"),
             column("sceneBindTag","integer"),
             column("sceneBindTagId","text"),
             column("createTime","text"),
             column("updateTime","text"),
             column("delFlag","integer")
             ];
}

+ (NSArray<NSDictionary *>*)newColumns {
    return  @[column("sceneBindTag","integer"),column("sceneBindTagId","text"),];
}

+ (NSString*)constrains
{
    return @"UNIQUE (sceneBindId, uid) ON CONFLICT REPLACE";
}


- (void)prepareStatement
{
    if (!self.createTime) {
        self.createTime = self.updateTime;
    }
    if (!self.pluseData) {
        self.pluseData = @"";
    }
    if (!self.actionName) {
        self.actionName = @"";
    }
}

-(void)setInsertWithDb:(FMDatabase *)db
{
    [self insertModel:db];
}



- (BOOL)deleteObject
{
    NSString * sql = [NSString stringWithFormat:@"delete from sceneBind where sceneBindId = '%@' and uid = '%@'",self.sceneBindId,self.uid];
    BOOL result = [self executeUpdate:sql];
    return result;
}

- (NSMutableDictionary *)dictionWithSceneBindObject
{
    NSMutableDictionary * sceneBindDic = [[NSMutableDictionary alloc] init];
    [sceneBindDic setObject:self.sceneNo forKey:@"sceneId"];
    [sceneBindDic setObject:self.deviceId forKey:@"deviceId"];
    [sceneBindDic setObject:self.bindOrder forKey:@"order"];
    if (self.actionName) {
        [sceneBindDic setObject:self.actionName forKey:@"order"];
    }
    [sceneBindDic setObject:[NSNumber numberWithInt:self.value1] forKey:@"value1"];
    [sceneBindDic setObject:[NSNumber numberWithInt:self.value2] forKey:@"value2"];
    [sceneBindDic setObject:[NSNumber numberWithInt:self.value3] forKey:@"value3"];
    [sceneBindDic setObject:[NSNumber numberWithInt:self.value4] forKey:@"value4"];
    [sceneBindDic setObject:[NSNumber numberWithInt:self.delayTime] forKey:@"delayTime"];

    
    return sceneBindDic;
}


+ (instancetype)bindObject:(FMResultSet *)rs
{
    HMSceneBind * object = [HMSceneBind object:rs];
    [object setBindProperty:rs];
    return object;
}

+ (instancetype)bindGroupObject:(FMResultSet *)rs {
    HMSceneBind * object = [HMSceneBind object:rs];

    object.deviceId = [rs stringForColumn:@"groupId"];
    object.deviceName = [rs stringForColumn:@"groupName"];
    object.deviceType = KDeviceTypeDeviceGroup;
    object.subDeviceType = [rs intForColumn:@"groupType"];
    object.roomId = [rs stringForColumn:@"roomId"];
    object.floorRoom = floorAndRoom([HMGroup deviceFromGroupId:object.deviceId]);
    object.selected = NO;
    object.sceneBindTag = 1;
    object.sceneBindTagId = object.deviceId;
    return object;
}

-(void)setBindProperty:(FMResultSet *)rs
{
    self.deviceId = [rs stringForColumn:@"deviceId"];
    self.deviceName = [rs stringForColumn:@"deviceName"];
    self.deviceType = [rs intForColumn:@"deviceType"];
    self.subDeviceType = [rs intForColumn:@"subDeviceType"];
    self.endPoint = [rs intForColumn:@"endPoint"];
    self.extAddr = [rs stringForColumn:@"extAddr"];
    self.appDeviceId = [rs intForColumn:@"appDeviceId"];
    self.model = [rs stringForColumn:@"model"];
    self.company = [rs stringForColumn:@"company"];
    self.uid = [rs stringForColumn:@"uid"];
    self.roomId = [rs stringForColumn:@"roomId"];
    self.sceneBindTag = [rs intForColumn:@"sceneBindTag"];
    self.sceneBindTagId = [rs stringForColumn:@"sceneBindTagId"];
    if (self.deviceType == KDeviceTypeHopeBackgroundMusic) {
        self.floorRoom = floorAndRoom([HMDevice objectWithUid:self.uid]);
    }else if(self.deviceType == KDeviceTypeDeviceGroup) {
         self.sceneBindTag = 1;
         self.sceneBindTagId = self.deviceId;
    } else {
        self.floorRoom = floorAndRoom([HMDevice objectWithDeviceId:self.deviceId uid:self.uid]);
    }
    self.selected = NO;

}

+ (instancetype)deviceObject:(FMResultSet *)rs
{
    HMSceneBind * object = [[HMSceneBind alloc] init];
    
    [object setBindProperty:rs];
    
    return object;
}

+ (instancetype)objectWithDevice:(HMDevice *)device {

    HMSceneBind * object = [[HMSceneBind alloc] init];
    [object setBindWithDevice:device];
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
    self.irDeviceId = device.irDeviceId;

    // 配电箱分控的房间Id需要从主控那里得来
    if (self.deviceType == KDeviceTypeOldDistBox && (self.endPoint !=kOldDistBoxMainPoint)) {
        self.roomId = [[HMDevice mainDistBoxWithExtAddr:self.extAddr] roomId];
    }

    // rgb白光那路名称、房间采用rgb的
    if (self.deviceType == KDeviceTypeDimmerLight
        && [self.model isEqualToString:kChuangWeiRGBWModel]) {
        self.deviceName = [[HMDevice chuangweiRgbEndPointDeviceWithExtAddr:self.extAddr] deviceName];

        self.roomId = [[HMDevice chuangweiRgbEndPointDeviceWithExtAddr:self.extAddr] roomId];
    }else if (self.deviceType == KDeviceTypeHopeBackgroundMusic) {
        self.floorRoom = floorAndRoom([HMDevice objectWithUid:self.uid]);

    }else if(device.deviceType == KDeviceTypeDeviceGroup) {
        self.sceneBindTagId = device.deviceId;
        self.sceneBindTag = 1;
        self.floorRoom = floorAndRoom(device);

    } else {
        self.floorRoom = floorAndRoom([HMDevice objectWithDeviceId:self.deviceId uid:self.uid]);

    }

    self.selected = NO;
}

+ (instancetype)objectWithLinkageOutput:(HMLinkageOutput *)output {
    HMSceneBind * object = [[HMSceneBind alloc] init];
    [object setBindWithLinkageOutput:output];
    return object;
}

- (void)setBindWithLinkageOutput:(HMLinkageOutput *)output {
    self.deviceId = output.deviceId;
    self.deviceType = output.deviceType;
    self.endPoint = output.endPoint;
    self.extAddr = output.extAddr;
    self.appDeviceId = output.appDeviceId;
    self.model = output.model;
    self.company = output.company;
    self.uid = output.uid;
    self.roomId = output.roomId;
    self.actionName = output.deviceName;
    self.deviceName = output.deviceName;
    self.floorRoom = output.floorRoom;
    self.sceneBindId = output.linkageOutputId;
    self.selected = output.selected;
    self.value1 = output.value1;
    self.value2 = output.value2;
    self.value3 = output.value3;
    self.value4 = output.value4;
    self.bindOrder = output.bindOrder;
    self.authList = output.authList;
    self.sceneBindTag = output.outPutTag;
    self.sceneBindId = output.outPutTagId;
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

+ (instancetype)objectWithUID:(NSString *)uid deviceID:(NSString *)deviceId
{
    NSString *sql;
    if (uid) {
        sql = [NSString stringWithFormat:@"select * from device where deviceId = '%@' and uid = '%@'",deviceId,uid];
    } else {
        sql = [NSString stringWithFormat:@"select * from device where deviceId = '%@'",deviceId];
    }
    
    FMResultSet * rs = [self executeQuery:sql];
    
    if([rs next])
    {
        HMSceneBind *object = [HMSceneBind deviceObject:rs];
        
        [rs close];
        
        return object;
    }
    [rs close];
    
    return nil;
}
+ (instancetype)object:(FMResultSet *)rs
{
    HMSceneBind *obj = [super object:rs];
    [obj copyInitialValue];
    return obj;
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dict
{
    HMSceneBind *obj = [super objectFromDictionary:dict];
    //[obj copyInitialValue];
    return obj;
}

- (NSDictionary *)dictionaryFromObject
{
    NSMutableDictionary * dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:self.sceneBindId forKey:@"sceneBindId"];
    [dic setObject:self.uid forKey:@"uid"];
    [dic setObject:self.sceneNo forKey:@"sceneNo"];
    [dic setObject:self.deviceId forKey:@"deviceId"];
    [dic setObject:self.bindOrder forKey:@"order"];
    [dic setObject:[NSNumber numberWithInt:self.value1] forKey:@"value1"];
    [dic setObject:[NSNumber numberWithInt:self.value2] forKey:@"value2"];
    [dic setObject:[NSNumber numberWithInt:self.value3] forKey:@"value3"];
    [dic setObject:[NSNumber numberWithInt:self.value4] forKey:@"value4"];
    [dic setObject:[NSNumber numberWithInt:self.delayTime] forKey:@"delayTime"];
    [dic setObject:self.createTime forKey:@"createTime"];
    [dic setObject:self.updateTime forKey:@"updateTime"];
    [dic setObject:[NSNumber numberWithInt:self.delFlag] forKey:@"delFlag"];
    if (self.actionName) {
        [dic setObject:self.actionName forKey:@"actionName"];
    }
    return dic;
}

- (id)copyWithZone:(NSZone *)zone
{
    HMSceneBind *object = [[HMSceneBind alloc]init];
    
    object.sceneBindId = self.sceneBindId;
    object.uid = self.uid;
    object.sceneNo = self.sceneNo;
    object.deviceId = self.deviceId;
    object.bindOrder = self.bindOrder;
    object.value1 = self.value1;
    object.value2 = self.value2;
    object.value3 = self.value3;
    object.value4 = self.value4;
    object.delayTime = self.delayTime;
    object.updateTime = self.updateTime;
    object.delFlag = self.delFlag;
    
    object.initialOrder = self.bindOrder;
    object.initialDelayTime = self.delayTime;
    object.initialValue1 = self.value1;
    object.initialValue2 = self.value2;
    object.initialValue3 = self.value3;
    object.initialValue4 = self.value4;

    object.deviceName = self.deviceName;
    object.deviceType = self.deviceType;
    object.subDeviceType = self.subDeviceType;
    object.endPoint = self.endPoint;
    object.floorRoom = self.floorRoom;
    object.selected = self.selected;
    object.model = self.model;
    object.company = self.company;
    object.extAddr = self.extAddr;
    object.appDeviceId = self.appDeviceId;
    object.roomId = self.roomId;

    object.pluseData = self.pluseData;
    object.freq = self.freq;
    object.pluseNum = self.pluseNum;
    object.actionName = self.actionName;
    object.themeId = self.themeId;
    object.authList = self.authList;

    return object;
}
-(void)copyObj:(HMSceneBind *)obj
{
    self.bindOrder = obj.bindOrder;
    self.value1 = obj.value1;
    self.value2 = obj.value2;
    self.value3 = obj.value3;
    self.value4 = obj.value4;
    self.pluseData = obj.pluseData;
    self.freq = obj.freq;
    self.pluseNum = obj.pluseNum;
    self.actionName = obj.actionName;
    self.authList = obj.authList;
}

-(void)copyInitialValue
{
    // 自定义通知
    if ([self.bindOrder isEqualToString:@"custom notification"]) {
        self.authList = [HMAuthority authorityWithObjectId:self.sceneBindId authorityType:3 familyId:userAccout().familyId];
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

-(BOOL)changed
{
    if ((![self.initialOrder isEqualToString:self.bindOrder])       // 动作命令变化
        || (self.initialDelayTime != self.delayTime)
        || (self.initialValue1 != self.value1)
        || (self.initialValue2 != self.value2)
        || (self.initialValue3 != self.value3)
        || (self.initialValue4 != self.value4)
        || (self.initialFreq != self.freq)
        || (self.initialPluseNum != self.pluseNum)
        || (![self.initialPluseData isEqualToString:self.pluseData])
        /*|| (![self.initialAuthList isEqualToArray:self.authList])*/
        ){
        return YES;
    }
    return NO;
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
    HMSceneBind *bind = self;
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

-(NSString *)description
{
        return [NSString stringWithFormat:@"name:%@ uid:%@ deviceId:%@ order:%@ delayTime:%d selected:%d",self.deviceName,self.uid,self.deviceId,self.bindOrder,self.delayTime,self.selected];
}

@end
