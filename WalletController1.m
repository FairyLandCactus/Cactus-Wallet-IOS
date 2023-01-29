//
//  WalletController.m
//  solanaWallet
//
//  Created by wang on 2021/11/4.
//

#import "WalletController1.h"
//#import <Curve25519.h>
//#import "Ed25519.h"
#import "HBlayoutButton.h"
#import "WalletHomeCell.h"
#import "ManageWalletView.h"
#import "AddWalletController.h"
#import "CollectionCoinController.h"
#import "ManageWalletController.h"

#import "SelectCoinView.h"
#import "SOLTransferController.h"
#import "AddTokensController.h"
#import "AFHTTPSessionManager+Synchronous.h"
#import "ASolanaWallet-Swift.h"

#import "CoinDetailsController.h"
#import "ApiServer.h"

//#import "CoreBitcoin.h"
@interface WalletController1 ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *hiddenBtn;
@property (weak, nonatomic) IBOutlet UIView *cardView;
//@property (weak, nonatomic) IBOutlet HBlayoutButton *transferBtn;
@property (weak, nonatomic) IBOutlet UILabel *money;
@property (weak, nonatomic) IBOutlet UIView *minddleView;
@property (nonatomic,strong) NSMutableArray *list;

@property (weak, nonatomic) IBOutlet UIButton *walletManageBtn;
@property (weak, nonatomic) IBOutlet UIButton *colorBtn;

@property (weak, nonatomic) IBOutlet UILabel *myAssets;

//@property (weak, nonatomic) IBOutlet HBlayoutButton *scanBtn;
@property (weak, nonatomic) IBOutlet HBlayoutButton *seedBtn;
@property (weak, nonatomic) IBOutlet HBlayoutButton *collectionBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *assetsWidth;
///全部资产
@property (weak, nonatomic) IBOutlet HBlayoutButton *allAssets;
///添加代币
@property (weak, nonatomic) IBOutlet HBlayoutButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *myWallet;

@property (weak, nonatomic) IBOutlet UILabel *traffic;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (weak, nonatomic) IBOutlet UILabel *address;

@property (nonatomic,strong) NSMutableArray *tokensList;
@property (nonatomic,strong) NSArray *tokenListData;
@property (nonatomic,strong) NSArray *addressList;
@property (nonatomic,assign) double solPrice;

@property (nonatomic,strong) OCBridgeSwift *pair;

@property (nonatomic,strong) NSDictionary *currentWallet;
@property (nonatomic,strong) NSString *BNBBalance;
@property (nonatomic,assign) NSInteger WalletChain;

@property (nonatomic,strong) NSString *wSol;
@property (nonatomic,strong) NSString *wSolToken;
@end

@implementation WalletController1
-(void)dealloc{
    notification_remove(self, @"checkBNBBalance", nil);
    notification_remove(self, @"checkTokenBalance", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSOL_USDTPrice];
    [self createSubViews];
    
    
    self.BNBBalance = @"0.00";
    [self.myWallet setBoundOfRadius:17];
    [self.myWallet setTitleOfNormal:languageStr(@"my_wallet")];
    
    
    self.navigationView.hidden = YES;
    
    [self.hiddenBtn setTitleOfNormal:@""];
    [self.cardView setBoundOfRadius:8];
    
    [self.walletManageBtn setTitleOfNormal:languageStr(@"AppWallet")];
    self.myAssets.text = languageStr(@"my_assets");
    
    //[self.scanBtn setTitleOfNormal:languageStr(@"Scan")];
    [self.seedBtn setTitleOfNormal:languageStr(@"transfer")];
    [self.collectionBtn setTitleOfNormal:languageStr(@"collection")];

    //[self.scanBtn setImageOfNormal:@"Scan_B"];
    [self.seedBtn setImageOfNormal:@"transfer_B"];
    [self.collectionBtn setImageOfNormal:@"collection_B"];
    
    [self.allAssets setTitleOfNormal:languageStr(@"all_assets")];
    [self.addBtn setTitleOfNormal:languageStr(@"add_currency")];
    
    CGFloat width = [languageStr(@"my_assets") widthWithFont:kFont_Medium(18) constrainedToHeight:20];
    
    self.assetsWidth.constant = width +6;
    
    
    
    NSArray* colors = @[(id)UIColorFromHex(0x70A0FF).CGColor,(id)UIColorFromHex(0x485BFF).CGColor];
    self.cardView.backgroundColor = [UIColor gradientColorWith:colors type:kGradientChangeDirectionVertical size:CGSizeMake(SCREEN_WIDTH-30, 158)];
    
   // notification_add(self, @selector(checkBNBBalance:), @"checkBNBBalance", nil);
    notification_add(self, @selector(checkTokenBalance:), @"checkTokenBalance", nil);
    //删除钱包后刷新数据
    notification_add(self, @selector(setSelectWalletAddress), @"KRefreshWallet", nil);
    [self setSelectWalletAddress];
   

   
}


