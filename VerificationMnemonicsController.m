//
//  VerificationMnemonicsController.m
//  solanaWallet
//
//  Created by wang on 2021/12/2.
//  Copyright © 2021 wang. All rights reserved.
//

#import "VerificationMnemonicsController.h"
#import "HHPayPasswordView.h"



@interface VerificationMnemonicsController ()<HHPayPasswordViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *num1;
@property (weak, nonatomic) IBOutlet UILabel *num2;
@property (weak, nonatomic) IBOutlet UILabel *num3;
@property (weak, nonatomic) IBOutlet UIButton *title1;
@property (weak, nonatomic) IBOutlet UIButton *title2;
@property (weak, nonatomic) IBOutlet UIButton *title3;

@property (weak, nonatomic) IBOutlet UILabel *tipTitle;
@property (weak, nonatomic) IBOutlet UILabel *tipDes;

@property (nonatomic,assign) NSInteger index1;
@property (nonatomic,assign) NSInteger index2;
@property (nonatomic,assign) NSInteger index3;
@property (nonatomic,strong) NSString *pwd1;
@property (nonatomic,strong) NSString *pwd2;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (nonatomic,strong) NSMutableArray *selectBtnArr;
@property (nonatomic,strong) UIButton *selectBtn1;
@property (nonatomic,strong) UIButton *selectBtn2;
@property (nonatomic,strong) UIButton *selectBtn3;
@property (nonatomic,strong) NSArray *dataSource;
@property (nonatomic,strong) NSArray *walletList;
@end

@implementation VerificationMnemonicsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blackColor;
    
    self.navigationView.backgroundColor = UIColorFromHexA(0x17161E, 1);
    self.navigationView.backgroundView.backgroundColor = UIColorFromHexA(0x17161E, 1);
    if (self.walletChain == 1) {//SOL
        self.walletList = [DTUserDefaults getArrayForKey:@"SOLWalletList"];
    }else if (self.walletChain == 2){//BNB
        self.walletList = [DTUserDefaults getArrayForKey:@"BNBWalletList"];
    }else if (self.walletChain == 3){//ETH
        self.walletList = [DTUserDefaults getArrayForKey:@"ETHWalletList"];
    }

    self.dataSource = self.words;
    //给助记词排序 
    self.words = [self.words sortedArrayUsingSelector:@selector(compare:)];
    
    self.navigationView.title = languageStr(@"create_a_wallet");
    self.tipTitle.text = languageStr(@"backup_mnemonics");
    self.tipDes.text = languageStr(@"select_mnemonic_number");
    [self.confirmBtn setTitleOfNormal:languageStr(@"confirm")];
    [self.confirmBtn setBoundOfRadius:10];
    
    self.title1.selected = NO;
    self.title2.selected = NO;
    self.title3.selected = NO;
    
    NSInteger index1 = arc4random()%3+1;
    NSInteger index2 = arc4random()%6+3;
    NSInteger index3 = index2 +3;
    
    if (index1 == index2) {
        index2 = index2+2;
    }
    self.index1 = index1;
    self.index2 = index2;
    self.index3 = index3;
    self.num1.text = [NSString stringWithFormat:languageStr(@"enter_th_word_1"),self.index1];
    self.num2.text = [NSString stringWithFormat:languageStr(@"enter_th_word_1"),self.index2];
    self.num3.text = [NSString stringWithFormat:languageStr(@"enter_th_word_1"),self.index3];
    
    [self setUPUI];
    
}
- (IBAction)wordTitleAction:(UIButton *)sender {
    
    if (self.selectBtnArr.count) {
        [sender setTitleOfNormal:@""];
        sender.selected = NO;

        [self.selectBtnArr removeLastObject];

        if (sender.tag == 100) {
            [self.selectBtn1 setColorOfNormal:UIColor.whiteColor];
        }else if (sender.tag == 200){
            [self.selectBtn2 setColorOfNormal:UIColor.whiteColor];
        }else if (sender.tag == 300){
            [self.selectBtn3 setColorOfNormal:UIColor.whiteColor];
        }

    }
    
    self.confirmBtn.backgroundColor = UIColorFromHex(0x2C3046);
   
    
}


