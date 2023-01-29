//
//  SOLTransferController.m
//  solanaWallet
//
//  Created by wang on 2021/12/6.
//  Copyright © 2021 wang. All rights reserved.
//

#import "SOLTransferController.h"
#import "SelectCoinView.h"

#import "ASolanaWallet-Swift.h"
@interface SOLTransferController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *bgView1;
@property (weak, nonatomic) IBOutlet UIView *bgView2;
@property (weak, nonatomic) IBOutlet UIView *bgView3;

@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *coinNumb;
@property (weak, nonatomic) IBOutlet UITextField *memo;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
//选择
@property (weak, nonatomic) IBOutlet UIButton *selectCoin;
@property (weak, nonatomic) IBOutlet UILabel *token;
@property (weak, nonatomic) IBOutlet UIImageView *tokenImg;

@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *addressBtn;

@property (weak, nonatomic) IBOutlet UILabel *addressTitle;
@property (weak, nonatomic) IBOutlet UILabel *numTitle;
@property (weak, nonatomic) IBOutlet UILabel *momeTitle;
//可用数量
@property (weak, nonatomic) IBOutlet UILabel *availableNum;

@property (weak, nonatomic) IBOutlet UILabel *line1;
@property (weak, nonatomic) IBOutlet UILabel *line2;
@property (weak, nonatomic) IBOutlet UILabel *tokenTitle;
@property (nonatomic,strong) OCBridgeSwift *pair;
@property (nonatomic,strong) NSString *money ;
@end

@implementation SOLTransferController

- (void)dealloc{
    notification_remove(self, @"SendBNBResults", nil);
    notification_remove(self, @"sendBNBTokenResults", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTransferInfo];
    [self setSubViewColor];
    
   
    notification_add(self, @selector(sendBNBResults:), @"SendBNBResults", nil);
    notification_add(self, @selector(sendBNBResults:), @"sendBNBTokenResults", nil);
}

-(void)sendBNBResults:(NSNotification *)noti{
    NSString *tx_hash = noti.object;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideIndicator];
        if (!kStringIsEmpty(tx_hash)) {
            [self messageToast:languageStr(@"transfer_succeeded")];
        
            self.address.text = @"";
            self.coinNumb.text = @"";
            self.memo.text = @"";
        }else{
            [self messageToast:languageStr(@"transfer_fail")];
        }
    
    });
}


-(void)setTransferInfo{
    NSString *tokenName = self.wallet[@"tokenSymbol"]?self.wallet[@"tokenSymbol"]:self.wallet[@"tokenName"];
    NSString *logoURI = self.wallet[@"tokenIcon"]?self.wallet[@"tokenIcon"]:self.wallet[@"logoURI"];
    if (kStringIsEmpty(tokenName)) {
        tokenName = self.wallet[@"name"];
    }
    
    if (kStringIsEmpty(logoURI)) {
        logoURI = self.wallet[@"logoUrl"];
    }
   
    if (self.WalletChain == 1) {//solana
        
        if (kStringIsEmpty(self.wallet[@"tokenSymbol"])) {
            _money = @"0.0000";
            if ([tokenName isEqualToString:@"SOL" ]) {
                _money = [NSString stringWithFormat:@"%.5f",[self.wallet[@"lamports"] doubleValue]/1000000000];
            }
            
        }else{
            NSDictionary *tokenAmount = self.wallet[@"tokenAmount"];
            if (kDictIsEmpty(tokenAmount)) {
                _money = @"0.0000";
            }else{
                _money = tokenAmount[@"uiAmountString"];
            }
        }
        
    }else if (self.WalletChain > 1){//NBN
        
        if ([self.wallet[@"name"] isEqualToString:@"BNB"]) {
            _money = [DTUserDefaults getStringForKey:@"KBNBBalance"];
        }else if([self.wallet[@"name"] isEqualToString:@"ETH"]) {
            _money = [DTUserDefaults getStringForKey:@"ETHBBalance"];
        }else{
            _money = [NSString stringWithFormat:@"%.5f",[self.wallet[@"balance"] doubleValue]];
        }
    }
    
    self.availableNum.text = [NSString stringWithFormat:@"%@%@ %@",languageStr(@"available"),[_money isEqualToString:@""]?@"0.00":_money,tokenName];
    self.token.text = tokenName;
    self.tokenTitle.text = tokenName;
    [self.tokenImg sd_setImageWithURL:[NSURL URLWithString:logoURI] placeholderImage:kImage(tokenName)];
}