#pragma mark====选择钱包后回调
-(void)setSelectWalletAddress{
    self.WalletChain = [DTUserDefaults getIntegerForkey:@"KWalletChain"];
    NSArray *array ;
    if (self.WalletChain == 1) {
        array = [DTUserDefaults getArrayForKey:@"SAVESOLWalletList"];
    }else if (self.WalletChain == 2){
        array = [DTUserDefaults getArrayForKey:@"SAVEBNBWalletList"];
    }else if (self.WalletChain == 3){
        array = [DTUserDefaults getArrayForKey:@"SAVEETHWalletList"];
    }else if (self.WalletChain == 4){
        array = [DTUserDefaults getArrayForKey:@"SAVEBTCWalletList"];
    }
    self.money.text  = @"0.0000 USDT";
    self.wSol = @"0.00";
    self.wSolToken = @"0.00";
    //有钱包的时候显示地址
    if (array.count) {
        //[self indicatorView];
        for (NSDictionary *obj in array) {
            if ([obj[@"isSelect"] intValue]) {
                self.address.text = obj[@"address"];
                [self.myWallet setTitleOfNormal:obj[@"name"]];
                //当前选择的钱包
                self.currentWallet = obj;
                //查询币美元价格
                [self loadCoinTokenPrice];
                
                if ([obj[@"name"] containsString:@"BNB"]) {//币安
                    OCBridgeSwift *pair = [OCBridgeSwift new];
                    self.pair = pair;
                    [self.list removeAllObjects];
                    [self.list addObject:@{@"tokenName":@"BNB",@"tokenIcon":@"wallet_69",@"Balance":self.BNBBalance}];
                    [self.tableView reloadData];
                    dispatch_queue_t queue = dispatch_queue_create("check_Balance", DISPATCH_QUEUE_CONCURRENT);
                    dispatch_async(queue, ^{
                        
                        //查BNB余额
                        [self loadBNB_Balance:obj[@"address"]];
                        
                        [self.list removeAllObjects];
                        [self.list addObjectsFromArray:self.currentWallet[@"tokenList"]];
                        for (NSDictionary*wallet in self.list) {
                            if (![wallet[@"name"] isEqualToString:@"BNB"]) {
                                //查代币余额
                                [self loadBEP20_Token_Balance:obj[@"address"] contract:wallet[@"contractAdd"]];
                            }
                            
                        }
                        
                        
                    });
                    
                    
                    
                }else{
                    [self.list removeAllObjects];
                    [self.list addObjectsFromArray:self.currentWallet[@"tokenList"]];
                    [self loadWalletData];
                    
                    [self loadTokenList];
                   
                       
                    [self.tableView reloadData];
                
                }
                
                
            }
        }
    }else{
        //没有钱包时显示空
        self.address.text = @"";
        [self.list removeAllObjects];
        self.money.text  = @"0.0000 USDT";
        [self.myWallet setTitleOfNormal:languageStr(@"my_wallet")];
        [self.tableView reloadData];
    }
}


#pragma mark===BNB查余额通知
//-(void)checkBNBBalance:(NSNotification *)not{
//    self.BNBBalance = not.object;
//    dispatch_async(dispatch_get_main_queue(), ^{
//       // UI更新代码
//        [self.tableView reloadData];
//    });
//
//}

