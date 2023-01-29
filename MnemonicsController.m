//
//  MnemonicsController.m
//  solanaWallet
//
//  Created by wang on 2021/12/2.
//  Copyright © 2021 wang. All rights reserved.
//

#import "MnemonicsController.h"
#import "MnemonicsWordCell.h"
#import "VerificationMnemonicsController.h"
#import "ASolanaWallet-Swift.h"
@class BTCMnemonic;
@interface MnemonicsController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;
@property (weak, nonatomic) IBOutlet UILabel *tips1;
@property (weak, nonatomic) IBOutlet UILabel *tips2;
@property (weak, nonatomic) IBOutlet UILabel *tips3;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic,strong) NSArray *words;
@property (nonatomic,strong) NSDictionary *walletObj;

@property (weak, nonatomic) IBOutlet UILabel *tipTitle;
@property (weak, nonatomic) IBOutlet UILabel *tipDes;


@property (nonatomic,strong) OCBridgeSwift *pair;

@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;

@end

@implementation MnemonicsController

- (void)dealloc{
    notification_remove(self, @"XMNotification", nil);
    notification_remove(self, @"BNBMmemonicsNot", nil);
    notification_remove(self, @"BNBcreateNot", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.blackColor;
    
    self.navigationView.backgroundColor = UIColorFromHexA(0x17161E, 1);
    self.navigationView.backgroundView.backgroundColor = UIColorFromHexA(0x17161E, 1);
    //self.navigationView.titleLabel.text = @"Add Wallet";
    self.navigationView.titleLabel.textColor = UIColor.whiteColor;
    [self.tips1 setBoundOfRadius:4];
    [self.tips2 setBoundOfRadius:4];
    [self.tips3 setBoundOfRadius:4];
    [self.bgView setBoundOfRadius:10];
    
    [self.confirmBtn setBoundOfRadius:10];
    [self.confirmBtn setTitleOfNormal:languageStr(@"backed_up")];
    self.navigationView.title = languageStr(@"create_a_wallet");
    self.tipTitle.text = languageStr(@"backup_mnemonics");
    self.tipDes.text = languageStr(@"they_are_correct");
    
    [self createSubViews];
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        self.view.backgroundColor = UIColorBlack;
        
        self.navigationView.titleLabel.textColor = UIColorWhite;
        self.statusBarStyle = UIStatusBarStyleLightContent;
        
        self.navigationView.backgroundColor = UIColorBlack;
        self.navigationView.backgroundView.backgroundColor = UIColorBlack;
        self.bgView.backgroundColor = UIColorBlack;
        self.tipTitle.textColor = UIColorWhite;
        self.tipDes.textColor = UIColorWhite;
        
        [self.bgView setBoundOfRadius:10 width:1 color:UIColorFromHex(0x707A93)];
        self.collectionView.backgroundColor = UIColorFromHex(0x707A93);
    }else{
        self.view.backgroundColor = UIColorFromHex(0xF9F9F9);
        
        self.navigationView.titleLabel.textColor = kTitleColor;
        
        self.statusBarStyle = UIStatusBarStyleDarkContent;
     
        self.navigationView.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.navigationView.backgroundView.backgroundColor = UIColorFromHex(0xF9F9F9);
        self.bgView.backgroundColor = UIColorWhite;
        self.tipTitle.textColor = kTitleColor;
        self.tipDes.textColor = UIColorFromHex(0xB7BED1);
        
        [self.bgView setBoundOfRadius:10 width:1 color:UIColorFromHex(0xE1E9FE)];
        self.collectionView.backgroundColor = UIColorFromHex(0xE1E9FE);
        
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiAction:) name:@"XMNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BNBMmemonicsNot:) name:@"BNBMmemonicsNot" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BNBcreateNot:) name:@"BNBcreateNot" object:nil];
    
   
    if (self.walletChain == 1) {//solana
        
        OCBridgeSwift *pair = [OCBridgeSwift new];
        self.pair = pair;
        [self.pair CreateWallet];
        
    }else if (self.walletChain == 2) {//BNB
        OCBridgeSwift *pair = [OCBridgeSwift new];
        self.pair = pair;
        [self.pair createBNBWalletWithChain:@"BNB"];
        
    }else if (self.walletChain == 3){//ETH
        OCBridgeSwift *pair = [OCBridgeSwift new];
        self.pair = pair;
        [self.pair createBNBWalletWithChain:@"ETH"];
    }
   

}


