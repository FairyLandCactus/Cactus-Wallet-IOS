//
//  CoinDetailsController.m
//  ASolanaWallet
//
//  Created by wang on 2022/10/25.
//

#import "CoinDetailsController.h"
#import "CoinDetailsToolView.h"
#import "CoinDetailsWeb3View.h"
#import "CoinDetailsAboutView.h"
#import "CoinDetailsRecordCell.h"
#import "TransferDetailsController.h"
#import "SOLTransferController.h"
#import "AFHTTPSessionManager+Synchronous.h"
#import "MyTools.h"
#import "CollectionCoinController.h"

@interface CoinDetailsController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *coinNum;
@property (weak, nonatomic) IBOutlet UIView *addressBgView;
@property (weak, nonatomic) IBOutlet UIView *topBgView;
@property (weak, nonatomic) IBOutlet UIView *typeBgView;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *toolBtn;
@property (weak, nonatomic) IBOutlet UIButton *assetsBtn;
@property (weak, nonatomic) IBOutlet UIButton *web3Btn;
@property (weak, nonatomic) IBOutlet UILabel *topLine;


@property (weak, nonatomic) IBOutlet UIImageView *coinImg;
@property (weak, nonatomic) IBOutlet UIButton *transferBtn;
@property (weak, nonatomic) IBOutlet UIButton *receiveBtn;
@property (weak, nonatomic) IBOutlet UIButton *exchangeBtn;
@property (weak, nonatomic) IBOutlet UILabel *coinName;
@property (weak, nonatomic) IBOutlet UILabel *coinPrice;
@property (weak, nonatomic) IBOutlet UILabel *gains;//涨幅
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;
@property (weak, nonatomic) IBOutlet UIView *bottomBgView;

@property (weak, nonatomic) IBOutlet UIView *middleBgView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLine1;
@property (weak, nonatomic) IBOutlet UILabel *bottomLine2;
@property (nonatomic,strong) NSArray *btnArray;

@property (nonatomic,strong) UIView *slidLine;
@property (nonatomic,strong) UIButton *selectBtn;
@property (nonatomic,strong) UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet UIScrollView *scrollview1;

@property (nonatomic,strong) CoinDetailsToolView *toolView;
@property (nonatomic,strong) CoinDetailsWeb3View *web3View;
@property (nonatomic,strong) CoinDetailsAboutView *aboutView;
@property (nonatomic,strong) NSMutableArray *list;
@property (nonatomic,assign) BOOL isTransfer;
@end

