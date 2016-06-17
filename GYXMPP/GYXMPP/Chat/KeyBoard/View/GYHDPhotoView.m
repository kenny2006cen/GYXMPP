//
//  GYHDPhotoView.m
//  HSConsumer
//
//  Created by shiang on 16/2/4.
//  @深圳市归一科技研发有限公司_iOS
//  @版权所有  禁止传播
//  @级别：绝密
//  Copyright © 2016年 SHENZHEN GUIYI SCIENCE AND TECHNOLOGY DEVELOP CO.,LTD.
//  All rights reserved.
//

#import "GYHDPhotoCell.h"
#import "GYHDPhotoModel.h"
#import "GYHDPhotoShowView.h"
#import "GYHDPhotoView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface GYHDPhotoView ()<UICollectionViewDataSource,
                            UICollectionViewDelegate, GYHDPhotoShowViewDelegate>
/**图片展示控制器*/
@property(nonatomic, weak) UICollectionView *photoCollectionView;
/**图片统计按钮*/
@property(nonatomic, weak) UIButton *originalPhotoButton;
/**发送按钮*/
@property(nonatomic, weak) UIButton *sendPhotoButton;
/**图片统计素组*/
@property(nonatomic, strong) NSMutableArray *photoArray;
/**底部View*/
@property(nonatomic, weak) UIView *photoBottomView;
@end

