//
//  VihomeDeviceIr.h
//  Vihome
//
//  Created by Air on 15-2-9.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBaseModel+Extension.h"

@class HMDevice;

@interface HMDeviceIr : HMBaseModel

@property (nonatomic, retain)NSString *     deviceIrId;

@property (nonatomic, retain)NSString *         deviceId;

@property (nonatomic, retain)NSString *         bindOrder;

@property (nonatomic, retain)NSString *         deviceAddress;

@property (nonatomic, assign)int                length;

@property (nonatomic, retain)NSString *         ir;

@property (nonatomic, retain)NSString *         keyName;

/**按键顺序*/
@property (nonatomic, assign) int sequence;

/** 临时按键顺序 */
@property (nonatomic, assign) int temporarySequence;

+ (NSArray *)getCorrespondingObjectByDevice:(HMDevice *)device;

- (BOOL)updateObjectWithDeviceID;

+ (HMDeviceIr *)getCorrespondingObjectByOrder:(NSString *)order device:(HMDevice *)device;

+ (int)getMaxInfraredOrderByUID:(NSString *)UID deviceID:(NSString *)deviceID;

-(BOOL)sequenceChanged;

-(void)saveChangedSequence:(BOOL)save;

@end
