//
//  HMProductModel.m
//  HomeMate
//
//  Created by liuzhicai on 16/1/13.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "HMProductModel.h"
#import "HMDevice.h"
#import "HMQrCodeModel.h"
#import "HMDeviceLanguage.h"
#import "HMConstant.h"

@implementation HMProductModel


+ (HMProductModel *)productModelWithQrCodeNo:(NSString *)qrCodeNo
{
    HMQrCodeModel *qrModel = [HMQrCodeModel objectwithQrCode:qrCodeNo];
    if (!qrModel) {
        return nil;
    }
    HMProductModel *pModel = [[HMProductModel alloc] init];
    pModel.imageStr = qrModel.picUrl;
    pModel.entryType = qrModel.type;
    HMDeviceLanguage *languageModel = [HMDeviceLanguage objectWithDataId:qrModel.qrCodeId];
    pModel.productName = languageModel.productName;
    pModel.manufacturer = languageModel.manufacturer;
    pModel.stepInfo = languageModel.stepInfo;
    
    // 英文环境下stepInfo为空，则去找中文的stepInfo
    if (isBlankString(pModel.stepInfo)) {
      HMDeviceLanguage *zhLanguageModel = [HMDeviceLanguage objectWithDataId:languageModel.dataId sysLanguage:@"zh"];
        pModel.stepInfo = zhLanguageModel.stepInfo;
    }
    
    return pModel;
}

+ (HMProductModel *)productModelWithModel:(NSString *)model
{
    if (!model) {
        return nil;
    }
    HMDeviceDesc *desc = [HMDeviceDesc objectWithModel:model];
    if (!desc) {
        return nil;
    }
    HMProductModel *pModel = [[HMProductModel alloc] init];
    pModel.imageStr = desc.picUrl;
    pModel.productModel = desc.productModel;
    pModel.endpointSet = desc.endpointSet;
    
    HMDeviceLanguage *languageModel = [HMDeviceLanguage objectWithDataId:desc.deviceDescId];
    pModel.productName = languageModel.productName;
    pModel.manufacturer = languageModel.manufacturer;
    
    return pModel;
}

+ (HMProductModel *)productModelWithDevice:(HMDevice *)device
{
    NSString *model = device.model;
    
    if (device.deviceType == KDeviceTypeSmokeTransducer
        || device.deviceType == KDeviceTypeCarbonMonoxideAlarm
        || device.deviceType == kDeviceTypeWaterDetector
        || device.deviceType == KDeviceTypeTemperatureSensor
        || device.deviceType == KDeviceTypeHumiditySensor
        || device.deviceType == KDeviceTypeEmergencyButton
        || device.deviceType == KDeviceTypeMagnet) {
        
        if (!isBlankString(model)) {
            
            NSArray *strArr = [model componentsSeparatedByString:@"V"];
            
            if (strArr.count >= 2) {
                model = [NSString stringWithFormat:@"%@%@",(NSString *)[strArr firstObject],@"V"];
            }
        }
        
    }
    
    
    if ([model hasPrefix:kCocoModel]) {
        model = kHanFengCocoModelId;
    }
    
     if (isBlankString(model)) {
        
        if (device.deviceType == KDeviceTypeCamera && [device.extAddr hasPrefix:@"VIEW"]) {
            model = kP2PCameraModelID;
        }else if (device.deviceType == kDeviceTypeMiniHub
                  || device.deviceType == kDeviceTypeViHCenter300) {
            model = [HMGateway objectWithUid:device.uid].model;

        }
     }
    
     HMDeviceDesc *desc = [HMDeviceDesc objectWithModel:model];
    
    if (!desc) {
        desc = [HMDeviceDesc objectWithModel:[NSString stringWithFormat:@"%d",device.appDeviceId]];
    }
    
    HMProductModel *pModel = [[HMProductModel alloc] init];
    pModel.imageStr = desc.picUrl;
    pModel.productModel = desc.productModel;
    pModel.endpointSet = desc.endpointSet;
    
    HMDeviceLanguage *languageModel = [HMDeviceLanguage objectWithDataId:desc.deviceDescId];
    pModel.productName = languageModel.productName;
    pModel.manufacturer = languageModel.manufacturer;
    
    return pModel;
}

