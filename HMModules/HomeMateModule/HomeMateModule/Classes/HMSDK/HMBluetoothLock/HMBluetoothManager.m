//
//  HMBluetoothManager.m
//  HomeMateSDK
//
//  Created by liqiang on 2017/10/24.
//  Copyright © 2017年 orvibo. All rights reserved.
//

#import "HMBluetoothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "HMBluetoothLockManager.h"

// T1蓝牙门锁serviceUUID
static NSString *const HMT1BluetoothLockSeviceUUID = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
// T1蓝牙门锁写特性UUID
static NSString *const HMT1BluetoothLockWriteCharacteristicUUID = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
// T1蓝牙门锁读特性UUID
static NSString *const HMT1BluetoothLockReadCharacteristicUUID = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E";


@interface HMBluetoothManager()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong)CBCentralManager * centerManager;
@property (nonatomic, strong)NSMutableArray * peripheralArray;
@property (nonatomic, strong)CBPeripheral * currentPeripheral;
@property (nonatomic, strong)CBCharacteristic * writeCharacteristic;
@property (nonatomic, strong)CBCharacteristic * readCharacteristic;
@property (nonatomic, assign)BOOL stopConnectBluetooth;
@property (nonatomic, assign)int connectBluetoothCount;

@end

@implementation HMBluetoothManager
- (instancetype)init {
    if (self = [super init]) {
        NSDictionary *options = @{CBCentralManagerOptionShowPowerAlertKey:@NO};
        self.centerManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
        self.peripheralArray = [NSMutableArray array];
        self.reconnectTimes = MAXRECONNECTTIMES;
    }
    return self;
}

- (void)scanPeripheralBlueMac:(NSString *)bleMac{
    DLog(@"蓝牙写数据,开始扫描门锁");
    self.reconnectTimes = MAXRECONNECTTIMES;
    [self connectToBlueTooth:bleMac];
    
}

- (void)connectToBlueTooth:(NSString *)bleMac {
    if(self.currentPeripheral.state == CBPeripheralStateConnected || self.currentPeripheral.state == CBPeripheralStateConnecting) {
        
        DLog(@"蓝牙写数据,开始扫描门锁,当前门锁已经连接,要先断开连接，再搜索");
        if(self.readCharacteristic){
            [self.currentPeripheral setNotifyValue:NO forCharacteristic:self.readCharacteristic];
        }
        if (self.currentPeripheral) {
            [self.centerManager cancelPeripheralConnection:self.currentPeripheral];
        }
        
    }
    self.bleMac = bleMac;
    self.stopConnectBluetooth = NO;
    CBUUID * UUID = [CBUUID UUIDWithString:@"0001"];
    NSArray * serviceUUIDs = [NSArray arrayWithObjects:UUID,[CBUUID UUIDWithString:HMT1BluetoothLockSeviceUUID],[CBUUID UUIDWithString:@"00000001-0000-1000-8000-00805f9b34fb"], nil];
    [self.centerManager scanForPeripheralsWithServices:serviceUUIDs options:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];//先取消之前的
    [self performSelector:@selector(cancelScanPeripheral) withObject:nil afterDelay:10];//10秒之后判断是否发现设备
}

- (void)cancelScanPeripheral {
    DLog(@"蓝牙写数据,10秒之后还没有搜到门锁，停止扫描，返回错误");
    [self.centerManager stopScan];
    [self connectBluetoothStatus:HMBluetoothStatusNotFoundDevice];
}
- (void)disconnectBluetooth {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];//先取消之前的
    self.stopConnectBluetooth = YES;
    if(self.readCharacteristic){
        [self.currentPeripheral setNotifyValue:NO forCharacteristic:self.readCharacteristic];
    }
    if (self.currentPeripheral) {
        [self.centerManager cancelPeripheralConnection:self.currentPeripheral];
    }
}

- (void)writeData:(NSData *)data {
    if(self.bluetoothOpen == NO) {
        DLog(@"蓝牙写数据，当前蓝牙状态处于非打开状态，不能发送数据");
        return;
    }
    if(self.currentPeripheral && self.writeCharacteristic){// 判断是否有写的特征值
        if(self.currentPeripheral.state == CBPeripheralStateConnected){
            DLog(@"蓝牙写数据，当前满足写数据的条件，可以发送数据");
            if (WriteBlueToothWithResponce) {
                [self.currentPeripheral writeValue:data
                                 forCharacteristic:self.writeCharacteristic
                                              type:CBCharacteristicWriteWithResponse];
            }else {
                [self.currentPeripheral writeValue:data
                                 forCharacteristic:self.writeCharacteristic
                                              type:CBCharacteristicWriteWithoutResponse];
            }
            
        }else {
            DLog(@"蓝牙写数据，当前外围没有连接，不能发送数据");
            [self connectBluetoothStatus: HMBluetoothStatusDisconnected];
        }
        
    }else {
        DLog(@"蓝牙写数据，当前外围设备为空，不能写数据");
    }
    
}

