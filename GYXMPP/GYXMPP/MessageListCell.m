//
//  GYHDBusinessCell.m
//  company
//
//  Created by apple on 16/2/16.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD. All rights reserved.
//

#import "MessageListCell.h"
#import "GYMessage.h"

static NSString * const GYTableViewCellID = @"GYHDBusinessCell";
@interface MessageListCell()
/**
 *  用户头像
 */
@property(nonatomic, strong) UIImageView *iconImageView;
/**
 *  用户昵称
 */
@property(nonatomic, strong) UILabel *userNameLabel;
/**
 *  最后一条消息时间
 */
@property(nonatomic, strong) UILabel *lasttimeLabel;
/**
 *  消息正文
 */
@property(nonatomic, strong) UILabel *messageContentLabel;
/**
 * 未读消息
 */
@property(nonatomic, strong) UIButton *unreadMessageButton;

@end

@implementation MessageListCell

+ (instancetype)cellWithTableView:(UITableView * )tableView {
   
    MessageListCell * cell = [tableView dequeueReusableCellWithIdentifier:GYTableViewCellID];
    if (cell == nil) {
        cell = [[MessageListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:GYTableViewCellID];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) return  self;
    // 头像
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.layer.cornerRadius = 3.0f;
    [self.contentView addSubview:_iconImageView];

    // 名称
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.font = [UIFont systemFontOfSize:16.0f];
    [self.contentView addSubview:_userNameLabel];
    
    //消息
    _messageContentLabel = [[UILabel alloc] init];
    _messageContentLabel.font = [UIFont systemFontOfSize:12.0f];
    _messageContentLabel.textColor = [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1];
    [self.contentView addSubview:_messageContentLabel];
    
    //未读消息标签
    _unreadMessageButton = [[UIButton alloc] init];
    _unreadMessageButton.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    _unreadMessageButton.imageView.contentMode = UIViewContentModeCenter;
    _unreadMessageButton.userInteractionEnabled = NO;
    [self.contentView addSubview:_unreadMessageButton];
   
    [_unreadMessageButton setBackgroundImage:[UIImage imageNamed:@"icon-xxts2"] forState:UIControlStateNormal];

    _lasttimeLabel = [[UILabel alloc] init];
    _lasttimeLabel.font = [UIFont systemFontOfSize:11.0f];
    _lasttimeLabel.textColor = [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1];
    _lasttimeLabel.textAlignment = NSTextAlignmentRight;
   
    [self.contentView addSubview:_lasttimeLabel];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 67.5, 320, 0.5)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView];
   
    __block  PPDragDropBadgeView* badgeView
    = [[PPDragDropBadgeView alloc] initWithFrame:CGRectMake(kScreenWidth-40, 40, 20, 20) dragdropCompletion:^{
        NSLog(@"Drag drop done.");
        
        badgeView.text=@"";
    }];
    badgeView.text = @"6";
    
    [self.contentView addSubview:badgeView];
    
    [self setUIFrame];
  
    return self;
}

- (void)setUIFrame {
    
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44.0f, 44.0f));
        make.left.top.mas_equalTo(12.0f);
    }];
    [_lasttimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.right.mas_equalTo(-12.0f);
        make.top.equalTo(self.userNameLabel.mas_top);
        make.height.equalTo(self.iconImageView.mas_height).multipliedBy(0.5);
    }];
    [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.iconImageView);
        make.left.equalTo(self.iconImageView.mas_right).with.offset(10.0f);
        make.right.equalTo(self.lasttimeLabel.mas_left).offset(5);
        make.height.equalTo(self.iconImageView.mas_height).multipliedBy(0.5);
    }];
    [_messageContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
      
        make.left.equalTo(self.userNameLabel);
        make.bottom.equalTo(self.iconImageView.mas_bottom);
        make.height.equalTo(self.iconImageView.mas_height).multipliedBy(0.5);
        make.right.mas_equalTo(-47.0f);
    }];
//修改未读数显示大小 设置成固定大小不在随字符长度变动 zhangx
    [_unreadMessageButton mas_makeConstraints:^(MASConstraintMaker *make) {
              make.size.mas_equalTo(CGSizeMake(20.0f, 20.0f));
        make.centerX.equalTo(self.iconImageView.mas_right);
        make.centerY.equalTo(self.iconImageView.mas_top);
    }];
    
 
}

- (void)setBusinessModel:(GYMessage *)businessModel {
    _businessModel = businessModel;
    //2. 设置控件内容
 
    self.iconImageView.image =[UIImage imageNamed:@"Default-568h"];
    
    self.userNameLabel.text  = businessModel.msgFriendJid;
    
    self.lasttimeLabel.text = businessModel.msgSendTime;
   
    self.messageContentLabel.text = businessModel.msgBody;
    
    
    [self setUIFrame];
}



@end