-(void)checkTokenBalance:(NSNotification *)not{
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary: not.object];

  //  NSLog(@"%@",dic[@"contractAdd"]);
    
    NSMutableArray *tokenList = [NSMutableArray arrayWithArray:self.list];
    
    for (NSDictionary * wallet in tokenList) {
        
        NSMutableDictionary *newWallet = [NSMutableDictionary dictionaryWithDictionary:wallet];
        if ([wallet[@"contractAdd"] isEqualToString:dic[@"contractAdd"]]) {
            [tokenList removeObject:wallet];
            [newWallet setValue:dic[@"balance"]forKey:@"balance"];
            [tokenList addObject:newWallet];
            break;
        }
        
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[DTUserDefaults getArrayForKey:@"SAVEBNBWalletList"]];
    
    for (NSDictionary *dic in array) {
        NSMutableDictionary *mubDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        if ([dic[@"address"] isEqualToString:self.currentWallet[@"address"]]) {
            [array removeObject:dic];
            [mubDic setValue:tokenList forKey:@"tokenList"];
            [array addObject:mubDic];
            break;
        }
    }
    
    [DTUserDefaults setArray:array key:@"SAVEBNBWalletList"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
       // UI更新代码
        [self.tableView reloadData];
    });
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        self.view.backgroundColor = UIColorBlack;
        self.tableView.backgroundColor = UIColorBlack;
        [self.colorBtn setImageOfNormal:@"Frame_B"];
        [self.walletManageBtn setColorOfNormal:UIColor.whiteColor];
        self.statusBarStyle = UIStatusBarStyleLightContent;
        
        [AppDelegate appDelegate].tabbarVC.mainTabBar.backgroundColor = UIColorBlack;
    }else{
        self.view.backgroundColor = UIColorWhite;
        self.tableView.backgroundColor = UIColorWhite;
        [self.colorBtn setImageOfNormal:@"Frame_W"];
        [self.walletManageBtn setColorOfNormal:kTitleColor];
        self.statusBarStyle = UIStatusBarStyleDarkContent;
        [AppDelegate appDelegate].tabbarVC.mainTabBar.backgroundColor = UIColorWhite;
    }
    [self.tableView reloadData];
    self.shouldDisplay = YES;
    self.placeholderType = YHNoData;
   // self.tokensList = [DTUserDefaults getArrayForKey:@"AddTokenList"];
    [self loadSOL_USDTPrice];
    
    
}


-(void)createSubViews{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.minddleView.mas_bottom).mas_offset(0);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark=====我的钱包管理
- (IBAction)manageWalletAction:(UIButton *)sender {
    ManageWalletView *walletView = [[ManageWalletView alloc] initManageWalletView:2];
    walletView.selectWallet = ^{
        [self.list removeAllObjects];
        [self setSelectWalletAddress];
    };
    
    [walletView show];
#pragma mark=====添加钱包
    [walletView.addBtn touchUpInside:^{
        
        AddWalletController *addVc = [[AddWalletController alloc] init];
        addVc.index = 20;
        addVc.navigationType = NavigationTypeWhite;
        [walletView dismiss];
        [self pushViewController:addVc loginFlag:NO animated:YES];
    }];
#pragma mark=====钱包管理
    [walletView.mangaeBtn touchUpInside:^{
        [walletView dismiss];
        ManageWalletController * vc = [[ManageWalletController alloc] init];
        vc.index = 20;
        vc.walletType = 2;
        vc.navigationType = NavigationTypeWhite;
        [self pushViewController:vc loginFlag:NO animated:YES];
    }];
}


- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return self.shouldDisplay;
}



