//
//  HomeMateSDK.h
//  HomeMateSDK
//
//  Created by Ko Lee on 2020/5/22.
//  Copyright © 2020 KOLee. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for HomeMateSDK.
FOUNDATION_EXPORT double HomeMateSDKVersionNumber;

//! Project version string for HomeMateSDK.
FOUNDATION_EXPORT const unsigned char HomeMateSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <HomeMateSDK/PublicHeader.h>


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "HMTypes.h"
#import "HMUtil.h"
#import "HMProtocol.h"
#import "HMNotifications.h"
#import "Gateway.h"
#import "CmdModel.h"
#import "SingletonClass.h"
#import "HMConstant.h"
#import "AccountSingleton+RT.h"
#import "AccountSingleton+Widget.h"
#import "LogMacro.h"
#import "HMAPWifiInfo.h"
#import "NSObject+Save.h"
#import "NSObject+Observer.h"
#import "NSObject+Foreground.h"
#import "UIButton+EnlargeEdge.h"
#import "NSData+AES.h"
#import "getgateway.h"
#import "HMDeviceConfig.h"
#import "HMAPGetIp.h"
#import "HMProductModel.h"
#import "HMNetworkMonitor.h"
#import "RunTimeLanguage.h"
#import "BLUtility.h"
#import "HMProductModel.h"
#import "Gateway+RT.h"
#import "Gateway+Foreground.h"
#import "RemoteGateway+RT.h"

#import "HMAppFactoryConfig.h"

#import "HMAirConditionUtil.h"
#import "HMVRVAirConditionUtil.h"
#import "SearchMdns+FindGateway.h"
#import "HMCommonChannelUtil.h"

#import "HMSDK.h"
#import "HMAPDeleteDeviceProtocol.h"
#import "HMCache.h"
#import "HMAPI.h"

#import "Reachability.h"
#import "GCDAsyncUdpSocket.h"
#import "HMDatabaseManager.h"
#import "GCDAsyncSocket.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabasePool.h"
#import "NSObject+MJKeyValue.h"
#import "MJExtensionConst.h"
#import "MJProperty.h"
#import "MJPropertyType.h"

#import "NewModel.h"