@implementation CoinDetailsController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    if ([self.currentWallet[@"coin"] containsString:@"BNB"]) {
        [self.coinImg sd_setImageWithURL:[NSURL URLWithString:self.wallet[@"logoUrl"]] placeholderImage:kImage(self.wallet[@"logoUrl"])];
        
        if ([self.wallet[@"name"] containsString:@"BNB"]) {
            self.navigationView.title = self.wallet[@"name"];
            self.coinNum.text = [DTUserDefaults getStringForKey:@"KBNBBalance"];
            self.address.text = self.currentWallet[@"address"];
            
        }else{
            self.navigationView.title = self.wallet[@"name"];
            self.coinNum.text = [NSString stringWithFormat:@"%.5f",[self.wallet[@"balance"] doubleValue]];
            self.address.text = self.wallet[@"contractAdd"];
            
        }
        
        
    }else if ([self.currentWallet[@"coin"] containsString:@"ETH"]) {
        [self.coinImg sd_setImageWithURL:[NSURL URLWithString:self.wallet[@"logoUrl"]] placeholderImage:kImage(self.wallet[@"logoUrl"])];
        
        if ([self.wallet[@"name"] containsString:@"ETH"]) {
            self.navigationView.title = self.wallet[@"name"];
            self.coinNum.text = [DTUserDefaults getStringForKey:@"KETHBalance"];
            self.address.text = self.currentWallet[@"address"];
            
        }else{
            self.navigationView.title = self.wallet[@"name"];
            self.coinNum.text = [NSString stringWithFormat:@"%.5f",[self.wallet[@"balance"] doubleValue]];
            self.address.text = self.wallet[@"contractAdd"];
            
        }
        
        
    }else{
        
        if ([self.wallet[@"tokenName"] containsString:@"SOL"]) {
            self.navigationView.title = self.wallet[@"tokenName"];
            self.coinNum.text = [NSString stringWithFormat:@"%.4f",[self.wallet[@"lamports"] doubleValue]/1000000000];;
            self.address.text = self.wallet[@"tokenAddress"];
            [self.coinImg sd_setImageWithURL:[NSURL URLWithString:self.wallet[@"tokenIcon"]] placeholderImage:kImage(self.wallet[@"tokenIcon"])];
        }else{
            NSDictionary *tokenAmount = self.wallet[@"tokenAmount"];
            if (tokenAmount) {
                self.navigationView.title = self.wallet[@"tokenName"];
                [self.coinImg sd_setImageWithURL:[NSURL URLWithString:self.wallet[@"tokenIcon"]] placeholderImage:kImage(self.wallet[@"tokenName"])];
                
                if ( [self.wallet[@"tokenAddress"] isEqualToString:@"AL1KoU6BLTuGM6hKgdezDqqmgM84yALFFF4oc3sZiWwT"]) {
                    self.navigationView.title = @"TEST";
                    self.coinImg.image = kImage(@"TEST");
                }
                
                self.coinNum.text = [NSString stringWithFormat:@"%.5f",[tokenAmount[@"amount"] doubleValue]/1000000000];;
                self.address.text = self.wallet[@"tokenAddress"];
            }else{
                self.navigationView.title = self.wallet[@"symbol"];
                [self.coinImg sd_setImageWithURL:[NSURL URLWithString:self.wallet[@"logoURI"]] placeholderImage:kImage(self.wallet[@"symbol"])];
                if ( [self.wallet[@"address"] isEqualToString:@"AL1KoU6BLTuGM6hKgdezDqqmgM84yALFFF4oc3sZiWwT"]) {
                    self.navigationView.title = @"TEST";
                    self.coinImg.image = kImage(@"TEST");
                }
                
                self.address.text = self.wallet[@"address"];
                self.coinNum.text = @"0.00";
            }
            
            
        }
       
        
        
    }
    
    
    
    
    
    [self.transferBtn setBoundOfRadius:4];
    [self.receiveBtn setBoundOfRadius:4];
    
    [self.addressBgView setBoundOfRadius:12];
    
    [self.recordBtn setTitleOfNormal:languageStr(@"transaction_record")];
    [self.toolBtn setTitleOfNormal:languageStr(@"Tool")];
    [self.assetsBtn setTitleOfNormal:languageStr(@"asset_introduction")];
    
    [self.transferBtn setTitleOfNormal:languageStr(@"transfer")];
    [self.receiveBtn setTitleOfNormal:languageStr(@"collection")];
    [self.exchangeBtn setTitleOfNormal:languageStr(@"exchange")];
    
    [self.typeBgView addSubview:self.slidLine];
    self.selectBtn = self.recordBtn;
    self.btnArray = @[self.recordBtn,self.toolBtn,self.assetsBtn,self.web3Btn];
    
    [self.middleBgView addSubview:self.scrollView];
    self.scrollView.delegate = self;
    
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(self.middleBgView);
    }];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // UI更新代码
        [self setSubViewsColor];
        [self indicatorView];
        }];
   
    if ([self.currentWallet[@"coin"] containsString:@"BNB"]) {
        
        if ([self.wallet[@"name"] isEqualToString:@"BNB"]) {
            [self loadBNBTransactionRecordsChain:@"BNB"];
        }else{
            
            [self loadBNBBEP20TokenTransactionRecordsChain:@"BNB"];
        }
        
    }else if([self.currentWallet[@"coin"] containsString:@"ETH"]) {
        
        if ([self.wallet[@"name"] isEqualToString:@"ETH"]) {
            [self loadBNBTransactionRecordsChain:@"ETH"];
        }else{
            
            [self loadBNBBEP20TokenTransactionRecordsChain:@"ETH"];
        }
        
    }else{
        
        if ([self.wallet[@"tokenName"] containsString:@"SOL"]) {
            [self loadSOLTransactionRecords];//sol记录查询
        }else{
            [self loadSOLTokenTransactionRecords];//sol代币记录查询
        }
       
        
        
    }
    
    
    
    
    
}