#pragma mark - UITableViewDataSource, UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
   
    return 1;//self.tokenListData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSDictionary *obj = self.list[indexPath.row];
    WalletHomeCell *cell = [WalletHomeCell WalletHomeCell:tableView WalletData:@{}];
    
    if ([self.currentWallet[@"coin"] containsString:@"BNB"]) {
        if (indexPath.row == 0) {
            cell.coinImg.image = kImage(@"wallet_69");
            cell.coin.text = @"BNB";
            cell.coinNum.text = self.BNBBalance;
            cell.usMoney.text  = @"0.000USDT";
        }else{
            
            [cell.coinImg sd_setImageWithURL:[NSURL URLWithString:obj[@"logoUrl"]] placeholderImage:kImage(@"wallet_58")];
            cell.coin.text = obj[@"name"];
            cell.coinNum.text = [NSString stringWithFormat:@"%.5f",[obj[@"balance"] doubleValue]];
            cell.usMoney.text  = @"0.000USDT";
        }
        
    }else{
    
    //没名称没图标
    if (kStringIsEmpty(obj[@"tokenIcon"]) && kStringIsEmpty(obj[@"tokenName"]) ) {
        cell.coinImg.image = kImage(@"wallet_58");
        cell.coin.text = obj[@"tokenAddress"];
        
        if (!kStringIsEmpty(obj[@"name"])){
            cell.coinImg.image = kImage(obj[@"symbol"]);
            cell.coin.text = obj[@"symbol"];
        }
        if ([obj[@"tokenAddress"] isEqualToString:@"AL1KoU6BLTuGM6hKgdezDqqmgM84yALFFF4oc3sZiWwT"]) {
            cell.coinImg.image = kImage(@"TEST");
            cell.coin.text = @"TEST";
        }
        
        
    }else if (kStringIsEmpty(obj[@"tokenIcon"])  ) {//没图标
        cell.coinImg.image = kImage(@"wallet_58");
        if (!kStringIsEmpty(obj[@"logoURI"])) {
            cell.coinImg.image = kImage(obj[@"logoURI"]);
        }
        cell.coin.text = obj[@"tokenName"];
        if ([obj[@"tokenName"] isEqualToString:@"IVE"]) {
            cell.coinImg.image = kImage(obj[@"tokenName"]);
        }
        
    }else if (kStringIsEmpty(obj[@"tokenName"])){//没名称
        cell.coinImg.image = kImage(@"wallet_58");
        cell.coin.text = obj[@"tokenAddress"];
    }else{
        
        
        cell.coin.text = kStringIsEmpty(obj[@"tokenName"])?obj[@"name"]:obj[@"tokenName"];
        NSString *imgUrl = kStringIsEmpty(obj[@"tokenIcon"])?obj[@"logoURI"]:obj[@"tokenIcon"];
       // NSLog(@"imgUrl===================%@",obj);
        if (imgUrl.length < 10) {
            cell.coinImg.image = kImage(imgUrl);
            
        }else{
               
            [cell.coinImg sd_setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:kImage(@"wallet_58")];
            if ([imgUrl containsString:@"Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB"]) {
                cell.coinImg.image = kImage(@"USDT");
            }
        }
       
    }
        
        
    
    if ([obj[@"tokenName"] isEqualToString:@"Wrapped SOL"]) {
            NSDictionary *amount = obj[@"tokenAmount"];
            cell.coinNum.text = [NSString stringWithFormat:@"%@",amount[@"uiAmount"]];
            cell.usMoney.text = [NSString stringWithFormat:@"≈%.4fUSDT",[amount[@"uiAmount"] doubleValue] *self.solPrice];
            self.wSol = [NSString stringWithFormat:@"%.5f",[amount[@"uiAmount"] doubleValue] *self.solPrice];
            self.wSolToken = [NSString stringWithFormat:@"%.5f",[obj[@"lamports"] doubleValue]/1000000000 *self.solPrice];
    }else if ([obj[@"tokenName"] isEqualToString:@"SOL"]) {
        cell.coinNum.text = [NSString stringWithFormat:@"%.4f",[obj[@"lamports"] doubleValue]/1000000000];
        cell.usMoney.text = [NSString stringWithFormat:@"≈%.4fUSDT",[obj[@"lamports"] doubleValue]/1000000000 *self.solPrice];
        NSString *money = [NSString stringWithFormat:@"%.4f USDT",([obj[@"lamports"] doubleValue]/1000000000 *self.solPrice + [self.wSol doubleValue])];
        self.money.text = money;
        
    }else if ([obj[@"tokenName"] isEqualToString:@"USDT"]|| [obj[@"tokenName"] isEqualToString:@"USD Coin"]) {
        NSDictionary *amount = obj[@"tokenAmount"];
        cell.coinNum.text = [NSString stringWithFormat:@"%.4f",[amount[@"uiAmountString"] doubleValue]];
        cell.usMoney.text = @"≈0.0000USDT";
    }else {
       
        NSDictionary *amount = obj[@"tokenAmount"];
        if (kStringIsEmpty(amount[@"uiAmountString"]) || [amount[@"uiAmountString"] isEqualToString:@"0"]) {
            cell.coinNum.text = @"0.0000";
        }else{
            cell.coinNum.text = [NSString stringWithFormat:@"%@",amount[@"uiAmountString"] ];
        }
        
        cell.usMoney.text = @"≈0.0000USDT";
       
    }
        
    }
   
    
    cell.backgroundColor =  self.view.backgroundColor;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
     return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
     return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
   
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    view.backgroundColor = UIColorFromHexA(0x000000, 0);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    CoinDetailsController *vc = [[CoinDetailsController alloc] init];
    NSDictionary *wallet = self.list[indexPath.row];
    vc.wallet = wallet;
    vc.tokenList = self.list;
    vc.WalletChain = self.WalletChain;
    vc.currentWallet = self.currentWallet;
    vc.navigationType = NavigationTypeWhite;
    [self pushViewController:vc loginFlag:NO animated:YES];
    
    