-(void)setSubViewColor{
    self.navigationView.titleLabel.text = languageStr(@"transfer");
    self.addressTitle.text = languageStr(@"collection_address");
    self.address.placeholder = languageStr(@"enter_collection_address");
    self.numTitle.text = languageStr(@"transfer_quantity");
    self.momeTitle.text = languageStr(@"memo");
    [self.confirmBtn setTitleOfNormal:languageStr(@"confirm")];
    [self.confirmBtn setBoundOfRadius:10];
    
    [self.memo setValue:UIColorFromHex(0x606577) forKeyPath:@"placeholderLabel.textColor"];
    [self.address setValue:UIColorFromHex(0x606577) forKeyPath:@"placeholderLabel.textColor"];
    [self.coinNumb setValue:UIColorFromHex(0x606577) forKeyPath:@"placeholderLabel.textColor"];
    
    [self.bgView1 setBoundOfRadius:10];
    [self.bgView2 setBoundOfRadius:10];
    [self.bgView3 setBoundOfRadius:10];
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        self.view.backgroundColor = UIColorBlack;
        
        self.navigationView.titleLabel.textColor = UIColorWhite;
        self.statusBarStyle = UIStatusBarStyleLightContent;
        self.navigationView.backgroundColor = UIColorBlack;
        self.navigationView.backgroundView.backgroundColor = UIColorBlack;
        
        [self.bgView setBoundOfRadius:10 width:1 color:UIColorFromHex(0x303441)];
        [self.bgView2 setBoundOfRadius:10 width:1 color:UIColorFromHex(0x303441)];
        [self.bgView3 setBoundOfRadius:10 width:1 color:UIColorFromHex(0x303441)];
        [self.bgView1 setBoundOfRadius:10 width:1 color:UIColorFromHex(0x303441)];
        self.token.textColor = UIColor.whiteColor;
        self.addressTitle.textColor = UIColor.whiteColor;
        self.numTitle.textColor = UIColor.whiteColor;
        self.momeTitle.textColor = UIColor.whiteColor;
        self.line1.backgroundColor = UIColorFromHex(0x303546);
        self.line2.backgroundColor = UIColorFromHex(0xCDD1E7);
        [self.memo setValue:UIColorFromHex(0x606577) forKeyPath:@"placeholderLabel.textColor"];
        [self.address setValue:UIColorFromHex(0x606577) forKeyPath:@"placeholderLabel.textColor"];
        [self.coinNumb setValue:UIColorFromHex(0x606577) forKeyPath:@"placeholderLabel.textColor"];
        
    }else{
        self.view.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.navigationView.titleLabel.textColor = kTitleColor;
        self.statusBarStyle = UIStatusBarStyleDarkContent;
        self.navigationView.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.navigationView.backgroundView.backgroundColor = UIColorFromHex(0xF9F9F9);
       
        [self.bgView setBoundOfRadius:10 width:1 color:UIColorFromHex(0xF2F2F2)];
        [self.bgView2 setBoundOfRadius:10 width:1 color:UIColorFromHex(0xF2F2F2)];
        [self.bgView3 setBoundOfRadius:10 width:1 color:UIColorFromHex(0xF2F2F2)];
        [self.bgView1 setBoundOfRadius:10 width:1 color:UIColorFromHex(0xF2F2F2)];
        
        self.token.textColor = kTitleColor;
        self.addressTitle.textColor = kTitleColor;
        self.numTitle.textColor = kTitleColor;
        self.momeTitle.textColor = kTitleColor;
        self.line1.backgroundColor = UIColorFromHex(0xD8DEF3);
        self.line2.backgroundColor = UIColorFromHex(0xD8DEF3);
        
        [self.memo setValue:UIColorFromHex(0xCACCD3) forKeyPath:@"placeholderLabel.textColor"];
        [self.address setValue:UIColorFromHex(0xCACCD3) forKeyPath:@"placeholderLabel.textColor"];
        [self.coinNumb setValue:UIColorFromHex(0xCACCD3) forKeyPath:@"placeholderLabel.textColor"];
        
        self.bgView1.backgroundColor = UIColorFromHex(0xEFF0F2);
        self.bgView2.backgroundColor = UIColorFromHex(0xEFF0F2);
        self.bgView3.backgroundColor = UIColorFromHex(0xEFF0F2);
        
        self.memo.textColor = kTitleColor;
    }
    
}


#pragma mark=====全部
- (IBAction)allAction:(UIButton *)sender {
    
    self.coinNumb.text = self.money;
    
}


#pragma mark===选择需要转账的币种
- (IBAction)selectCoinAction:(UIButton *)sender {
    SelectCoinView *showView = [[SelectCoinView alloc] initSelectCoinView:self.tokenList];
    [showView show];
    showView.selectCoin = ^(NSDictionary * _Nonnull wallet) {
        [showView dismiss];
        self.wallet = wallet;
        self.coinNumb.text = @"";
        [self setTransferInfo];
        
    };
    
    
}

#pragma mark=====转账
- (IBAction)confirmAction:(UIButton *)sender {
    //NSArray *array = @[@"kid",@"exhaust", @"initial", @"laptop", @"kingdom", @"silver", @"slam", @"thumb", @"leave", @"upset", @"transfer", @"orphan"];
   
    OCBridgeSwift *pair = [OCBridgeSwift new];
    self.pair = pair;
    
    NSString *toAddress = self.address.text;
    NSString *money = self.coinNumb.text;
    
    if (!kStringIsEmpty(toAddress)) {
        
        if (!kStringIsEmpty(money)) {
            [self indicatorView];
            if ([self.currentWallet[@"coin"] isEqualToString:@"SOL"]) {
                
            NSArray *array = self.wallet[@"Mnemonics"];
            if ([self.wallet[@"symbol"] isEqualToString:@"SOL"]) {//发送sol
                [self.pair CreateAssociatedTokenAccountWithPhrase:array isSendSOL:YES address:toAddress money:[money doubleValue]];
            }else{//发送代币
                [self.pair CreateAssociatedTokenAccountWithPhrase:array isSendSOL:NO address:toAddress money:[money doubleValue]];
            }
                
            }else if ([self.currentWallet[@"coin"] isEqualToString:@"BNB"]){
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if ([self.wallet[@"name"] isEqualToString:@"BNB"]) {
                        [self.pair sendBnbWithWalletAddress:self.currentWallet[@"address"] password:@"123456" receiverAddress:toAddress etherAmount:money gasLimit:@"21000"];
                    }else{
                        [self.pair sendBnbTokenWithWalletAddress:self.currentWallet[@"address"] password:@"123456" receiverAddress:toAddress tokenAmount:money tokenContractAddress:self.wallet[@"contractAdd"] gasLimit:@"21000"];
                    }
                    
                });
            }
            
            
            
        }else{
            [self messageToast:languageStr(@"fill_amount")];
        }
        
        
        
    }else{
        [self messageToast:languageStr(@"fill_transfer_address")];
    }
    
    
   
    
    
    
}


@end
