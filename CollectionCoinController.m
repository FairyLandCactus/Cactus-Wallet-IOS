//
//  CollectionCoinController.m
//  solanaWallet
//
//  Created by wang on 2021/12/3.
//  Copyright © 2021 wang. All rights reserved.
//

#import "CollectionCoinController.h"
#import "HHPayPasswordView.h"
#import "HBPublicManage.h"

@interface CollectionCoinController ()<HHPayPasswordViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *pwdBgView;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipDes;

@property (weak, nonatomic) IBOutlet UILabel *noteTitle;

@property (nonatomic,strong) NSString *pwd1;
@property (nonatomic,strong) NSString *pwd2;
@property (weak, nonatomic) IBOutlet UIButton *copysBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UILabel *solTitle;
@property (weak, nonatomic) IBOutlet UILabel *solDes;
@property (weak, nonatomic) IBOutlet UIImageView *codeImg;

@property (weak, nonatomic) IBOutlet UIImageView *wattleImg;
@property (weak, nonatomic) IBOutlet UILabel *address;
@end

@implementation CollectionCoinController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *logoURI = self.wallet[@"tokenIcon"]?self.wallet[@"tokenIcon"]:self.wallet[@"logoURI"];
    if (kStringIsEmpty(logoURI)) {
        logoURI = self.wallet[@"logoUrl"];
    }
    
    NSString *tokenName = self.wallet[@"tokenSymbol"]?self.wallet[@"tokenSymbol"]:self.wallet[@"tokenName"];
    
    if (kStringIsEmpty(tokenName)) {
        tokenName = self.wallet[@"name"];
    }
   
    
    
    self.solTitle.text = [NSString stringWithFormat:@"%@%@",tokenName,languageStr(@"collection")];
    
    [self.wattleImg sd_setImageWithURL:[NSURL URLWithString:logoURI] placeholderImage:kImage(logoURI)];
    
    
    self.view.backgroundColor = UIColorFromHex(0x658CFF);
    self.navigationView.backgroundColor = UIColorFromHexA(0x17161E, 0);
    self.navigationView.backgroundView.backgroundColor = UIColorFromHexA(0x17161E, 0);
    
    [self.copysBtn setTitleOfNormal:languageStr(@"copy_address")];
    [self.shareBtn setTitleOfNormal:languageStr(@"share")];
   
    
    //self.solTitle.text = [NSString stringWithFormat:@"SOL%@",languageStr(@"collection")];
    self.solDes.text = languageStr(@"scan_qr_code_pay_me");
    
    [self.bgView setBoundOfRadius:15];
    [self.confirmBtn setBoundOfRadius:6];
    

    [self.confirmBtn setTitleOfNormal:languageStr(@"confirm")];
    
    self.tipDes.text = languageStr(@"collection_verify_tip");
    if (self.WalletChain == 1) {
        self.noteTitle.text =  languageStr(@"note_sol");
    }else if (self.WalletChain == 2){
        self.noteTitle.text =  languageStr(@"note_bnb");
    }else if (self.WalletChain == 3){
        self.noteTitle.text =  languageStr(@"note_eth");
    }
    
    
}


- (IBAction)confirmAction:(UIButton *)sender {
    
    HHPayPasswordView *payPasswordView = [[HHPayPasswordView alloc] init];
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
   
    payPasswordView.backgroundColor = UIColorFromHexA(0x000000, 0);
    
    
    payPasswordView.delegate = self;
    [payPasswordView showInView:self.view];
}


#pragma mark - HHPayPasswordViewDelegate
- (void)passwordView:(HHPayPasswordView *)passwordView didFinishInputPayPassword:(NSString *)password{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        NSString *pwd = [DTUserDefaults getStringForKey:@"KPassword"];
        if (kStringIsEmpty(pwd)) {//没有设置过密码
            
        if (kStringIsEmpty(self.pwd1)) {
            self.pwd1 = password;
            [passwordView setDotsViewHidden];
            [passwordView clickOnceButton];
            [passwordView paySuccess];
            return;
        }else{
            self.pwd2 = password;
            
            if (![self.pwd1 isEqualToString:self.pwd2]) {//两次密码不一致
                
                passwordView.tipLabel.text = @"The passwords are inconsistent. Enter them again";
                self.pwd1 = @"";
                self.pwd2 = @"";
                [passwordView setDotsViewHidden];
                [passwordView clickOnceButton];
                
            }else{//密码正确
                //保存密码
                [DTUserDefaults setString:password key:@"KPassword"];
                //[passwordView hide];
                //保存钱包数据
//                NSArray *array = [DTUserDefaults getArrayForKey:@"KWalletList"];
//                NSDictionary *wallet ;
//                if (array.count) {
//                    for (NSDictionary *obj in array) {
//                        if ([obj[@"isSelect"] intValue]) {
//                            wallet = obj;
//                        }
//                    }
//                }else{
//                    [self messageToast:languageStr(@"no_wallet")];
//                }
//
  
                
               
                
                self.address.text = self.currentWallet[@"address"];
                self.codeImg.image = [CollectionCoinController creatCIQRCodeImage:self.currentWallet[@"address"]];
                [passwordView hide];
                self.pwdBgView.hidden = YES;
                
               
            }
        }
        
       
        }else{//设置过密码
            
            if ([pwd isEqualToString:password]) {//密码正确
                //保存钱包数据
               
                NSArray *array = [DTUserDefaults getArrayForKey:@"KWalletList"];
//                NSDictionary *wallet ;
//                if (array.count) {
//                    for (NSDictionary *obj in array) {
//                        if ([obj[@"isSelect"] intValue]) {
//                            wallet = obj;
//                        }
//                    }
//                }else{
//                    [self messageToast:languageStr(@"no_wallet")];
//                }
                
               
                self.address.text = self.currentWallet[@"address"];
                
               
                self.codeImg.image = [CollectionCoinController creatCIQRCodeImage:self.currentWallet[@"address"]];
                [passwordView hide];
                self.pwdBgView.hidden = YES;
            }else{//密码错误
                passwordView.tipLabel.text = languageStr(@"pwd_error");
        
                [passwordView setDotsViewHidden];
                [passwordView clickOnceButton];
            }
            
        
        }
        

   });
        
    
}

- (IBAction)copysAction:(UIButton *)sender {
    
    [HBPublicManage stringToPasteBoard:self.address.text];
}

- (IBAction)shareAction:(UIButton *)sender {
}



/**
 *  生成二维码
 */
+ (UIImage *)creatCIQRCodeImage:(NSString *)dataStr{
    //创建过滤器，这里的@"CIQRCodeGenerator"是固定的
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //恢复默认设置
    [filter setDefaults];
    //给过滤器添加数据
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    //value必须是NSData类型
    [filter setValue:data forKeyPath:@"inputMessage"];
    //生成二维码
    CIImage *outputImage = [filter outputImage];
    //显示二维码
    return [self creatNonInterpolatedUIImageFormCIImage:outputImage withSize:160.0];
}

+ (UIImage *)creatNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    //创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    //保存bitmap图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


@end