//    CoinDetailsController *vc = [[CoinDetailsController alloc] init];
//    //vc.navigationType = NavigationTypeWhite;
//    NSDictionary *obj = self.list[indexPath.row];
//    vc.walletObj = obj;
//    vc.wallet = self.currentWallet;
//    vc.Balance = self.BNBBalance;
//    [self pushViewController:vc loginFlag:NO animated:YES];
    
}


#pragma mark===添加代币
- (IBAction)addTokensAction:(UIButton *)sender {
    
    
    if (self.WalletChain&&self.list.count) {
        AddTokensController *vc = [[AddTokensController alloc] init];
        vc.leftSelect = self.WalletChain-1;
        vc.selectWalletData = self.currentWallet;
        vc.navigationType = NavigationTypeWhite;
        [self pushViewController:vc loginFlag:NO animated:YES];
    }else{
        
        [self messageToast:languageStr(@"no_wallet")];
    }
    
    
    
}


#pragma mark===扫描
- (IBAction)scanAction:(UIButton *)sender {
    
}

#pragma mark====转账
- (IBAction)transfer:(UIButton *)sender {
    
    
   
    if (self.WalletChain&&self.list.count) {
       
        SelectCoinView *showView = [[SelectCoinView alloc] initSelectCoinView:self.list];
        [showView show];
        showView.wallet = self.currentWallet;
        __weak SelectCoinView *show = showView;
        showView.selectCoin = ^(NSDictionary * _Nonnull wallet) {
            [show dismiss];
            SOLTransferController *vc = [[SOLTransferController alloc] init];
           
            vc.wallet = wallet;
            vc.tokenList = self.list;
            vc.WalletChain = self.WalletChain;
            vc.currentWallet = self.currentWallet;
            vc.navigationType = NavigationTypeWhite;
            [self pushViewController:vc loginFlag:NO animated:YES];
        };
        
        showView.addToken = ^{
            //添加代币
            AddTokensController *vc = [[AddTokensController alloc] init];
            [show dismiss];
            vc.navigationType = NavigationTypeWhite;
            [self pushViewController:vc loginFlag:NO animated:YES];
        };
    
        
    }else{
        
        [self messageToast:languageStr(@"no_wallet")];
    }
    
    
    
    
}




