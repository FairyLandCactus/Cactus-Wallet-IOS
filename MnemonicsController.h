//
//  MnemonicsController.h
//  solanaWallet
//
//  Created by wang on 2021/12/2.
//  Copyright © 2021 wang. All rights reserved.
//

#import "YHBaseListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MnemonicsController : YHBaseListViewController
// 1:应用钱包 2:存储钱包
@property (nonatomic,assign) NSInteger walletType;
@property (nonatomic,assign) NSInteger walletChain;
@end

NS_ASSUME_NONNULL_END
