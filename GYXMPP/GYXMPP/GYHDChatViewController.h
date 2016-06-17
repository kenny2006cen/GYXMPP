//
//  GYHDChatViewController.h
//  GYXMPP
//
//  Created by User on 16/6/17.
//  Copyright © 2016年 jianglincen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GYMessage.h"

#import "GYHDVideoModel.h"
#import "GYHDVoiceModel.h"

@interface GYHDChatViewController : UIViewController

- (instancetype)initWithChatter:(NSString *)chatter isGroup:(BOOL)isGroup;

- (void)reloadData;

- (void)hideImagePicker;

#pragma mark - sendMessage Method
-(void)sendTextMessage:(NSString *)textMessage;

-(void)sendImageMessage:(UIImage *)image;

-(void)sendAudioMessage:(GYHDVoiceModel *)voice;

-(void)sendVideoMessage:(GYHDVideoModel *)video;

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address;

-(void)addMessage:(GYMessage *)message;

//- (EMMessageType)messageType;

@end