#pragma mark====收款
- (IBAction)CollectionAction:(UIButton *)sender {
    

    
    if (self.WalletChain&&self.list.count) {
       
        SelectCoinView *showView = [[SelectCoinView alloc] initSelectCoinView:self.list];
        [showView show];
        showView.wallet = self.currentWallet;
        __weak SelectCoinView *show = showView;
        showView.selectCoin = ^(NSDictionary * _Nonnull wallet) {
            [show dismiss];
            
            CollectionCoinController *vc = [[CollectionCoinController alloc] init];
            vc.navigationType = NavigationTypeWhite;
            vc.wallet = wallet;
            vc.WalletChain = self.WalletChain;
            vc.currentWallet = self.currentWallet;
            [self pushViewController:vc loginFlag:NO animated:YES];
            
        };
        
        
    }else{
        
            [self messageToast:languageStr(@"no_wallet")];
        }
    
   
    
}


#pragma mark===隐藏金额
- (IBAction)hiddenAction:(UIButton *)sender {
    
}

#pragma mark====背景颜色
- (IBAction)mangaeAction:(UIButton *)sender {
  //  NSLog(@"点击了==========");
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        [DTUserDefaults setString:@"W" key:@"KBGColor"];
    }else{
        [DTUserDefaults setString:@"B" key:@"KBGColor"];
    }
   // [self indicatorView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
       
        
        NSString *colorStr1 = [DTUserDefaults getStringForKey:@"KBGColor"];
        if ([colorStr1 isEqualToString:@"W"]) {
            
            self.view.backgroundColor = UIColorWhite;
            self.tableView.backgroundColor = UIColorWhite;
            [self.colorBtn setImageOfNormal:@"Frame_W"];
            [self.walletManageBtn setColorOfNormal:kTitleColor];
            
            self.statusBarStyle = UIStatusBarStyleDarkContent;
            [AppDelegate appDelegate].tabbarVC.mainTabBar.backgroundColor = UIColorWhite;
            [AppDelegate appDelegate].tabbarVC.mainTabBar.line.backgroundColor = UIColorFromHex(0xf3f5f7);
        }else{
            
            self.view.backgroundColor = UIColorBlack;
            self.tableView.backgroundColor = UIColorBlack;
            [self.colorBtn setImageOfNormal:@"Frame_B"];
            [self.walletManageBtn setColorOfNormal:UIColor.whiteColor];
            self.statusBarStyle = UIStatusBarStyleLightContent;
            [AppDelegate appDelegate].tabbarVC.mainTabBar.backgroundColor = UIColorBlack;
            [AppDelegate appDelegate].tabbarVC.mainTabBar.line.backgroundColor = UIColorFromHex(0x2F3545);
            
        }
        [self.tableView reloadData];
        [self hideIndicator];
    });
    
    
   
    
//    ManageWalletController * vc = [[ManageWalletController alloc] init];
//    vc.navigationType = NavigationTypeWhite;
//    [self pushViewController:vc loginFlag:NO animated:YES];
}


#pragma mark====钱包获取资产
-(void)loadWalletData{
    NSString *url = [NSString stringWithFormat:@"https://api.solscan.io/account?address=%@",self.address.text];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error = nil;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSDictionary *result = [manager syncGET:url
                               parameters:@{}
                                  headers:@{}
                                     task:NULL
                                    error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.count) {
                NSDictionary *data = result[@"data"];
                if (data.count > 2) {
                    
                    NSDictionary *obj = @{@"tokenAddress":data[@"account"],@"tokenName":@"SOL",@"tokenIcon":@"SOL",@"lamports":data[@"lamports"],@"decimals": @9};
                    [self.list insertObject:obj atIndex:0];
                    
                }else{
                    NSDictionary *obj = @{@"tokenAddress":data[@"account"],@"tokenName":@"SOL",@"tokenIcon":@"SOL",@"lamports":@"0",@"decimals": @9};
                    [self.list insertObject:obj atIndex:0];
                }
                
               
               
            }
            
            [self.tableView reloadData];
            [self hideIndicator];
        });
        
        
    });

    
    
}



