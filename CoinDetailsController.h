//
//  CoinDetailsController.h
//  ASolanaWallet
//
//  Created by wang on 2022/10/25.
//

#import "YHBaseListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoinDetailsController : YHBaseListViewController
//@property (nonatomic,strong) NSDictionary *wallet;
//@property (nonatomic,strong) NSDictionary *walletObj;
//@property (nonatomic,strong) NSString *Balance;

@property (nonatomic,strong) NSDictionary *wallet;
@property (nonatomic,strong) NSArray *tokenList;
@property (nonatomic,assign) NSInteger WalletChain;
@property (nonatomic,strong) NSDictionary *currentWallet;

@end

NS_ASSUME_NONNULL_END