- (void)connectBluetoothStatus:(HMBluetoothStatus)status {
    if (self.delegate && [self.delegate respondsToSelector:@selector(connectBluetoothStatus:)]) {
        [self.delegate connectBluetoothStatus:status];
    }
}


#pragma mark-
#pragma mark CBCentralManager 的代理函数
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            DLog(@">>>CBCentralManagerStateUnknown");
            self.bluetoothOpen = NO;
            self.bluetoothState = HMCBManagerStateUnknown;
            break;
        case CBCentralManagerStateResetting:
            DLog(@">>>CBCentralManagerStateResetting");
            self.bluetoothOpen = NO;
            self.bluetoothState = HMCBManagerStateResetting;
            break;
        case CBCentralManagerStateUnsupported:
            DLog(@">>>CBCentralManagerStateUnsupported");
            self.bluetoothOpen = NO;
            self.bluetoothState = HMCBManagerStateUnsupported;

            break;
        case CBCentralManagerStateUnauthorized:
            DLog(@">>>CBCentralManagerStateUnauthorized");
            self.bluetoothOpen = NO;
            self.bluetoothState = HMCBManagerStateUnauthorized;

            break;
        case CBCentralManagerStatePoweredOff:
            DLog(@">>>CBCentralManagerStatePoweredOff");
            self.bluetoothOpen = NO;
            self.bluetoothState = HMCBManagerStatePoweredOff;

            break;
        case CBCentralManagerStatePoweredOn:
            DLog(@">>>CBCentralManagerStatePoweredOn");
            self.bluetoothOpen = YES;
            self.bluetoothState = HMCBManagerStatePoweredOn;
            [self connectBluetoothStatus:HMBluetoothStatusPowerOn];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_BLUETOOTH_OPEN object:nil userInfo:nil];
            break;
        default:
            break;
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSData * bleMacData = [advertisementData objectForKey:@"kCBAdvDataManufacturerData"];
    NSString * bleMacString = @"";
    if (bleMacData.length) {
        NSData * converData = [self sizeEndConversion:bleMacData];
        bleMacString = [self convertDataToHexStr:converData];
        DLog(@"搜索到peripheral %@  advertisementData %@ 当前要搜的蓝牙mac %@,搜索到的蓝牙mac地址为 %@",peripheral.name,advertisementData,self.bleMac,bleMacString);
        if (bleMacString.length > 12) {
            bleMacString = [bleMacString substringWithRange:NSMakeRange(0, 12)];
        }
    }

    if (self.bleMac == nil) {//说明是第一次搜索，搜索一个就可以了，搜索到之后，要保存一下，因为蓝牙会断掉，等断掉之后再连接还要连之前的这个
        if([peripheral.name containsString:@"DOORLOCK"]){
            self.currentPeripheral = peripheral;
            [NSObject cancelPreviousPerformRequestsWithTarget:self];//取消超时
            [self.centerManager stopScan];
            [self.centerManager connectPeripheral:self.currentPeripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
            self.bleMac = bleMacString;
            [[HMBluetoothLockManager defaultManager] setCurrentLockBleMac:bleMacString];

        }
    }else if([self.bleMac isEqualToString:bleMacString]){
        if([peripheral.name containsString:@"DOORLOCK"]){
            self.currentPeripheral = peripheral;
            [NSObject cancelPreviousPerformRequestsWithTarget:self];//取消超时
            [self.centerManager stopScan];
            [self.centerManager connectPeripheral:self.currentPeripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES}];
            self.bleMac = bleMacString;
            [[HMBluetoothLockManager defaultManager] setCurrentLockBleMac:bleMacString];
        }
    }
}

- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange,BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i =0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) &0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

- (NSData *)sizeEndConversion:(NSData *)originData {
    NSMutableData * data = [NSMutableData data];
    for (NSUInteger i = originData.length; i > 0; i--) {
        NSData * subOringinData = [originData subdataWithRange:NSMakeRange(i - 1, 1)];
         [data appendData:subOringinData];
    }
    
    return data;
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    self.currentPeripheral.delegate = self;
    DLog(@"连接服务peripheral  %@",peripheral.name);
    [self.currentPeripheral discoverServices:nil];
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    DLog(@"连接设备 %@ 失败",peripheral.name);
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    DLog(@"断开设备 %@ 的连接: %@，错误码%d",peripheral.name, [error localizedDescription],error.code);

    if(error.code == 0) {
        DLog(@"错误码是0，可以认为是主动断开，这时就不重新连接了");
        return;
    }
    
    if (self.reconnectTimes > 0) {
        DLog(@"断开设备 %@ 当前连接次数为 %d，所以要重新连接",peripheral.name,self.reconnectTimes);
        FirmwareUpdateStatus status = [HMBluetoothLockAPI firmwareUpdateStatus];
        if (status == FirmwareUpdateStatusNormal) {//不是升级过程就会重连
            DLog(@"断开设备 %@ 当前连接次数为 %d，并且当前升级状态是正常状态要重连",peripheral.name,self.reconnectTimes);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((5-self.reconnectTimes) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self connectToBlueTooth:self.bleMac];
                self.reconnectTimes--;
            });
        }else {
            if(status == FirmwareUpdateStatusTransmission){
                DLog(@"断开设备 %@ 当前连接次数为 %d，并且当前升级状态是在上传固件，发送通知提示",peripheral.name,self.reconnectTimes);
                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_T1UPLOADBLURTOOTHBREAK object:nil];
            }
            DLog(@"断开设备 %@ 当前连接次数为 %d，但是当前升级状态不是正常状态，不要重连",peripheral.name,self.reconnectTimes);
        }
    }
}


