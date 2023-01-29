//
//  CollectionCoinController.h
//  solanaWallet
//
//  Created by wang on 2021/12/3.
//  Copyright © 2021 wang. All rights reserved.
//

#import "YHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CollectionCoinController : YHBaseViewController
@property (nonatomic,strong) NSDictionary *wallet;
@property (nonatomic,strong) NSDictionary *currentWallet;
@property (nonatomic,assign) NSInteger WalletChain;
@end

NS_ASSUME_NONNULL_END