#pragma mark====获取代币价格列表
-(void)loadTokenList{
    
    NSString *url = [NSString stringWithFormat:@"https://api.solscan.io/account/tokens?address=%@&price=1",self.address.text];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error = nil;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSDictionary *result = [manager syncGET:url
                               parameters:@{}
                                  headers:@{}
                                     task:NULL
                                    error:&error];
        

      
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *list1 = [[NSMutableArray alloc] initWithArray:result[@"data"]];
            if (list1.count) {

                NSArray *tokenList = self.currentWallet[@"tokenList"];
               // [self.list addObjectsFromArray:list];

                NSMutableArray *newArr = [NSMutableArray new];
                
//                for (int i = 0 ; i < list.count; i++) {
//                    NSDictionary *obj = list[i];
//                    NSString *name = obj[@"tokenName"];
//                    if (!kStringIsEmpty(obj[@"tokenName"])) {
//                        [newArr addObject:obj[@"tokenAddress"]];
//                    }else{
//                        [list removeObject:obj];
//                    }
//
//                }
                NSMutableArray *list = [NSMutableArray new];
                
                for (int i = 0 ; i < list1.count; i++) {
                    NSDictionary *obj = list1[i];
                    if (!kStringIsEmpty(obj[@"tokenName"])) {
                        [newArr addObject:obj[@"tokenAddress"]];
                        [list addObject:obj];
                    }
                    
                }
                
                
        
                for (int i = 0 ; i < tokenList.count; i++) {
                    NSDictionary *obj = tokenList[i];
                    NSString *tokenAddress = obj[@"tokenAddress"]?obj[@"tokenAddress"]:obj[@"address"];
                    //if (newArr.count < i) {
                        if (![newArr containsObject:tokenAddress]) {
                            [list addObject:obj];
                        }
                  //  }
                    
                }
                
               
                
                NSMutableArray *walletList = [NSMutableArray arrayWithArray:[DTUserDefaults getArrayForKey:@"SAVESOLWalletList"]];
                NSMutableArray *array = [NSMutableArray new];
                for (int i = 0; i < walletList.count ; i++) {
                    NSMutableDictionary *obj = [NSMutableDictionary dictionaryWithDictionary:walletList[i]];
                    if ([self.currentWallet[@"address"]  isEqualToString:obj[@"address"]]) {
                        
                        [obj setValue:list forKey:@"tokenList"];
                    }
                    [array addObject:obj];
                }
               
                
                [DTUserDefaults setArray:array key:@"SAVESOLWalletList"];
                
               
                
            }else{
                //新钱包没有代币
               // NSArray *tokenList = self.currentWallet[@"tokenList"];
                //[self.list addObjectsFromArray:tokenList];
            }
            
            [self.tableView reloadData];
            
            
        });
        
        
    });
    
    
}


#pragma mark=====
-(void)loadSOL_USDTPrice{
        NSString *url = @"https://api.solscan.io/market?symbol=SOL";
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSError *error = nil;
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            NSDictionary *result = [manager syncGET:url
                                   parameters:@{}
                                      headers:@{}
                                         task:NULL
                                        error:&error];
            

          
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result.count) {
                    NSString *priceUsdt = result[@"data"][@"priceUsdt"];
                    self.solPrice = [priceUsdt doubleValue];
                    
                    [DTUserDefaults setDouble:self.solPrice key:@"KSOL_USDTPrice"];
                    [self.tableView reloadData];
                    [self hideIndicator];
                }
                
              
            });
            
            
        });
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

#pragma mark=====获取BNB余额
-(void)loadBNB_Balance:(NSString*)address{
    
   // [self.pair checkBNBBalanceWithAddress:address];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *url = [NSString  stringWithFormat:@"https://api.bscscan.com/api?module=account&action=balance&address=%@&apikey=78NFN5UHK9FTYN6ZTSHZCK8IF5DV4W3JI5",self.currentWallet[@"address"]];
    
    NSError *error = nil;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *result = [manager syncGET:url
                           parameters:@{}
                              headers:@{}
                                 task:NULL
                                error:&error];
    
    if ([result[@"status"] intValue]) {
        self.BNBBalance = [NSString stringWithFormat:@"%f",[result[@"result"] integerValue]/1000000000000000000.0];
        [DTUserDefaults setString:self.BNBBalance key:@"KBNBBalance"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           // UI更新代码
            [self.tableView reloadData];
        });
    }
        
    });
}