+(NSString*)adJustDeviceModelWithDevice:(HMDevice *)device
{
    NSString *deviceModel = device.model;
    DLog(@"当前设备的device.model %@",deviceModel);
    
    if ([deviceModel hasPrefix:kCocoModel]) {
        deviceModel = kHanFengCocoModelId;
    }else if (isBlankString(deviceModel)) {
        
        if (device.deviceType == KDeviceTypeCamera && [device.extAddr hasPrefix:@"VIEW"]) {
            deviceModel = kP2PCameraModelID;
            
        }else if (device.deviceType == kDeviceTypeViHCenter300
                  || device.deviceType == kDeviceTypeMiniHub) {
            
            deviceModel = [HMGateway objectWithUid:device.uid].model;
            DLog(@"设备信息页的主机model：%@",deviceModel);
            
        }
        else {
            deviceModel = [NSString stringWithFormat:@"%d", device.appDeviceId];
        }
    }
    
    DLog(@"调整后 ===== 当前设备的 device.model = %@",deviceModel);
    
    return deviceModel;
}

// 判断是否需要下载相应设备图片
- (BOOL)isNeedToDownload {
    NSString *imageName = self.imageStr.lastPathComponent;
    UIImage *image = [UIImage imageNamed:imageName];
     NSString *path = [kImagesDir stringByAppendingPathComponent:imageName];
    if (!image && ![[NSFileManager defaultManager]fileExistsAtPath:path]) {
        return YES;
    }else {
        DLog(@"本地有图片： %@ 不需要下载",imageName);
    }
    return NO;
}

- (UIImage *)deviceImage {
    return [[self class] deviceImageWithImgStr:self.imageStr.lastPathComponent];
}

+ (UIImage *)deviceImageWithImgStr:(NSString *)imgStr
{
    NSString *imageName = imgStr;
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        image = [UIImage imageWithContentsOfFile:[kImagesDir stringByAppendingPathComponent:imageName]];
    }
    DLog(@"imgStr : %@ 设备信息无图片",imgStr);
    if (!image) {
        image = [UIImage imageNamed:@"device_500_unknowset"];
    }
    return image;
}

+ (void)downloadImageToCacheWithUrlStr:(NSString *)urlStr imgBlock:(void(^)(UIImage *image))imgBlock {
    NSString *path = [kImagesDir stringByAppendingPathComponent:urlStr.lastPathComponent];
    if (![[NSFileManager defaultManager]fileExistsAtPath:path]) {
        
        urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *url = [NSURL URLWithString:urlStr];
        executeAsync(^{
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            if (imageData) {
                [imageData writeToFile:path atomically:YES];
            }
            if (imgBlock) {
                UIImage *tmpImage = [UIImage imageWithContentsOfFile:path];
                dispatch_async(dispatch_get_main_queue(), ^{
                    imgBlock(tmpImage);
                });
                
            }
        });
        
    }else {
        
        if (imgBlock) {
            UIImage *tmpImage = [UIImage imageWithContentsOfFile:path];
            imgBlock(tmpImage);
        }
    }
}

+ (void)downloadImageToCacheWithUrlStr:(NSString *)urlStr
{
    [self downloadImageToCacheWithUrlStr:urlStr imgBlock:nil];
}

+ (void)downloadImgWithDevice:(HMDevice *)device imgBlock:(void(^)(UIImage *image))imgBlock {

    NSString *deviceModel = [self adJustDeviceModelWithDevice:device];
    HMProductModel *model = [self productModelWithModel:deviceModel];
    if (model.isNeedToDownload) {
        [self downloadImageToCacheWithUrlStr:model.imageStr imgBlock:imgBlock];
    }else {
        if (imgBlock) {
            imgBlock([self deviceImageWithImgStr:model.imageStr.lastPathComponent]);
        }
    }
}

+ (void)downloadImgWithDevice:(HMDevice *)device {
    [self downloadImgWithDevice:device imgBlock:nil];
}

@end