@implementation GYHDPhotoView
- (NSMutableArray *)photoArray {
  if (!_photoArray) {
    _photoArray = [NSMutableArray array];
  }
  return _photoArray;
}
- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setup];
  }
  return self;
}
#pragma mark - method
- (void)setup {
  [self photoFromLibrary];

  // 1. 展示photoView
  //创建一个layout布局类
  UICollectionViewFlowLayout *layout =
      [[UICollectionViewFlowLayout alloc] init];
  //设置布局方向为垂直流布局
  layout.scrollDirection = UICollectionViewScrollDirectionVertical;
  CGFloat itemWH = (kScreenWidth - 6) / 3;
  layout.minimumLineSpacing = 2;
  layout.minimumInteritemSpacing = 2;
  //设置每个item的大小为100*100
  layout.itemSize = CGSizeMake(itemWH, itemWH);
  //创建collectionView 通过一个布局策略layout来创建
  UICollectionView *collect =
      [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
                         collectionViewLayout:layout];

    WSHD(weakSelf);
    
  //代理设置
  collect.delegate = self;
  collect.dataSource = self;
  //注册item类型 这里使用系统的类型
  [collect registerClass:[GYHDPhotoCell class]
      forCellWithReuseIdentifier:@"PhotoCellID"];
  [self addSubview:collect];
  _photoCollectionView = collect;
      collect.backgroundColor = kLightRedColor;
  collect.backgroundColor = [UIColor whiteColor];
  [collect mas_makeConstraints:^(MASConstraintMaker *make) {
    
    make.top.left.bottom.right.equalTo(weakSelf);
  }];

  UIView *photoBottomView = [[UIView alloc] init];
  photoBottomView.backgroundColor = [UIColor whiteColor];
  [self addSubview:photoBottomView];
  _photoBottomView = photoBottomView;
  photoBottomView.hidden = YES;
  [photoBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.bottom.mas_equalTo(0);
    make.height.mas_equalTo(30);
  }];
  // 原图按钮
  UIButton *originalPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
  originalPhotoButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
  originalPhotoButton.backgroundColor = [UIColor whiteColor];
  originalPhotoButton.contentHorizontalAlignment =
      UIControlContentHorizontalAlignmentLeft;
  originalPhotoButton.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
  originalPhotoButton.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
  [originalPhotoButton setTitleColor:[UIColor colorWithRed:250 / 255.0f
                                                     green:60 / 255.0f
                                                      blue:40 / 255.0f
                                                     alpha:1]
                            forState:UIControlStateNormal];
  [originalPhotoButton setTitle:@"原图" forState:UIControlStateNormal];
  [originalPhotoButton setImage:[UIImage imageNamed:@"btn_yd_n"]
                       forState:UIControlStateNormal];
  [originalPhotoButton setImage:[UIImage imageNamed:@"btn_yd_h"]
                       forState:UIControlStateSelected];
  [originalPhotoButton addTarget:self
                          action:@selector(originalButtonClick:)
                forControlEvents:UIControlEventTouchDown];
  [photoBottomView addSubview:originalPhotoButton];
  _originalPhotoButton = originalPhotoButton;
  [originalPhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(photoBottomView);
    make.size.mas_equalTo(CGSizeMake(150, 30));

  }];
  // 发送按钮
  UIButton *sendPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
  sendPhotoButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
  sendPhotoButton.backgroundColor = [UIColor whiteColor];
  sendPhotoButton.contentHorizontalAlignment =
      UIControlContentHorizontalAlignmentLeft;
  [sendPhotoButton setTitleColor:[UIColor colorWithRed:250 / 255.0f
                                                 green:60 / 255.0f
                                                  blue:40 / 255.0f
                                                 alpha:1]
                        forState:UIControlStateNormal];
  [sendPhotoButton setTitle:@"发送" forState:UIControlStateNormal];
  [sendPhotoButton addTarget:self
                      action:@selector(sendButtonClick:)
            forControlEvents:UIControlEventTouchUpInside];
  [photoBottomView addSubview:sendPhotoButton];
  _sendPhotoButton = sendPhotoButton;
  [sendPhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
    make.right.bottom.equalTo(photoBottomView);
    make.size.mas_equalTo(CGSizeMake(100, 30));

  }];
}
- (void)sendButtonClick:(UIButton *)button {
  if (self.originalPhotoButton.selected) {  // 原图发送
    for (GYHDPhotoModel *photo in self.photoArray) {
      if (photo.photoSelectStates) {
        photo.photoSelectStates = NO;

        if ([self.delegate
                respondsToSelector:@selector(GYHDKeyboardSelectBaseView:
                                                               sendDict:
                                                               SendType:)]) {
          ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
          [assetLibrary assetForURL:photo.photoOriginalImageUrl
              resultBlock:^(ALAsset *asset) {

                UIImage *image =
                    [UIImage imageWithCGImage:[[asset defaultRepresentation]
                                                  fullScreenImage]];

//                [self.delegate
//                    GYHDKeyboardSelectBaseView:self
//                                      sendDict:
//                                          [self saveImageToBoxWithImage:image]
//                                      SendType:GYHDKeyboardSelectBaseSendPhoto];
              }
              failureBlock:^(NSError *error) {

              
              }];
        }
      }
    }

  } else {  // 缩略图发送
    for (GYHDPhotoModel *photo in self.photoArray) {
      if (photo.photoSelectStates) {
        photo.photoSelectStates = NO;

        if ([self.delegate
                respondsToSelector:@selector(GYHDKeyboardSelectBaseView:
                                                               sendDict:
                                                               SendType:)]) {
          ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
          [assetLibrary assetForURL:photo.photoOriginalImageUrl
              resultBlock:^(ALAsset *asset) {

                UIImage *photoImage =
                    [UIImage imageWithCGImage:[[asset defaultRepresentation]
                                                  fullScreenImage]];
                UIImage *image = nil;
                if (photoImage.size.width > 1080 ||
                    photoImage.size.height > 1080) {
//                  image =
//                      [Utils imageCompressForWidth:photoImage targetWidth:1080];
                } else {
                  image = photoImage;
                }

//                [self.delegate
//                    GYHDKeyboardSelectBaseView:self
//                                      sendDict:
//                                          [self saveImageToBoxWithImage:image]
//                                      SendType:GYHDKeyboardSelectBaseSendPhoto];
              }
              failureBlock:^(NSError *error) {
               
                  
                  
              }];
        }
      }
    }
  }

  selectImageCount = 0;

  [self.photoCollectionView reloadData];
}
/**保存图片到沙盒*/
/*
- (NSDictionary *)saveImageToBoxWithImage:(UIImage *)image {
    
  NSData *imageData = nil;
  if (UIImageJPEGRepresentation(image, 1)) {
    imageData = UIImageJPEGRepresentation(image, 1);
  } else {
    imageData = UIImagePNGRepresentation(image);
  }
  NSInteger timeNumber =
      arc4random_uniform(1000) + [[NSDate date] timeIntervalSince1970];
  NSString *imageName =
      [NSString stringWithFormat:@"originalImage%ld.jpg", (long)timeNumber];
    
  NSString *imagePath = [NSString pathWithComponents:@[
    [[GYHDMessageCenter sharedInstance] imagefolderNameString],
    imageName
  ]];
  [imageData writeToFile:imagePath atomically:NO];

  UIImage *thumbnailsImage =
      [Utils imageCompressForWidth:image targetWidth:150];
  NSData *thumbnailsImageData = nil;
  if (UIImageJPEGRepresentation(thumbnailsImage, 1)) {
    thumbnailsImageData = UIImageJPEGRepresentation(thumbnailsImage, 1);
  } else {
    thumbnailsImageData = UIImagePNGRepresentation(thumbnailsImage);
  }

  NSString *thumbnailsImageName =
      [NSString stringWithFormat:@"thumbnailsImage%ld.jpg", (long)timeNumber];
  NSString *thumbnailsImageNamePath = [NSString pathWithComponents:@[
    [[GYHDMessageCenter sharedInstance] imagefolderNameString],
    thumbnailsImageName
  ]];
  [thumbnailsImageData writeToFile:thumbnailsImageNamePath atomically:NO];
  NSMutableDictionary *dict = [NSMutableDictionary dictionary];
  dict[@"originalName"] = imageName;
  dict[@"thumbnailsName"] = thumbnailsImageName;
  return dict;
}
*/
- (void)originalButtonClick:(UIButton *)button {
  button.selected = !button.selected;
}