-(void)setUPUI{
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        self.view.backgroundColor = UIColorBlack;
        
        self.navigationView.titleLabel.textColor = UIColorWhite;
        self.statusBarStyle = UIStatusBarStyleLightContent;
        
        self.navigationView.backgroundColor = UIColorBlack;
        self.navigationView.backgroundView.backgroundColor = UIColorBlack;
        self.tipTitle.textColor = UIColorWhite;
        self.tipDes.textColor = UIColorWhite;
        
        self.num1.textColor = UIColorWhite;
        self.num2.textColor = UIColorWhite;
        self.num3.textColor = UIColorWhite;
        
        [self.title1 setColorOfNormal:UIColorWhite];
        [self.title2 setColorOfNormal:UIColorWhite];
        [self.title3 setColorOfNormal:UIColorWhite];
        
        self.title1.backgroundColor = UIColorFromHex(0x2C2E3C);
        self.title2.backgroundColor = UIColorFromHex(0x2C2E3C);
        self.title3.backgroundColor = UIColorFromHex(0x2C2E3C);
        
        [self.title1 setBoundOfRadius:6 width:1 color:UIColorFromHex(0x3D404B)];
        [self.title2 setBoundOfRadius:6 width:1 color:UIColorFromHex(0x3D404B)];
        [self.title3 setBoundOfRadius:6 width:1 color:UIColorFromHex(0x3D404B)];
        
        self.confirmBtn.backgroundColor = UIColorFromHex(0x2C3046);
    }else{
        self.view.backgroundColor = UIColorFromHex(0xF9F9F9);
        
        self.navigationView.titleLabel.textColor = kTitleColor;
        
        self.statusBarStyle = UIStatusBarStyleDarkContent;
     
        self.navigationView.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.navigationView.backgroundView.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.tipTitle.textColor = kTitleColor;
        self.tipDes.textColor = UIColorFromHex(0xB7BED1);
        
        self.num1.textColor = kTitleColor;
        self.num2.textColor = kTitleColor;
        self.num3.textColor = kTitleColor;
        [self.title1 setColorOfNormal:kTitleColor];
        [self.title2 setColorOfNormal:kTitleColor];
        [self.title3 setColorOfNormal:kTitleColor];
        self.title1.backgroundColor = UIColorFromHex(0xF3F4F8);
        self.title2.backgroundColor = UIColorFromHex(0xF3F4F8);
        self.title3.backgroundColor = UIColorFromHex(0xF3F4F8);
        
        [self.title1 setBoundOfRadius:6 width:1 color:UIColorFromHex(0xEAECF2)];
        [self.title2 setBoundOfRadius:6 width:1 color:UIColorFromHex(0xEAECF2)];
        [self.title3 setBoundOfRadius:6 width:1 color:UIColorFromHex(0xEAECF2)];
        
        self.confirmBtn.backgroundColor = UIColorFromHex(0xE9EBF4);
    }
    
   
    [self layoutMultiLine];
    
    
}

-(void)layoutMultiLine{
    //多行布局 要考虑换行的问题
    
    CGFloat marginX = 25;  //按钮距离左边和右边的距离
    CGFloat marginY = 0;  //距离上下边缘距离
    CGFloat toTop = 0;  //按钮距离顶部的距离
    CGFloat gapX = 15;    //左右按钮之间的距离
    CGFloat gapY = 15;    //上下按钮之间的距离
    NSInteger col = 3;    //这里只布局5列
    NSInteger count = self.words.count;  //这里先设置布局任意个按钮
    
    CGFloat viewWidth = SCREEN_WIDTH;  //视图的宽度
    CGFloat viewHeight = 200;  //视图的高度
    
    CGFloat itemWidth = (viewWidth - marginX *2 - (col - 1)*gapX)/col*1.0f;  //根据列数 和 按钮之间的间距 这些参数基本可以确定要平铺的按钮的宽度
    CGFloat itemHeight = 48;   //按钮的高度可以根据情况设定 这里设置为相等
    
    UIButton *last = nil;   //上一个按钮
    //准备工作完毕 既可以开始布局了
    for (int i = 0 ; i < count; i++) {
        UIButton *item = [self buttonCreat];
        
        [item addTarget:self action:@selector(selectMnemonics:) forControlEvents:UIControlEventTouchUpInside];
        
        [item setTitleOfNormal:self.words[i]];
        [self.bgView addSubview:item];
        
        //布局
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            
            //宽高是固定的，前面已经算好了
            make.width.mas_equalTo(itemWidth);
            make.height.mas_equalTo(itemHeight);
            
            //topTop距离顶部的距离，单行不用考虑太多，多行，还需要计算距离顶部的距离
            //计算距离顶部的距离 --- 根据换行
            CGFloat top = toTop + marginY + (i/col)*(itemHeight+gapY);
            make.top.mas_offset(top);
            if (!last || (i%col) == 0) {  //last为nil  或者(i%col) == 0 说明换行了 每行的第一个确定它距离左边边缘的距离
                make.left.mas_offset(marginX);
                
            }else{
                //第二个或者后面的按钮 距离前一个按钮右边的距离都是gap个单位
                make.left.mas_equalTo(last.mas_right).mas_offset(gapX);
            }
        }];
        last = item;
    }
}

#pragma mark - Private
-(UIButton *)buttonCreat{
    UIButton *item = [[UIButton alloc] init];
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        [item setBoundOfRadius:6 width:1 color:UIColorFromHex(0x2D313A)];
        [item setColorOfNormal:UIColor.whiteColor];
    }else{
        [item setBoundOfRadius:6 width:1 color:UIColorFromHex(0xE5E8ED)];
        [item setColorOfNormal:kTitleColor];
    }
    
    [item setFontOfSize:16];
    
    
  
    return item;
}

#pragma mark==== 选择助记词
-(void)selectMnemonics:(UIButton*)btn{
    if (self.selectBtnArr.count < 3) {
        [btn setColorOfNormal:UIColorFromHex(0x3F4155)];
        [self.selectBtnArr addObject:btn];
    }else{
        return;
    }
    
   
    [self setMnemonicsTitle:btn];
    
    if (self.selectBtnArr.count == 3) {
        self.confirmBtn.backgroundColor = UIColorFromHex(0x445FFF);
    }else{
        self.confirmBtn.backgroundColor = UIColorFromHex(0x2C3046);
    }
    

}


