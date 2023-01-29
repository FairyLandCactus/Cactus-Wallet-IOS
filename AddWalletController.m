//
//  AddWalletController.m
//  solanaWallet
//
//  Created by wang on 2021/11/30.
//  Copyright © 2021 wang. All rights reserved.
//

#import "AddWalletController.h"
#import "AddWalletCoinView.h"
#import "ImportWalletController.h"

#import "MnemonicsController.h"
#import "SelectPublicChainView.h"
@interface AddWalletController ()
@property (weak, nonatomic) IBOutlet UIView *addWalletView;
@property (weak, nonatomic) IBOutlet UIView *ImportWallet;

@property (weak, nonatomic) IBOutlet UILabel *createTitle;
@property (weak, nonatomic) IBOutlet UILabel *createDes;
@property (weak, nonatomic) IBOutlet UIImageView *createImg;
@property (weak, nonatomic) IBOutlet UILabel *importTitle;
@property (weak, nonatomic) IBOutlet UILabel *importDes;
@property (weak, nonatomic) IBOutlet UIImageView *importImg;

@end

@implementation AddWalletController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.index == 20) {
        self.ImportWallet.hidden = YES;
    }
    
    self.view.backgroundColor = UIColor.blackColor;
    
    self.navigationView.backgroundColor = UIColorFromHexA(0x17161E, 1);
    self.navigationView.backgroundView.backgroundColor = UIColorFromHexA(0x17161E, 1);
    //self.navigationView.titleLabel.text = languageStr(@"Add Wallet");
    self.navigationView.titleLabel.textColor = UIColor.whiteColor;
    
    [self.addWalletView setBoundOfRadius:10];
    [self.ImportWallet setBoundOfRadius:10];
    
    self.createTitle.text = languageStr(@"create_new_wallet");
    self.createDes.text = languageStr(@"brand_new_wallet");
    self.importTitle.text = languageStr(@"import_existing_wallet");
    self.importDes.text = languageStr(@"import_mnemonic_private_key");
    
    
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        self.view.backgroundColor = UIColorBlack;
        
        self.navigationView.titleLabel.textColor = UIColorWhite;
        self.statusBarStyle = UIStatusBarStyleLightContent;
        
        self.navigationView.backgroundColor = UIColorBlack;
        self.navigationView.backgroundView.backgroundColor = UIColorBlack;
        [self.addWalletView setBoundOfRadius:10 width:1 color:UIColorFromHex(0x707A93)];
        [self.ImportWallet setBoundOfRadius:10 width:1 color:UIColorFromHex(0x707A93)];
        
        self.createTitle.textColor = UIColor.whiteColor;
        self.importTitle.textColor = UIColor.whiteColor;
        self.createDes.textColor = UIColorFromHex(0xAEB4D5);
        self.importDes.textColor = UIColorFromHex(0xAEB4D5);
    }else{
        self.view.backgroundColor = UIColorFromHex(0xF9F9F9);
        
        self.navigationView.titleLabel.textColor = kTitleColor;
        
        self.statusBarStyle = UIStatusBarStyleDarkContent;
     
        self.navigationView.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.navigationView.backgroundView.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.createImg.image = kImage(@"create_Img");
        self.importImg.image = kImage(@"import_img");
        [self.addWalletView setBoundOfRadius:10 width:1 color:UIColorFromHex(0xE9EEFA)];
        [self.ImportWallet setBoundOfRadius:10 width:1 color:UIColorFromHex(0xE9EEFA)];
        self.createTitle.textColor = kTitleColor;
        self.importTitle.textColor = kTitleColor;
        self.createDes.textColor = UIColorFromHex(0xAEB4D5);
        self.importDes.textColor = UIColorFromHex(0xAEB4D5);
    }
    
    
    //添加钱包
    [self.addWalletView addTapGestureRecognizer:^(UITapGestureRecognizer *recognizer, NSString *gestureId) {
        
        AddWalletCoinView *walletView = [[AddWalletCoinView alloc] initAddWalletCoinView];
        if (self.index == 20) {
            walletView.applyBgView.hidden = YES;
            walletView.applyHeight.constant=0;
            walletView.index = 2;
            walletView.storageImg.hidden = NO;
        }
        
        [walletView show];
        [walletView.nextBtn touchUpInside:^{
            
            //选择公链
            SelectPublicChainView *selectChain = [[SelectPublicChainView alloc] initSelectPublicChainView];
            
            [selectChain show];
            
            [selectChain.nextBtn addTapActionWithBlock:^(UITapGestureRecognizer *recognizer) {
                
                if (!selectChain.selectBtn.tag) {
                    return [self messageToast:languageStr(@"select_main_chain")];
                }
                
               
                
                MnemonicsController *vc = [[MnemonicsController alloc] init];
                [walletView dismiss];
                vc.walletType = walletView.index;
                vc.walletChain = selectChain.selectBtn.tag;
                vc.navigationType = NavigationTypeWhite;
                [selectChain dismiss];
                [self pushViewController:vc loginFlag:NO animated:YES];
                
            }];
           
           
        }];
        
    }];
    
    
    //倒入钱包
    [self.ImportWallet addTapGestureRecognizer:^(UITapGestureRecognizer *recognizer, NSString *gestureId) {
        
        
        //选择公链
        SelectPublicChainView *selectChain = [[SelectPublicChainView alloc] initSelectPublicChainView];
        
        [selectChain show];
        
        [selectChain.nextBtn addTapActionWithBlock:^(UITapGestureRecognizer *recognizer) {
            
            if (!selectChain.selectBtn.tag) {
                return [self messageToast:languageStr(@"select_main_chain")];
            }
            
           
            
            ImportWalletController *vc = [[ImportWalletController alloc] init];
            vc.walletChain = selectChain.selectBtn.tag;
            vc.navigationType = NavigationTypeWhite;
            [selectChain dismiss];
            [self pushViewController:vc loginFlag:NO animated:YES];
            
        }];

      
        
        
    }];
    
}



@end