-(void)setSubViewsColor{
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        self.view.backgroundColor = UIColorFromHex(0x0A0C1A);
        
        self.navigationView.titleLabel.textColor = UIColorWhite;
        self.statusBarStyle = UIStatusBarStyleLightContent;
        
        self.navigationView.backgroundColor = UIColorBlack;
        self.navigationView.backgroundView.backgroundColor = UIColorBlack;
        self.topBgView.backgroundColor = UIColorBlack;
        self.tableView.backgroundColor = UIColorBlack;
        self.typeBgView.backgroundColor = UIColorBlack;
        self.bottomBgView.backgroundColor = UIColorBlack;
        self.topLine.backgroundColor = UIColorFromHex(0x252836);
        self.bottomLine1.backgroundColor = UIColorFromHex(0x252836);
        self.bottomLine2.backgroundColor = UIColorFromHex(0x252836);
        self.slidLine.backgroundColor = UIColorWhite;
        self.addressBgView.backgroundColor = UIColorFromHex(0x2C2F3E);
        self.coinNum.textColor = UIColorWhite;
        self.address.textColor = UIColorFromHex(0x8489A1);
        self.topBgView.backgroundColor = UIColorBlack;
        [self.exchangeBtn setBoundOfRadius:4 width:1 color:UIColorWhite];
        [self.exchangeBtn setColorOfNormal:UIColorWhite];
        [self.exchangeBtn setImageOfNormal:@"wallet_107"];
        [self.recordBtn setColorOfNormal:UIColorWhite];
        [self.assetsBtn setColorOfNormal:UIColorFromHex(0x5D6A84)];
        [self.toolBtn setColorOfNormal:UIColorFromHex(0x5D6A84)];
        [self.web3Btn setColorOfNormal:UIColorFromHex(0x5D6A84)];
        self.coinName.textColor = UIColorWhite;
        self.middleBgView.backgroundColor = UIColorBlack;
        
    }else{
        self.view.backgroundColor = UIColorFromHex(0xF0F2FE);
        
        self.navigationView.titleLabel.textColor = kTitleColor;
        
        self.statusBarStyle = UIStatusBarStyleDarkContent;
     
        self.navigationView.backgroundColor =UIColorWhite;
        self.navigationView.backgroundView.backgroundColor = UIColorWhite;
        
        self.tableView.backgroundColor = UIColorWhite;
        self.topLine.backgroundColor = UIColorFromHex(0xEEEFF6);
        self.bottomLine1.backgroundColor = UIColorFromHex(0xEEEFF6);
        self.bottomLine2.backgroundColor = UIColorFromHex(0xEEEFF6);
        self.slidLine.backgroundColor = kTitleColor;
        self.addressBgView.backgroundColor = UIColorFromHex(0xE9EBF5);
        self.coinNum.textColor = kTitleColor;
        self.address.textColor = UIColorFromHex(0x8C91AB);
        self.topBgView.backgroundColor = UIColorWhite;
        [self.exchangeBtn setBoundOfRadius:4 width:1 color:UIColorFromHex(0x9CB4C5)];
        [self.exchangeBtn setColorOfNormal:kTitleColor];
        [self.recordBtn setColorOfNormal:kTitleColor];
        [self.assetsBtn setColorOfNormal:UIColorFromHex(0x6E7A92)];
        [self.toolBtn setColorOfNormal:UIColorFromHex(0x6E7A92)];
        [self.web3Btn setColorOfNormal:UIColorFromHex(0x6E7A92)];
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UIColorFromHexA(0x000000, 0);
    [self.scrollView addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.scrollView addSubview:self.toolView];
    [self.scrollView addSubview:self.aboutView];
    [self.scrollView addSubview:self.web3View];
   // [self initMJRefresh];
    NSArray *array = @[self.tableView, self.toolView,self.aboutView,self.web3View];
    
    
    
    [array mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
   
    [array mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.height.mas_equalTo(K_WIDTH(390));
    }];
    
    self.shouldDisplay = YES;
    self.placeholderType = YHNoData;
}

- (void)initMJRefresh{
    
   //[self initMJRefresh_header];
    [self initMJRefresh_footer];
}

