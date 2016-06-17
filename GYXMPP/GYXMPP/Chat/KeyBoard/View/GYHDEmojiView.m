//
//  GYHDEmojiView.m
//  HSConsumer
//
//  Created by shiang on 16/2/24.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import "GYHDEmojiCell.h"
#import "GYHDEmojiView.h"

@interface GYHDEmojiView ()<UICollectionViewDataSource,
                            UICollectionViewDelegate>
/**表情显示View*/
@property(nonatomic, weak) UICollectionView *emojiCollectionView;
/**图像数组*/
@property(nonatomic, strong) NSMutableArray *emojiArray;
/**分页*/
@property(nonatomic, weak) UIPageControl *page;
@end

@implementation GYHDEmojiView

- (NSMutableArray *)emojiArray {
  if (!_emojiArray) {
    NSMutableArray *chlidArray = [NSMutableArray array];
    for (int z = 1; z <= 60 / 24 + 1; z++) {
      NSMutableArray *array = [NSMutableArray array];
      int k = z * 24;

      for (int i = 0; i < 8; i++) {
        for (int j = k - 24; j < k; j++) {
          if (j % 8 == i) {
            if (z == 1) {
              if (j % 23 == 0 && j != 0) {
                NSString *title = [NSString stringWithFormat:@"del"];
                [array addObject:title];
              } else {
                NSString *title = [NSString stringWithFormat:@"%03d", j + 1];
                [array addObject:title];
              }
            } else {
              if ((j - z + 1) % 23 == 0 && j != k - 24) {
                NSString *title = [NSString stringWithFormat:@"del"];
                [array addObject:title];
              } else {
                NSString *title =
                    [NSString stringWithFormat:@"%03d", j - z + 1 + 1];
                [array addObject:title];
              }
            }
          }
        }
      }
      [chlidArray addObject:array];
    }
    _emojiArray = chlidArray;
  }
  return _emojiArray;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setup];
  }
  return self;
}
- (void)setup {

    UIButton *sendButton = [[UIButton alloc] init];
  [sendButton setTitle:@"发送" forState:UIControlStateNormal];
  sendButton.backgroundColor = [UIColor colorWithRed:59.0 / 255.0
                                               green:153.0 / 255.0
                                                blue:72.0 / 255.0
                                               alpha:101];
  [sendButton addTarget:self
                 action:@selector(sendButton)
       forControlEvents:UIControlEventTouchUpInside];
  sendButton.layer.cornerRadius = 2.0;
  [self addSubview:sendButton];
  [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.bottom.mas_equalTo(-4);
    make.right.mas_equalTo(-12);
  }];

  // 2. page
  UIPageControl *page = [[UIPageControl alloc] init];
  page.numberOfPages = 3;
  page.currentPage = 0;
  page.currentPageIndicatorTintColor = kLightRedColor;
  page.pageIndicatorTintColor = [UIColor grayColor];
  [self addSubview:page];
  _page = page;
  [page mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.mas_equalTo(self);
    make.bottom.equalTo(sendButton.mas_top);
  }];

  // 1. 展示photoView
  //创建一个layout布局类

  UICollectionViewFlowLayout *layout =
      [[UICollectionViewFlowLayout alloc] init];
  //设置布局方向为垂直流布局
  layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
 
  layout.minimumLineSpacing = 0;
  layout.minimumInteritemSpacing = 0;

    CGFloat itemWH = (kScreenWidth) / 8;
    
   CGFloat itemH =  (211 - 65)/ 3;
    
    //设置每个item的大小为100*100
  layout.itemSize = CGSizeMake(itemWH, itemWH);

    if (kScreenWidth
        >320) {
        //适配6以上屏幕
    layout.itemSize = CGSizeMake(itemWH, itemH);

    }
    
    
  //创建collectionView 通过一个布局策略layout来创建
  UICollectionView *collect =
      [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
                         collectionViewLayout:layout];
  collect.pagingEnabled = YES;

  //代理设置
  collect.delegate = self;
  collect.dataSource = self;
  //注册item类型 这里使用系统的类型
  [collect registerClass:[GYHDEmojiCell class]
      forCellWithReuseIdentifier:@"emojiCellID"];
  [self addSubview:collect];
  _emojiCollectionView = collect;

  collect.backgroundColor = [UIColor whiteColor];
  [collect mas_makeConstraints:^(MASConstraintMaker *make) {

      make.top.left.right.equalTo(self);
    make.bottom.equalTo(page.mas_top).offset(10);
  }];
}
- (void)sendButton {

    if (self.delegate &&
      [self.delegate respondsToSelector:@selector(GYHDemojiVIewSendMessage)]) {
    [self.delegate GYHDemojiVIewSendMessage];
  }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  NSInteger selectInt =
      (int)scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;

    self.page.currentPage = selectInt;
}

#pragma mark - UICollectionView Delegate
- (NSInteger)numberOfSectionsInCollectionView:
    (UICollectionView *)collectionView {
  return self.emojiArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  NSArray *arrya = self.emojiArray[section];
  return arrya.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  GYHDEmojiCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:@"emojiCellID"
                                                forIndexPath:indexPath];
  NSString *title = self.emojiArray[indexPath.section][indexPath.row];
  [cell setimageName:title];
  return cell;
}
- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  NSString *imageName = self.emojiArray[indexPath.section][indexPath.row];
  if (imageName.integerValue <= 60 || [imageName isEqualToString:@"del"]) {
    if ([self.delegate
            respondsToSelector:@selector(GYHDEmojiView:selectEmojiName:)]) {
      [self.delegate GYHDEmojiView:self selectEmojiName:imageName];
    }
  }
}

@end
