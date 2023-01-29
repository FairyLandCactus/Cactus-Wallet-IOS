//
//  TransferDetailsController.h
//  ASolanaWallet
//
//  Created by wang on 2022/10/27.
//

#import "YHBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TransferDetailsController : YHBaseViewController
@property (nonatomic,strong) NSDictionary *obj;
@property (nonatomic,strong) NSDictionary *coinObj;
@property (nonatomic,assign) BOOL isTransfer;
@end

NS_ASSUME_NONNULL_END