#pragma mark -
#pragma mark CBPeripheralDelegate 的代理函数

// 搜索到Service回调，在这里搜索Characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    DLog(@"搜到服务 = %@",peripheral.services);
    for (CBService * service in peripheral.services) {
        if ([service.UUID.UUIDString containsString: HMT1BluetoothLockSeviceUUID]
            ||[service.UUID.UUIDString containsString:@"1234"]) {
            [peripheral discoverCharacteristics:[NSArray arrayWithObjects:
                                                 [CBUUID UUIDWithString:HMT1BluetoothLockWriteCharacteristicUUID],
                                                 [CBUUID UUIDWithString:HMT1BluetoothLockReadCharacteristicUUID],
                                                 [CBUUID UUIDWithString:@"1235"],
                                                 [CBUUID UUIDWithString:@"1236"],
                                                 nil]
                                     forService:service];
            break;

        }
    }
}
// 搜索到Characteristics回调，在这里设置需要订阅的Characteristic和需要写的Characteristic
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    DLog(@"搜到特征值 = %@",service.characteristics);
    for (CBCharacteristic *characteristic in service.characteristics) {
        DLog(@"Discovered characteristic %@ characteristic.UUID = %@,characteristic.UUID.UUIDString = %@", characteristic,characteristic.UUID,characteristic.UUID.UUIDString);
        if ([characteristic.UUID.UUIDString containsString:HMT1BluetoothLockReadCharacteristicUUID]||[characteristic.UUID.UUIDString containsString:@"1236"]) {//找到需要订阅的Characteristic
            if (characteristic.properties & CBCharacteristicPropertyNotify ||
                characteristic.properties & CBCharacteristicPropertyIndicate) {//可以订阅
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                self.readCharacteristic = characteristic;
                DLog(@"订阅characteristic %@",characteristic.UUID.UUIDString);
            }else {// 不可以订阅
                DLog(@"此characteristic %@ 不可以订阅",characteristic.UUID.UUIDString);

            }
        }else if ([characteristic.UUID.UUIDString containsString:HMT1BluetoothLockWriteCharacteristicUUID]||
                  [characteristic.UUID.UUIDString containsString:@"1235"]) {//找到需要写的Characteristic
            if(characteristic.properties & CBCharacteristicPropertyWrite ||
               characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) {//支持写
                self.writeCharacteristic = characteristic;
                DLog(@"获取写characteristic %@",characteristic.UUID.UUIDString);
                [self connectBluetoothStatus:HMBluetoothStatusGetwriteCharacteristic];

            }else {//不支持写
                DLog(@"此characteristic %@ 不可以写",characteristic.UUID.UUIDString);

            }
            
        }else {
            DLog(@"此characteristic %@ 不需要处理",characteristic.UUID.UUIDString);

        }
    }
    
}
//订阅成功或失败的回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        DLog(@"订阅characteristic %@失败 Error changing notification state: %@",characteristic.UUID.UUIDString,[error localizedDescription]);
    }else {
        DLog(@"订阅characteristic %@成功",characteristic.UUID.UUIDString);
    }
}
//收到订阅characteristic 的数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSData *data = characteristic.value;
    if([self.delegate respondsToSelector:@selector(didUpdateValue:error:)]) {
        [self.delegate didUpdateValue:data error:error];
    }
}

//不管写成功还是失败都会回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(didWriteValueError:)]) {
        [self.delegate didWriteValueError:error];
    }
    if (error) {
        DLog(@"写characteristic %@失败 Error writing characteristic value: %@",characteristic.UUID.UUIDString,[error localizedDescription]);
    }
}

/**
 判断是否连接的是bleMac
 
 @return YES 是的 NO 不是
 */
- (BOOL)bluetoothConnectToBlueMac:(NSString *)bleMac {
    if (self.currentPeripheral) {
        if (self.currentPeripheral.state == CBPeripheralStateConnected) {
            if ([self.bleMac isEqualToString:bleMac]) {
                return YES;
            }
        }
    }
    return NO;
    
}

@end