- (void)viewDidAppear:(BOOL)animated{
    
}
#pragma mark==BNB钱包创建回调
-(void)BNBcreateNot:(NSNotification *)not{
    NSLog(@"oc:%@",not.object);
    NSArray *array = not.object;
   
    self.words = [array[3] componentsSeparatedByString:@" "];
    
    NSArray *list ;
   if (self.walletChain == 2) {//BNB
        list =  [DTUserDefaults getArrayForKey:@"BNBWalletList"];
    }else if (self.walletChain == 3){//ETH
        list =  [DTUserDefaults getArrayForKey:@"ETHWalletList"];
    }
    
    NSDictionary *dic;
    NSDictionary *BNB = @{
        @"name": [array[0] isEqualToString:@"BNB"]?@"BNB":@"ETH",
        @"dec": @"Bsc",
        @"contractAdd":[array[0] isEqualToString:@"BNB"]?@"0xbb4cdb9cbd36b01bd1cbaebf2de08d9173bc095c":@"0x2170Ed0880ac9A755fd29B2688956BD959F933F8",
        @"logoUrl": [array[0] isEqualToString:@"BNB"]?@"https://bscscan.com/images/gen/binance_20.png":@"Ethereum",
        @"decimals": @18
    };
    
    if ([array[0] isEqualToString:@"BNB"]) {
        if (list.count) {
            dic = @{@"address":array[1],@"SecretKey":array[2],@"Mnemonics":self.words,@"name":[NSString stringWithFormat:@"%@%ld",languageStr(@"BNB_wallet"),list.count+1],@"isSelect":@"0",@"coin":@"BNB",@"tokenList":@[BNB]};
           
        }else{
            dic = @{@"address":array[1],@"SecretKey":array[2],@"Mnemonics":self.words,@"name":[NSString stringWithFormat:@"%@%d",languageStr(@"BNB_wallet"),1],@"isSelect":@"1",@"coin":@"BNB",@"tokenList":@[BNB]};
        }
    }else{//ETH
        if (list.count) {
            dic = @{@"address":array[1],@"SecretKey":array[2],@"Mnemonics":self.words,@"name":[NSString stringWithFormat:@"%@%ld",languageStr(@"ETH_wallet"),list.count+1],@"isSelect":@"0",@"coin":@"ETH",@"tokenList":@[BNB]};
           
        }else{
            dic = @{@"address":array[1],@"SecretKey":array[2],@"Mnemonics":self.words,@"name":[NSString stringWithFormat:@"%@%d",languageStr(@"ETH_wallet"),1],@"isSelect":@"1",@"coin":@"ETH",@"tokenList":@[BNB]};
        }
    }
    
    
    
    
    
    self.walletObj = dic;
    [self hideIndicator];
}


-(void)notiAction:(NSNotification *)sender{
    NSLog(@"oc:%@",sender.object);
    NSArray *array = sender.object;
    self.words = array[2];
    
    NSArray *list =  [DTUserDefaults getArrayForKey:@"SOLWalletList"];
    NSDictionary *dic;
   
   
    if (list.count) {
        dic = @{@"address":array[0],@"SecretKey":array[1],@"Mnemonics":array[2],@"name":[NSString stringWithFormat:@"%@%ld",languageStr(@"SOL_wallet"),list.count+1],@"isSelect":@"0",@"coin":@"SOL",@"tokenList":[self readLocalFileWithName:@"solana.default"]};
       
    }else{
        dic = @{@"address":array[0],@"SecretKey":array[1],@"Mnemonics":array[2],@"name":[NSString stringWithFormat:@"%@%d",languageStr(@"SOL_wallet"),1],@"isSelect":@"1",@"coin":@"SOL",@"tokenList":[self readLocalFileWithName:@"solana.default"]};
    }
    
    
    
    self.walletObj = dic;
    [self.collectionView reloadData];
}

#pragma mark==BNB助记词
-(void)BNBMmemonicsNot:(NSNotification *)not{
    
    NSArray * obj = not.object;
    
    
    self.words = [obj[1] componentsSeparatedByString:@" "];
    //回到主线程
    dispatch_async(dispatch_get_main_queue(), ^{
       // UI更新代码
        [self.collectionView reloadData];
        [self indicatorView];
    });
    
}


- (IBAction)confirmAction:(UIButton *)sender {
    VerificationMnemonicsController *vc = [[VerificationMnemonicsController alloc] init];
    vc.navigationType = NavigationTypeWhite;
    vc.words = self.words;
    vc.walletObj = self.walletObj;
    vc.walletChain = self.walletChain;
    vc.walletType = self.walletType;
    [self pushViewController:vc loginFlag:NO animated:YES];
}

//换一组
- (IBAction)refreshWordsAction:(UIButton *)sender {
    
    [self.pair callBridge];
}



-(void)createSubViews{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = 1;
    layout.minimumInteritemSpacing = 1;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColorFromHexA(0x000000, 0);
    
    [self.bgView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
     
        make.top.left.right.bottom.mas_equalTo(self.bgView);
    }];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"MnemonicsWordCell" bundle:nil] forCellWithReuseIdentifier:@"MnemonicsWordCell"];
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.collectionView reloadData];
}


#pragma mark - UICollectionViewDataSource/UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
   
    return self.words.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MnemonicsWordCell *item = [MnemonicsWordCell MnemonicsWordCell:collectionView indexPath:indexPath ];
    item.num.text = [NSString stringWithFormat:@"%ld",indexPath.item+1];
    item.name.text = self.words[indexPath.item];
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        item.bgView.backgroundColor = UIColorBlack;
        item.name.textColor = UIColor.whiteColor;
        item.num.textColor = UIColorFromHex(0x41424D);
    }else{
        item.bgView.backgroundColor = UIColor.whiteColor;
        item.name.textColor = kTitleColor;
        item.num.textColor = UIColorFromHex(0xB4B7CA);
    }
    
    return item;
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
 
    CGFloat width = (kScreenWidth- 46) / 3;
    return CGSizeMake(floor(width), 60);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  
    return UIEdgeInsetsMake(K_WIDTH(1),1, K_WIDTH(1), 1);
    
}

//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//
//    return CGSizeMake(kScreenWidth,0);
//}
//
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footerView" forIndexPath:indexPath];
//   // header.backgroundColor = UIColor.greenColor;
//    UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(15, 12, kScreenWidth-30, K_WIDTH(75))];
//    imageV.image = kImage(@"home_03");
//    [header addSubview:imageV];
//    return header;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
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

@end
