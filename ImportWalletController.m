//
//  ImportWalletController.m
//  solanaWallet
//
//  Created by wang on 2021/12/1.
//  Copyright © 2021 wang. All rights reserved.
//

#import "ImportWalletController.h"
#import "UITextView+Placeholder.h"
#import "ImportWalletHelpView.h"
#import "ASolanaWallet-Swift.h"
//#import "BTCBase58.h"
//#import "NS+BTCBase58.h"
@interface ImportWalletController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIButton *importBtn;
@property (weak, nonatomic) IBOutlet UILabel *importTitle;
@property (weak, nonatomic) IBOutlet UILabel *importDes;
@property (nonatomic,strong) OCBridgeSwift *pair;
@end

@implementation ImportWalletController
- (void)dealloc{
    notification_remove(self, @"SOLImportNotice", nil);
    notification_remove(self, @"BNBimportNot", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationView.title = languageStr(@"Import_the_wallet");
    
    self.txtView.delegate = self;
    
    [self.importBtn setBoundOfRadius:10];
    
   
    self.importTitle.text = languageStr(@"import_existing_wallet");
    self.importDes.text = languageStr(@"mnemonics_private_3");
    [self.importBtn setTitleOfNormal:languageStr(@"confirm")];
    
    self.importBtn.backgroundColor = UIColorFromHex(0xE0E3F1);
    
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        self.view.backgroundColor = UIColorBlack;
        
        self.navigationView.titleLabel.textColor = UIColorWhite;
        self.statusBarStyle = UIStatusBarStyleLightContent;
        
        self.navigationView.backgroundColor = UIColorBlack;
        self.navigationView.backgroundView.backgroundColor = UIColorBlack;
        
        [self.txtView setBoundOfRadius:16 width:1 color:UIColorFromHex(0x7F7F7F)];
        self.txtView.placeholderColor = UIColorFromHex(0x999999);
        self.txtView.textColor = UIColor.whiteColor;
        self.txtView.placeholder = languageStr(@"separated_by_spaces");
       
    }else{
        self.view.backgroundColor = UIColorFromHex(0xF9F9F9);
        
        self.navigationView.titleLabel.textColor = kTitleColor;
        
        self.statusBarStyle = UIStatusBarStyleDarkContent;
     
        self.navigationView.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.navigationView.backgroundView.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.importTitle.textColor = kTitleColor;
        self.importDes.textColor = UIColorFromHex(0x46525C);
        self.txtView.backgroundColor = UIColor.whiteColor;
        
        [self.txtView setBoundOfRadius:16 width:1 color:UIColorFromHex(0x919AB1)];
        self.txtView.placeholderColor = UIColorFromHex(0x999999);
        self.txtView.textColor = kTitleColor;
        self.txtView.placeholder = languageStr(@"separated_by_spaces");
    }
    
    
    
#pragma ====
    [self.navigationView addRightButtonWithTitle:@"" image:kImage(@"wallet_16") clickCallBack:^(UIView *view) {
        ImportWalletHelpView *showView = [[ImportWalletHelpView alloc] initImportWalletHelpView];
        [showView show];
    }];
    
#pragma ====通知
    if (self.walletChain == 1) {
        notification_add(self, @selector(importSOLNotice:), @"SOLImportNotice", nil);
    }else{
        notification_add(self, @selector(importBNBNotice:), @"BNBimportNot", nil);
    }
   
    
}

- (void)textViewDidChange:(UITextView *)textView { // 在该代理方法中实现实时监听uitextview的输入
    
    if (self.txtView.text.length) {
        [self.importBtn setBackgroundColor:UIColorFromHex(0x445FFF)];
        self.importBtn.enabled = YES;
    }else{
        
        [self.importBtn setBackgroundColor:UIColorFromHex(0xE0E3F1)];
        self.importBtn.enabled = NO;
    }
   

}


-(void)importSOLNotice:(NSNotification *)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
    NSArray *array = noti.object;
    
    [self.importBtn setTitleOfNormal:languageStr(@"confirm")];
    self.importBtn.enabled = YES;
    NSArray *list =  [DTUserDefaults getArrayForKey:@"SOLWalletList"];
    NSDictionary *dic;
    NSMutableArray *mutArray ;
    if (list.count) {
        
        
        dic = @{@"address":array[0],@"SecretKey":array[1],@"Mnemonics":array[2],@"name":[NSString stringWithFormat:@"%@%ld",languageStr(@"SOL_wallet"),list.count+1],@"isSelect":@"0",@"coin":@"SOL",@"tokenList":[self readLocalFileWithName:@"solana.default"]};
        mutArray = [NSMutableArray arrayWithArray:list];
        
        //判断钱包是否存在
        for (NSDictionary* wallet in list) {
            if ([wallet[@"SecretKey"] isEqualToString:dic[@"SecretKey"]]) {//钱包存在
                return [self messageToast:languageStr(@"Wallet_already_exists")];;
            }
        }
        
    }else{
        dic = @{@"address":array[0],@"SecretKey":array[1],@"Mnemonics":array[2],@"name":[NSString stringWithFormat:@"%@%d",languageStr(@"SOL_wallet"),1],@"isSelect":@"1",@"coin":@"SOL",@"tokenList":[self readLocalFileWithName:@"solana.default"]};
        mutArray = [NSMutableArray new];
    }
    
   
    
    [mutArray addObject:dic];
    [DTUserDefaults setInteger:1 key:@"KWalletChain"];
    [DTUserDefaults setArray:mutArray key:@"SOLWalletList"];
    
    [self messageToast:languageStr(@"inprot_wallet_success")];
    
    [[AppDelegate appDelegate] showMainVC:0];
        
    });
}

#pragma mark====BNB钱包导入回调