-(void)viewWillAppear:(BOOL)animated{
    
    

    
}
-(void)layoutSubviews{
    
}
#pragma mark - UITableViewDataSource, UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.list.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    NSDictionary *obj = self.list[indexPath.section];
    
    CoinDetailsRecordCell *cell = [CoinDetailsRecordCell CoinDetailsRecordCell:tableView ];
    
    if ([self.currentWallet[@"coin"] containsString:@"BNB"]) {
        
            NSString *from = obj[@"from"];
            NSString *to = obj[@"to"];
            NSString *value = obj[@"value"];
        
            if ([from isEqualToString:self.wallet[@"address"]]) {//转出
                cell.typeImg.image = kImage(@"wallet_116");
                cell.num.text = [NSString stringWithFormat:@"- %f",[value integerValue]/100000000000000000.0];
            
                cell.address.text = [NSString stringWithFormat:@"Transfer %@",to];
                self.isTransfer = YES;
            }else{////转入
                cell.typeImg.image = kImage(@"wallet_115");
                cell.num.text = [NSString stringWithFormat:@"+ %f",[value integerValue]/100000000000000000.0];
                cell.address.text = [NSString stringWithFormat:@"Collect %@",from];
            }
            cell.time.text = [MyTools timestampChangesTime:obj[@"timeStamp"] ];
            cell.price.text = @"≈0.0000USDT";
       
        
        
    }else if ([self.currentWallet[@"coin"] containsString:@"ETH"]) {
        
        NSString *from = obj[@"from"];
        NSString *to = obj[@"to"];
        NSString *value = obj[@"value"];
    
        if ([from isEqualToString:self.wallet[@"address"]]) {//转出
            cell.typeImg.image = kImage(@"wallet_116");
            cell.num.text = [NSString stringWithFormat:@"- %f",[value integerValue]/100000000000000000.0];
        
            cell.address.text = [NSString stringWithFormat:@"Transfer %@",to];
            self.isTransfer = YES;
        }else{////转入
            cell.typeImg.image = kImage(@"wallet_115");
            cell.num.text = [NSString stringWithFormat:@"+ %f",[value integerValue]/100000000000000000.0];
            cell.address.text = [NSString stringWithFormat:@"Collect %@",from];
        }
        cell.time.text = [MyTools timestampChangesTime:obj[@"timeStamp"] ];
        cell.price.text = @"≈0.0000USDT";
   
    
    
}else{
        
        if ([self.wallet[@"tokenName"] isEqualToString:@"SOL"]) {
            cell.time.text = [MyTools timestampChangesTime:obj[@"blockTime"] ];
            NSString *from = obj[@"src"];
            NSString *to = obj[@"dst"];
            NSString *value = obj[@"lamport"];
            
            if ([from isEqualToString:self.wallet[@"address"]]) {//转出
                cell.typeImg.image = kImage(@"wallet_116");
                self.isTransfer = YES;
                cell.num.text = [NSString stringWithFormat:@"- %f",[value doubleValue]/1000000000];
            
                cell.address.text = [NSString stringWithFormat:@"Transfer %@",to];
            
            }else{////转入
                cell.typeImg.image = kImage(@"wallet_115");
                cell.num.text = [NSString stringWithFormat:@"+ %f",[value doubleValue]/1000000000];
                cell.address.text = [NSString stringWithFormat:@"Collect %@",from];
            }
        }else{
            cell.time.text = [MyTools timestampChangesTime:obj[@"blockTime"] ];
            NSDictionary *change = obj[@"change"];
            NSString *value = change[@"changeAmount"];
            if ([change[@"changeType"] containsString:@"dec"]) {//转出
                cell.address.text  =@"Transfer";
                self.isTransfer = YES;
                cell.typeImg.image = kImage(@"wallet_116");
                cell.num.text = [NSString stringWithFormat:@" %f",[value doubleValue]/1000000000.00];
            }else{
                cell.typeImg.image = kImage(@"wallet_115");
                cell.address.text  =@"Collect";
                cell.num.text = [NSString stringWithFormat:@"+ %f",[value doubleValue]/1000000000.00];
            }
            
            
        }
       
        
        
    }
    

    cell.price.text = @"≈0.0000USDT";
    return cell;
}




- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
     return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
     return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
   
    UIView *view = [UIView new];
    view.backgroundColor = UIColorFromHex(0x131313);
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *obj = self.list[indexPath.section];
    TransferDetailsController *vc = [[TransferDetailsController alloc] init];
    vc.obj = obj;
    vc.coinObj = self.wallet;
    vc.isTransfer = self.isTransfer;
    [self pushViewController:vc loginFlag:NO animated:YES];
}



#pragma mark==
- (IBAction)copyAddress:(UIButton *)sender {
    [HBPublicManage stringToPasteBoard:self.wallet[@"address"]];
    
}

#pragma mark=====转账、收款、兑换
- (IBAction)transferAction:(UIButton *)sender {
    // 10 转账 20 接收 30 兑换
    if (sender.tag == 10) {
        SOLTransferController *vc = [[SOLTransferController alloc] init];
       
        vc.wallet = self.wallet;
        vc.tokenList = self.tokenList;
        vc.WalletChain = self.WalletChain;
        vc.currentWallet = self.currentWallet;
        vc.navigationType = NavigationTypeWhite;
        [self pushViewController:vc loginFlag:NO animated:YES];
    }else if (sender.tag == 20){
        
        CollectionCoinController *vc = [[CollectionCoinController alloc] init];
        vc.navigationType = NavigationTypeWhite;
        vc.wallet = self.wallet;
        vc.WalletChain = self.WalletChain;
        vc.currentWallet = self.currentWallet;
        [self pushViewController:vc loginFlag:NO animated:YES];
    }
}

- (IBAction)selectTypeAction:(UIButton *)sender {
    // 1 记录 2 工具 3 关于 4 web3
    
    NSString *colorStr = [DTUserDefaults getStringForKey:@"KBGColor"];
    if ([colorStr isEqualToString:@"B"]) {
        [self.selectBtn setColorOfNormal:UIColorFromHex(0x5D6A84)];
        [sender setColorOfNormal:UIColorWhite];
    }else{
        [self.selectBtn setColorOfNormal:UIColorFromHex(0x6E7A92)];
        [sender setColorOfNormal:kTitleColor];
    }
    
    self.selectBtn = sender;
    
    [UIView animateWithDuration:0.24 animations:^{
        self.slidLine.center = CGPointMake(sender.centerX,40);
        self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH*(sender.tag-1), 0);
    }];
    
    
}

- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate{
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView*)scrollView{
    //NSLog(@"scrollViewDidEndDecelerating");
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor(scrollView.contentOffset.x / pageWidth) + 1;
    
    [self selectTypeAction:self.btnArray[page-1]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
   
    
   
}

#pragma mark=====获取sol交易记录
-(void)loadSOLTransactionRecords{
    NSString *url = [NSString stringWithFormat:@"https://api.solscan.io/account/soltransfer/txs"];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error = nil;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSDictionary *result = [manager syncGET:url
                                     parameters:@{@"address":self.wallet[@"tokenAddress"],@"offset":@"1",@"limit":@"20"}
                                  headers:@{}
                                     task:NULL
                                    error:&error];
        

      
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *array = result[@"data"][@"tx"][@"transactions"];
            
            if (array.count) {
                self.list = [NSMutableArray arrayWithArray:array];
               
            }
           
        });
        //主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // UI更新代码
            [self endRefreshing];
            [self hideIndicator];
            [self.tableView reloadData];
            [self.tableView reloadData];
        }];
        
    });
}

#pragma mark=====获取sol代币交易记录
-(void)loadSOLTokenTransactionRecords{
    NSString *url = [NSString stringWithFormat:@"https://api.solscan.io/account/token/txs"];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *tokenAddress = self.wallet[@"tokenAddress"]?self.wallet[@"tokenAddress"]:self.wallet[@"address"];
        NSError *error = nil;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSDictionary *result = [manager syncGET:url
                                     parameters:@{@"address":tokenAddress,@"offset":@"1",@"limit":@"15"}
                                  headers:@{}
                                     task:NULL
                                    error:&error];
        

      
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *array = result[@"data"][@"tx"][@"transactions"];
            
            if (array.count) {
                self.list = [NSMutableArray arrayWithArray:array];
               
            }
           
        });
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // UI更新代码
            [self endRefreshing];
            [self hideIndicator];
            [self.tableView reloadData];
            [self.tableView reloadData];
            }];
        
    });
}

