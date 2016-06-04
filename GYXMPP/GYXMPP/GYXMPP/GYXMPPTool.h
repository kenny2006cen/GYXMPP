//
//  GYXMPPTool.h
//  GYXMPP
//
//  Created by jianglincen on 16/6/4.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^HttpToolProgressBlock)(CGFloat progress);
typedef void (^HttpToolCompletionBlock)(NSError *error);

@interface GYXMPPTool : NSObject

-(void)uploadData:(NSData *)data
              url:(NSURL *)url
   progressBlock : (HttpToolProgressBlock)progressBlock
       completion:(HttpToolCompletionBlock) completionBlock;

/**
 下载数据
 */
-(void)downLoadFromURL:(NSURL *)url
        progressBlock : (HttpToolProgressBlock)progressBlock
            completion:(HttpToolCompletionBlock) completionBlock;


-(NSString *)fileSavePath:(NSString *)fileName;

@end