-(void)setMnemonicsTitle:(UIButton*)btn{
    if (!self.title1.selected) {
        self.title1.selected = YES;
        [self.title1 setTitleOfNormal:btn.titleLabel.text];
        self.selectBtn1 = btn;
    }else if (!self.title2.selected) {
        self.title2.selected = YES;
        self.selectBtn2 = btn;
        [self.title2 setTitleOfNormal:btn.titleLabel.text];
    }else if (!self.title3.selected) {
        self.title3.selected = YES;
        self.selectBtn3 = btn;
        [self.title3 setTitleOfNormal:btn.titleLabel.text];
    }
}


- (IBAction)confirmAction:(UIButton *)sender {
    
    
    if (![self.dataSource[self.index1-1] isEqualToString:self.title1.titleLabel.text]) {
        
        return [self messageToast:[NSString stringWithFormat:languageStr(@"word_wrong"),self.index1]];
    }else if (![self.dataSource[self.index2-1] isEqualToString:self.title2.titleLabel.text]) {
        
        return [self messageToast:[NSString stringWithFormat:languageStr(@"word_wrong"),self.index2]];
    }else if (![self.dataSource[self.index3-1] isEqualToString:self.title3.titleLabel.text]) {
        
        return [self messageToast:[NSString stringWithFormat:languageStr(@"word_wrong"),self.index3]];
    }else {
        
        
        
        HHPayPasswordView *payPasswordView = [[HHPayPasswordView alloc] init];
        
        NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
        if ([colorStr isEqualToString:@"B"]) {
            payPasswordView.backgroundColor = UIColorFromHex(0x292B35);
        }else{
            payPasswordView.backgroundColor = UIColor.whiteColor;
        }
        
        payPasswordView.delegate = self;
        [payPasswordView showInView:self.view];
    }
    
   
    HHPayPasswordView *payPasswordView = [[HHPayPasswordView alloc] init];
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        //payPasswordView.backgroundColor = UIColorFromHex(0x292B35);
    }else{
       // payPasswordView.backgroundColor = UIColor.whiteColor;
    }
    
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
                
                [DTUserDefaults setString:password key:@"KPassword"];
                [passwordView hide];
                //保存钱包数据
               
                [DTUserDefaults setInteger:self.walletChain key:@"KWalletChain"];
                if (!self.walletList.count) {
                    [DTUserDefaults setArray:@[self.walletObj] key:[self getUserDefaultskey]];
                }else{
                    NSMutableArray *muArr = [NSMutableArray new];
                    for (NSDictionary *obj in self.walletList) {
                        [muArr addObject:obj];
                    }
                    [muArr addObject:self.walletObj];
                    [DTUserDefaults setArray:muArr key:[self getUserDefaultskey]];
                }
                
                
                [self messageToast:languageStr(@"wallet_create_success")];
                [[AppDelegate appDelegate] loginSuccessVc];
            }
        }
        
       
        }else{//已经设置过密码
            
            if ([pwd isEqualToString:password]) {//密码正确
                //保存钱包数据
                [DTUserDefaults setInteger:self.walletChain key:@"KWalletChain"];
                if (!self.walletList.count) {
                    [DTUserDefaults setArray:@[self.walletObj] key:[self getUserDefaultskey]];
                }else{
                    NSMutableArray *muArr = [NSMutableArray new];
                    for (NSDictionary *obj in self.walletList) {
                        [muArr addObject:obj];
                    }
                    [muArr addObject:self.walletObj];
                    [DTUserDefaults setArray:muArr key:[self getUserDefaultskey]];
                }
               
                [self messageToast:languageStr(@"wallet_create_success")];
                [[AppDelegate appDelegate] loginSuccessVc];
            }else{//密码错误
                passwordView.tipLabel.text = @"Password error";
        
                [passwordView setDotsViewHidden];
                [passwordView clickOnceButton];
            }
            
        }
        
        

   });
}


-(NSString*)getUserDefaultskey{
    NSString *type;
    if (self.walletType == 2) {
        type = @"SAVE";
    }else{
        type = @"";
    }
    
    if (self.walletChain == 1) {//SOL
        return [NSString stringWithFormat:@"%@%@",type,@"SOLWalletList"];
    }else if (self.walletChain == 2){//BNB
        return [NSString stringWithFormat:@"%@%@",type,@"BNBWalletList"];
    }else if (self.walletChain == 3){//ETH
        return [NSString stringWithFormat:@"%@%@",type,@"ETHWalletList"];
    }else if (self.walletChain == 4){//BTC
        return [NSString stringWithFormat:@"%@%@",type,@"BTCWalletList"];
    }
    return @"";
}

-(NSMutableArray *)selectBtnArr{
    if (!_selectBtnArr) {
        _selectBtnArr = [NSMutableArray new];
    }
    return _selectBtnArr;;
}
@end