#pragma mark=====获取BNB /ETH 交易记录
-(void)loadBNBTransactionRecordsChain:(NSString*)chain{
    NSString *url;
    if ([chain isEqualToString:@"BNB"]) {
        url = [NSString stringWithFormat:@"https://api.bscscan.com/api?module=account&action=txlistinternal&address=%@&startblock=0&endblock=99999999&page=1&offset=20&sort=asc&apikey=%@",self.currentWallet[@"address"],@"78NFN5UHK9FTYN6ZTSHZCK8IF5DV4W3JI5"];
    }else{
        url = [NSString stringWithFormat:@"https://api.etherscan.io/api?module=account&action=txlistinternal&address=%@&startblock=0&endblock=99702578&page=1&offset=20&sort=asc&apikey=%@",self.currentWallet[@"address"],@"FJV1AWZ8UWNMX9NIF3UN26NCDU1D5Y2SYG"];
    }
   
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error = nil;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSDictionary *result = [manager syncGET:url
                               parameters:@{}
                                  headers:@{}
                                     task:NULL
                                    error:&error];
        

      
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result[@"status"] intValue]) {
                self.list = result[@"result"];
               
            }
           
        });
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // UI更新代码
            [self endRefreshing];
            [self hideIndicator];
            [self.tableView reloadData];
            [self.tableView reloadData];
            }];
        
    });

    
}

-(void)loadBNBBEP20TokenTransactionRecordsChain:(NSString*)chain{

    NSString *url;
    if ([chain isEqualToString:@"BNB"]) {
        url = [NSString stringWithFormat:@"https://api.bscscan.com/api?module=account&action=tokentx&contractaddress=%@&address=%@&page=1&offset=20&startblock=0&endblock=999999999&sort=asc&apikey=78NFN5UHK9FTYN6ZTSHZCK8IF5DV4W3JI5",self.wallet[@"contractAdd"],self.currentWallet[@"address"]];
    }else{
        url = [NSString stringWithFormat:@"https://api.etherscan.io/api?module=account&action=tokentx&contractaddress=%@&address=%@&page=1&offset=100&startblock=0&endblock=999025780&sort=asc&apikey=FJV1AWZ8UWNMX9NIF3UN26NCDU1D5Y2SYG",self.wallet[@"contractAdd"],self.currentWallet[@"address"]];
    }
   
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error = nil;
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSDictionary *result = [manager syncGET:url
                               parameters:@{}
                                  headers:@{}
                                     task:NULL
                                    error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([result[@"status"] intValue]) {
                self.list = result[@"result"];
               
            }
           
        });
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // UI更新代码
            [self endRefreshing];
            [self hideIndicator];
            [self.tableView reloadData];
            [self.tableView reloadData];
            }];
        });
}



-(UIView *)slidLine{
    if (!_slidLine) {
        _slidLine = [[UIView alloc] initWithFrame:CGRectMake(self.recordBtn.width/2-18, 39, 36, 2)];
        [_slidLine setBoundOfRadius:1];
    }
    return _slidLine;
}

-(UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        //_scrollView.backgroundColor = UIColor.redColor;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*4, 0);
        _scrollView.bounces = NO;
        //_scrollView.showsHorizontalScrollIndicator = NO;
        //_scrollView.showsVerticalScrollIndicator = NO;
        
    }
    return _scrollView;
}

-(CoinDetailsToolView *)toolView{
    if (!_toolView) {
        _toolView = [[CoinDetailsToolView alloc] initCoinDetailsToolView];
    }
    return _toolView;
}
-(CoinDetailsWeb3View *)web3View{
    if (!_web3View) {
        _web3View = [[CoinDetailsWeb3View alloc] initCoinDetailsWeb3View];
    }
    return _web3View;
}

-(CoinDetailsAboutView *)aboutView{
    
    if (!_aboutView) {
        _aboutView = [[CoinDetailsAboutView alloc] initCoinDetailsAboutView];
    }
    return _aboutView;
}
@end