/**获得系统相册所有图片*/
- (void)photoFromLibrary {
  
    WSHD(weakSelf);
    
  __block NSMutableArray *groupArrays = [NSMutableArray array];

  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // add by jianglincen 为批量获取图片增加自动释放池，避免内存溢出
        @autoreleasepool {
          ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(
              ALAssetsGroup *group, BOOL *stop) {

            if (group != nil) {
              [groupArrays addObject:group];
            } else {
              [groupArrays enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
                                                        BOOL *stop) {
                [obj enumerateAssetsUsingBlock:^(ALAsset *result,
                                                 NSUInteger index, BOOL *stop) {

                  if ([result thumbnail] != nil) {
                    // 照片
                    if ([[result valueForProperty:ALAssetPropertyType]
                            isEqualToString:ALAssetTypePhoto]) {
                     
                      UIImage *image =
                          [UIImage imageWithCGImage:[result thumbnail]];
                      //    NSString *fileName = [[result defaultRepresentation]
                      //    filename];
                      NSURL *url = [[result defaultRepresentation] url];
                      int64_t fileSize = [[result defaultRepresentation] size];

                      NSMutableDictionary *dict =
                          [NSMutableDictionary dictionary];
                      dict[@"thumbnailImage"] = image;
                      dict[@"originalImageUrl"] = url;
                      dict[@"imageSize"] = @(fileSize);
                      GYHDPhotoModel *photo =
                          [[GYHDPhotoModel alloc] initWithDict:dict];

                      [photo addObserver:self
                              forKeyPath:@"photoSelectStates"
                                 options:NSKeyValueObservingOptionNew
                                 context:NULL];
                    
                      [weakSelf.photoArray addObject:photo];
                    }
                  }
                }];
                // UI的更新记得放在主线程,要不然等子线程排队过来都不知道什么年代了,会很慢的
                dispatch_async(dispatch_get_main_queue(), ^{
                  
                  [self.photoCollectionView reloadData];
                });

              }];
            }
          };
          ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {

            NSString *errorMessage = nil;

            switch ([error code]) {
              case ALAssetsLibraryAccessUserDeniedError:
              case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"用户拒绝访问相册,请在<隐私>"
                               @"中开启";
                break;

              default:
                errorMessage = @"Reason unknown.";
                break;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
              UIAlertView *alertView =
                  [[UIAlertView alloc] initWithTitle:@"错误,无法访问!"
                                             message:errorMessage
                                            delegate:self
                                   cancelButtonTitle:@"确定"
                                   otherButtonTitles:nil, nil];
              [alertView show];
            });
          };

          ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
          [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                       usingBlock:listGroupBlock
                                     failureBlock:failureBlock];
        }
      });
}

