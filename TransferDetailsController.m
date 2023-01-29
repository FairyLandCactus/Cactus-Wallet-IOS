//
//  TransferDetailsController.m
//  ASolanaWallet
//
//  Created by wang on 2022/10/27.
//

#import "TransferDetailsController.h"
#import "MyTools.h"
@interface TransferDetailsController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *num;
@property (weak, nonatomic) IBOutlet UILabel *results;
@property (weak, nonatomic) IBOutlet UILabel *sendAddress;
@property (weak, nonatomic) IBOutlet UILabel *send;
@property (weak, nonatomic) IBOutlet UILabel *receiveTitle;
@property (weak, nonatomic) IBOutlet UILabel *receive;
@property (weak, nonatomic) IBOutlet UILabel *feeTitle;
@property (weak, nonatomic) IBOutlet UILabel *fee;
@property (weak, nonatomic) IBOutlet UILabel *timeTitle;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *highlyTitle;
@property (weak, nonatomic) IBOutlet UILabel *highly;
@property (weak, nonatomic) IBOutlet UILabel *hashTitle;
@property (weak, nonatomic) IBOutlet UILabel *hashDes;

@end

@implementation TransferDetailsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.bgView setBoundOfRadius:20];
    self.results.text = languageStr(@"transfer_completed");
    self.sendAddress.text = languageStr(@"transfer_address_this");
    self.receiveTitle.text = languageStr(@"transfer_in_address");
    self.feeTitle.text = languageStr(@"miner_fee");
    self.timeTitle.text = languageStr(@"time");
    self.hashTitle.text = languageStr(@"Transaction_Hash");
    self.highlyTitle.text  = languageStr(@"block_height");
    
    
    if ([self.coinObj[@"tokenName"] containsString:@"BNB"]) {
        self.send.text = self.obj[@"from"];
        self.receive.text = self.obj[@"to"];
        self.highly.text = self.obj[@"blockNumber"];
        self.hashDes.text = self.obj[@"hash"];
        NSString *value = self.obj[@"value"];
        NSString *fee = self.obj[@"gasUsed"];
        self.time.text = [MyTools timestampChangesTime:self.obj[@"timeStamp"] ];
        if (self.isTransfer) {//转出
            self.num.text = [NSString stringWithFormat:@"- %f BNB",[value integerValue]/100000000000000000.0];
        }else{
            self.num.text = [NSString stringWithFormat:@"+ %f BNB",[value integerValue]/100000000000000000.0];
        }
        
        self.fee.text = [NSString stringWithFormat:@" %f BNB",[fee integerValue]/100000000000000000.0];
        
    }else{
        if ([self.coinObj[@"tokenName"] containsString:@"SOL"]) {
            self.send.text = self.obj[@"src"];
            self.receive.text = self.obj[@"dst"];
            self.highly.text = [self.obj[@"slot"] stringValue];
            self.hashDes.text = self.obj[@"txHash"];
            NSString *value = [self.obj[@"lamport"] stringValue];
            NSString *fee = [self.obj[@"fee"] stringValue];
            self.time.text = [MyTools timestampChangesTime:self.obj[@"blockTime"] ];
            if (self.isTransfer) {//转出
                self.num.text = [NSString stringWithFormat:@"- %f SOL",[value doubleValue]/1000000000];
            }else{
                self.num.text = [NSString stringWithFormat:@"+ %f SOL",[value doubleValue]/1000000000];
            }
            
            self.fee.text = [NSString stringWithFormat:@" %f SOL",[fee doubleValue]/1000000000];
        }else{
            self.send.text = self.obj[@"src"];
            self.receive.text = @"";
            self.highly.text = [self.obj[@"slot"] stringValue];
            self.hashDes.text = self.obj[@"txHash"];
            NSString *value = [self.obj[@"lamport"] stringValue];
            NSString *fee = [self.obj[@"fee"] stringValue];
            NSDictionary *change = self.obj[@"change"];
            self.time.text = [MyTools timestampChangesTime:self.obj[@"blockTime"] ];
            if (self.isTransfer) {//转出
                self.num.text = [NSString stringWithFormat:@"- %f %@",[value doubleValue]/1000000000,change[@"tokenName"]];
            }else{
                self.num.text = [NSString stringWithFormat:@"+ %f %@",[value doubleValue]/1000000000,change[@"tokenName"]];
            }
            
            self.fee.text = [NSString stringWithFormat:@" %f %@",[fee doubleValue]/1000000000,change[@"tokenName"]];
        }
        
    }
    
    
    
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        self.view.backgroundColor = UIColorFromHex(0x0A0C1A);
        
        self.navigationView.titleLabel.textColor = UIColorWhite;
        self.statusBarStyle = UIStatusBarStyleLightContent;
        
        self.navigationView.backgroundColor = UIColorBlack;
        self.navigationView.backgroundView.backgroundColor = UIColorBlack;
        self.bgView.backgroundColor = UIColorBlack;
        
        self.num.textColor = UIColorWhite;
        self.sendAddress.textColor = UIColorWhite;
        self.receiveTitle.textColor = UIColorWhite;
        self.feeTitle.textColor = UIColorWhite;
        self.timeTitle.textColor = UIColorWhite;
        self.highlyTitle.textColor = UIColorWhite;
        self.hashTitle.textColor = UIColorWhite;
        self.send.textColor = UIColorFromHex(0x8489A1);
        self.receive.textColor = UIColorFromHex(0x8489A1);
        self.fee.textColor = UIColorFromHex(0x8489A1);
        self.time.textColor = UIColorFromHex(0x8489A1);
        self.highly.textColor = UIColorFromHex(0x8489A1);
        self.hashDes.textColor = UIColorFromHex(0x8489A1);
        
        
    }else{
        self.view.backgroundColor = UIColorWhite;
        
        self.navigationView.titleLabel.textColor = kTitleColor;
        
        self.statusBarStyle = UIStatusBarStyleDarkContent;
     
        self.navigationView.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.navigationView.backgroundView.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.bgView.backgroundColor = UIColorFromHex(0xF9F9FB);
       // self.num.textColor = kTitleColor;
       
    }
    
   
   
    
    


}



@end
