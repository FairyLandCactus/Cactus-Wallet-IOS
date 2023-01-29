//
//  VerificationMnemonicsController.h
//  solanaWallet
//
//  Created by wang on 2021/12/2.
//  Copyright © 2021 wang. All rights reserved.
//

#import "YHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VerificationMnemonicsController : YHBaseViewController
@property (nonatomic,strong) NSArray *words;
@property (nonatomic,strong) NSDictionary *walletObj;
@property (nonatomic,assign) NSInteger walletChain;
// 1:应用钱包 2:存储钱包
@property (nonatomic,assign) NSInteger walletType;

@end

NS_ASSUME_NONNULL_END