#pragma mark - UICollectionView Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  GYHDPhotoCell *cell =
      [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCellID"
                                                forIndexPath:indexPath];
  cell.photoModel = self.photoArray[indexPath.row];
  return cell;
}
- (void)collectionView:(UICollectionView *)collectionView
    didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  GYHDPhotoModel *photoModel = self.photoArray[indexPath.row];
  GYHDPhotoShowView *photoShowView = [[GYHDPhotoShowView alloc] init];
  photoShowView.delegate = self;
  ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
  [assetLibrary assetForURL:photoModel.photoOriginalImageUrl
      resultBlock:^(ALAsset *asset) {
        [photoShowView
            setImage:[UIImage imageWithCGImage:[[asset defaultRepresentation]
                                                   fullScreenImage]]];
      }
      failureBlock:^(NSError *error) {
       
      
      }];
  [photoShowView show];
}

#pragma mark - GYHDPhotoShowViewDelegate 发送图片
- (void)GYHDPhotoShowView:(UIView *)photoShowView
            SendImageData:(NSData *)imageData {
  UIImage *image = [UIImage imageWithData:imageData];
  if ([self.delegate
          respondsToSelector:@selector(GYHDKeyboardSelectBaseView:
                                                         sendDict:
                                                         SendType:)]) {
//    [self.delegate
//        GYHDKeyboardSelectBaseView:self
//                          sendDict:[self saveImageToBoxWithImage:image]
//                          SendType:GYHDKeyboardSelectBaseSendPhoto];
  }
}

#pragma mark - KVO 监听图片选中状态
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"photoSelectStates"]) {
    NSInteger sizeCount = 0;
    NSInteger count = 0;
    for (GYHDPhotoModel *photo in self.photoArray) {
      if (photo.photoSelectStates) {
        sizeCount += photo.photoImageSize;
        count++;
      }
    }
    sizeCount = sizeCount / 1024;
    if (sizeCount) {
      self.photoBottomView.hidden = NO;
      [self.originalPhotoButton
          setTitle:[NSString stringWithFormat:@"原图 (%ldk) ", sizeCount]
          forState:UIControlStateSelected];
      [self.sendPhotoButton
          setTitle:[NSString stringWithFormat:@"发送 (%ld)", count]
          forState:UIControlStateNormal];
    } else {
      self.photoBottomView.hidden = YES;
      [self.originalPhotoButton setTitle:[NSString stringWithFormat:@"原图"]
                                forState:UIControlStateSelected];
      [self.sendPhotoButton setTitle:[NSString stringWithFormat:@"发送"]
                            forState:UIControlStateNormal];
    }
  }
}

#pragma mark - dealloc
- (void)dealloc {
  for (GYHDPhotoModel *photo in self.photoArray) {
    [photo removeObserver:self forKeyPath:@"photoSelectStates"];
  }
}
@end