-(void)importBNBNotice:(NSNotification *)not{
    
    
  
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.importBtn setTitleOfNormal:languageStr(@"confirm")];
        self.importBtn.enabled = YES;
        // UI更新代码
       
        NSArray *array = not.object;
        
        NSString *chain = [array lastObject];
        NSArray *list;
        if ([chain isEqualToString:@"BNB"]) {
            list =  [DTUserDefaults getArrayForKey:@"BNBWalletList"];
        }else{
            list =  [DTUserDefaults getArrayForKey:@"ETHWalletList"];
        }
        //
      
        NSDictionary *dic;
        NSMutableArray *mutArray ;
        NSDictionary *BNB = @{
            @"name":[chain isEqualToString:@"BNB"]? @"BNB":@"ETH",
            @"dec": [chain isEqualToString:@"BNB"]? @"Bsc":@"Ethereum",
            @"contractAdd":[chain isEqualToString:@"BNB"]? @"0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c":@"0x2170Ed0880ac9A755fd29B2688956BD959F933F8" ,
            @"logoUrl": [chain isEqualToString:@"BNB"]? @"https://bscscan.com/images/gen/binance_20.png":@"Ethereum",
            @"decimals": @18
        };
        if (list.count) {
            
           
            
            dic = @{@"address":array[0],@"SecretKey":array[1],@"Mnemonics":array[2],@"name":[NSString stringWithFormat:@"%@%ld",[chain isEqualToString:@"BNB"]? languageStr(@"BNB_wallet"):languageStr(@"ETH_wallet"),list.count+1],@"isSelect":@"0",@"coin":[chain isEqualToString:@"BNB"]? @"BNB":@"ETH",@"tokenList":@[BNB]};
            mutArray = [NSMutableArray arrayWithArray:list];
            //判断钱包是否存在
            for (NSDictionary* wallet in list) {
                if ([wallet[@"SecretKey"] isEqualToString:dic[@"SecretKey"]]) {//钱包存在
                    
                    return [self messageToast:languageStr(@"Wallet_already_exists")];;
                }
            }
            
        }else{
            dic = @{@"address":array[0],@"SecretKey":array[1],@"Mnemonics":array[2],@"name":[NSString stringWithFormat:@"%@%d",[chain isEqualToString:@"BNB"]? languageStr(@"BNB_wallet"):languageStr(@"ETH_wallet"),1],@"isSelect":@"1",@"coin":[chain isEqualToString:@"BNB"]? @"BNB":@"ETH",@"tokenList":@[BNB]};
            mutArray = [NSMutableArray new];
        }
    
   
    
        [mutArray addObject:dic];
    
        [DTUserDefaults setInteger:[chain isEqualToString:@"BNB"]? 2:3 key:@"KWalletChain"];
        [DTUserDefaults setArray:mutArray key:[chain isEqualToString:@"BNB"]? @"BNBWalletList":@"ETHWalletList"];
        
        [self messageToast:languageStr(@"inprot_wallet_success")];
    
        [[AppDelegate appDelegate] showMainVC:0];
        
        });
    
}

#pragma mark=====导入钱包
- (IBAction)importAction:(UIButton *)sender {
    
    //主线程
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // UI更新代码
        //[self hideIndicator];
        [sender setTitleOfNormal:languageStr(@"In_the_import")];
        sender.enabled = NO;
    }];
    NSString *txtStr = self.txtView.text;
    NSArray* array = [txtStr componentsSeparatedByString:@" "];
  
    OCBridgeSwift *pair = [OCBridgeSwift new];
    self.pair = pair;
    
    if (array.count >= 6) {//助记词导入
      
        if (self.walletChain == 1) {
            
            [self.pair mnemonicImportSolanaWalletWithPhrase:array];
        }else{
            //BNB
            //[self indicatorView];
            dispatch_queue_t queue = dispatch_queue_create("importBNB", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(queue, ^{
                
               // [self.pair BNBimportByMnemonicWithMnemonic:self.txtView.text];
              
            });
           
        }
       
    }else{
        
        if (txtStr.length > 63) {//十六进制
            dispatch_queue_t queue = dispatch_queue_create("importBNB", DISPATCH_QUEUE_CONCURRENT);
            dispatch_async(queue, ^{
                if (self.walletChain == 1) {//sol
                    [self.pair privateKeyImportSolanaWalletWithSecretKey:txtStr];
                }else{
                    NSArray *chains = @[@"BNB",@"ETH"];
                    //BNB ETH
                    [self.pair BNBimportByPrivateKeyWithPrivateKey:txtStr chain:chains[self.walletChain-2]];
                }
            });
            
        }else{
            
            [self messageToast:languageStr(@"Private_error")];
        }
        
    }
    
    
    
    
    
}

// 读取本地JSON文件
- (NSArray *)readLocalFileWithName:(NSString *)name {
    // 获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"json"];
    // 将文件数据化
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    // 对数据进行JSON格式化并返回字典形式
    return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
}

//2Ev1Fgck6JgiEzWWKUkaVLrwm7CjX7MJNdeSrCwqBsLz

//-(void)saveWallet:(NSDictionary*)dic{
//    sleep(1);
//    NSArray *array =  [DTUserDefaults getArrayForKey:@"KWalletList"];
//    
//    if (!array.count) {
//        [DTUserDefaults setArray:@[dic] key:@"KWalletList"];
//    }else{
//        NSMutableArray *muArr = [NSMutableArray new];
//        for (NSDictionary *obj in array) {
//            [muArr addObject:obj];
//        }
//        [muArr addObject:dic];
//        [DTUserDefaults setArray:muArr key:@"KWalletList"];
//    }
//    //[self hideIndicator];
//    [[AppDelegate appDelegate] loginSuccessVc];
//    
//}

@end
