//
//  SOLTransferController.h
//  solanaWallet
//
//  Created by wang on 2021/12/6.
//  Copyright © 2021 wang. All rights reserved.
//

#import "YHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SOLTransferController : YHBaseViewController
@property (nonatomic,strong) NSDictionary *wallet;
@property (nonatomic,strong) NSArray *tokenList;
@property (nonatomic,assign) NSInteger WalletChain;
@property (nonatomic,strong) NSDictionary *currentWallet;
@end

NS_ASSUME_NONNULL_END
