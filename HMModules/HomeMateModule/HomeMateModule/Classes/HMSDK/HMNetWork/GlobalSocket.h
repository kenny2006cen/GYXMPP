//
//  GlobalSocket.h
//  HomeMate
//
//  Created by Air on 15/8/14.
//  Copyright © 2017年 Air. All rights reserved.
//

#import "GCDAsyncSocket.h"


@interface GlobalSocket : GCDAsyncSocket

@property(nonatomic,strong)NSString *uid;
@property(nonatomic,strong)NSString *session;
@property(nonatomic,strong)NSString *encryptionKey;
@property(nonatomic,assign) BOOL isConnectToServer;
@property(nonatomic,assign) BOOL updateTimeStamp;

@property(nonatomic,assign) BOOL connectFailed;

@property(nonatomic,assign,readonly) BOOL timeStampExpired;

- (void)socketStartTls;

- (void)socket:(GlobalSocket *)sock didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler;

@end

@interface HMServerSocket:GlobalSocket

@end