#pragma mark=======查询币美元价格
-(void)loadCoinTokenPrice{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
  NSString *url = @"https://price.ius.finance/api/user/price/selectTokenPriceByIos";
    //NSString *url = @"http://192.168.0.105:8031/user/price/selectTokenPrice";
    
    NSString *chain ;
    
    if (self.WalletChain == 1) {
        chain = @"SOL";
    }else if (self.WalletChain == 2){
        chain = @"bsc";
    }else if (self.WalletChain == 3){
        chain = @"ETH";
    }
    
    NSArray *tokenList = self.currentWallet[@"tokenList"];
    NSMutableArray *list = [NSMutableArray new];
    
    for (NSDictionary*obj in tokenList) {
        NSString *tokenName = obj[@"tokenSymbol"]?obj[@"tokenSymbol"]:obj[@"tokenName"];
        
        if (kStringIsEmpty(tokenName)) {
            tokenName = obj[@"name"];
        }
        
        NSString *address = obj[@"tokenAddress"]?obj[@"tokenAddress"]:obj[@"address"];
        
        if (kStringIsEmpty(address)) {
            address = obj[@"contractAdd"];
        }
        
        [list addObject:@{@"slug":tokenName,@"tokenAddress":address}];
    }
       // NSDictionary *param = @{@"param":@{@"chain":chain,@"data":list}};
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"chain":chain,@"data":list} options:NSJSONWritingFragmentsAllowed error:nil];
        NSString *param = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        
        
        [ApiServer POST:url parameters:@{@"param":param} success:^(NetworkResultResponse *responseObject) {
            
            if (responseObject.code == 200) {
              
               
            }
           
        
        } failure:^(NetworkResultResponse *response) {
           // [self messageToast:@"服务器异常"];
        }];
        

//    NSError *error = nil;
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//
//        NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"POST" URLString:url parameters:@{@"param":param} error:nil];
//
//        request.timeoutInterval= 30;
//        //设置上传数据type
//        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
//        //设置接受数据type
//        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//
//        //将对象设置到requestbody中 ,主要是这不操作
//
//
//
//
//
//    NSDictionary *result = [manager syncPOST:url
//                                  parameters:@{@"param":param}
//                            headers:@{}
//                                 task:NULL
//                                error:&error];
//
//    if ([result[@"status"] intValue]) {
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//           // UI更新代码
//            [self.tableView reloadData];
//        });
//    }
    
        
    });
}


//将字典转换成json格式字符串,不含 这些符号

+ (NSString *)gs_jsonStringCompactFormatForDictionary:(NSDictionary *)dicJson {

    

    if (![dicJson isKindOfClass:[NSDictionary class]] || ![NSJSONSerialization isValidJSONObject:dicJson]) {

        return nil;

    }

    

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson options:0 error:nil];

    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return strJson;

}

//将数组转换成json格式字符串,不含 这些符号

+ (NSString *)gs_jsonStringCompactFormatForNSArray:(NSArray *)arrJson {

    

    if (![arrJson isKindOfClass:[NSArray class]] || ![NSJSONSerialization isValidJSONObject:arrJson]) {

        return nil;

    }

    

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:arrJson options:0 error:nil];

    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return strJson;

}

//将字典转换成json格式字符串,含 这些符号,便于阅读

+ (NSString *)gs_jsonStringPrettyPrintedFormatForDictionary:(NSDictionary *)dicJson {

    

    if (![dicJson isKindOfClass:[NSDictionary class]] || ![NSJSONSerialization isValidJSONObject:dicJson]) {

        return nil;

    }

    

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson options:NSJSONWritingPrettyPrinted error:nil];

    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return strJson;

}



-(void)loadBEP20_Token_Balance:(NSString *)address contract:(NSString*)contractAdd{
    [self.pair checkBEP20_TokenBalanceWithAddress:address contractAdd:contractAdd];
    
}


-(NSMutableArray *)list{
    if (!_list) {
        _list = [NSMutableArray new];
    }
    return _list;
}

@end
