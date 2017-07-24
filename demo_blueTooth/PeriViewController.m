//
//  ViewController.m
//  demo_blueTooth
//
//  Created by LZP on 2017/7/21.
//  Copyright © 2017年 LZP. All rights reserved.
//

#import "PeriViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "MJRefresh.h"
#import "MBProgressHUD+KR.h"
#import "diyCell.h"
#import "PeriModel.h"
#import "SetFilterStringVC.h"
#import "AudioManager.h"
#import "DataManager.h"

#define RSSISTANDERED 99
#define RSSIWUCHA 30
#define RSSIUSEFULCOUNT 3
#define RSSICHECKCOUNT 5

@interface PeriViewController () <UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) UITableView *tableView;

// CBCentral开头的都是中心设备类，CBPeripheral开头的都是外设类。
// 管理器
@property (nonatomic, strong) CBCentralManager *cbcManager;

// 连接到的设备
@property (nonatomic, strong) CBPeripheral *peripheral;

// 特征值
@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

// 保存所有扫描到的设备(或者model)
@property (nonatomic, strong) NSMutableArray *peripheralsMArray;

/** 配套检查的字典
        {
            @"UUID1" : {
                @"info" : model,
                @"data" : {
                    @(-57.0),
                    @(-69.0)
                },
                @"totalCount" : @(10)
            },
            @"UUID2" : {
                @"info" : model,
                @"data" : {
                    @(-57.0),
                    @(-69.0)
                },
                @"totalCount" : @(10)
            }
        }

 */
@property (nonatomic, strong) NSMutableDictionary *peripheralDic;

// 目标设备的UUID, 所有预设的UUID均为常量
@property (nonatomic, strong) NSArray *kPeripheralUUIDs;
@property (nonatomic, strong) NSString *kPeripheralUUID;

// 写特征值UUID
@property (nonatomic, strong) NSString *kCharacteristicWriteUUID;
// 通知特征值UUID
@property (nonatomic, strong) NSString *kCharacteristicNotifyUUID;

// 是否连接
@property (nonatomic, assign) BOOL isConnect;

// 刷新扫描的定时器 -- 2s其实有点快, 如果在4秒内做出反应就OK
@property (nonatomic, strong) NSTimer *scanTimer;

// 扫描中
@property (nonatomic, assign) BOOL timerIsOn;

// 名称过滤
@property (nonatomic, strong) NSString *nameFilterate;

// 配置表
@property (nonatomic, strong) NSDictionary *prefrenceDic;
@end

@implementation PeriViewController

- (NSString *)nameFilterate {
    if(nil == _nameFilterate) {
        _nameFilterate = @"April";
    }
    return _nameFilterate;
}

- (NSArray *)kPeripheralUUIDs {
    return @[];
}

- (NSString *)kPeripheralUUID {
    return @"";
}

- (NSMutableArray *)peripheralsMArray {
    if(nil == _peripheralsMArray) {
        _peripheralsMArray = [NSMutableArray array];
    }
    return _peripheralsMArray;
}

- (NSMutableDictionary *)peripheralDic {
    if(nil == _peripheralDic) {
        _peripheralDic = [NSMutableDictionary dictionary];
    }
    return _peripheralDic;
}

- (void)viewWillAppear:(BOOL)animated {
    tapCount = 0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [DataManager getPrefrenceComplete:^(NSDictionary *prefrenceDic, NSError *error) {
        if(nil == error) {
            self.prefrenceDic = prefrenceDic;
        }
    }];
    
    [self setUpTableView];
    
    
    [self initAll];
}

- (void)setUpTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"diyCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

- (void)initAll {
    
    self.timerIsOn = NO;
    // 初始化
    self.cbcManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.cbcManager.delegate = self;
    
    self.peripheral = nil;
    self.writeCharacteristic = nil;
    self.isConnect = NO;
}

- (IBAction)refresh:(UIBarButtonItem *)sender {
    if(!self.timerIsOn) {
        [self initAll];
    }
}


int tapCount = 0;
- (IBAction)setFilterString:(UIButton *)sender {
    tapCount ++;
    if(tapCount >= 4) {
        // 跳转页面
        SetFilterStringVC *setVC = [[SetFilterStringVC alloc] init];
        setVC.preFilteration = self.nameFilterate;
        setVC.setFilerBlock = ^(NSString *newString) {
            self.nameFilterate = newString;
            [self startScan];
            
        };
        [self.navigationController pushViewController:setVC animated:YES];
    }
}

#pragma mark CBCentralManagerDelegate, CBPeripheralDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"%@", central.description);
    
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CBCentralManagerStatePoweredOn");
            
            // 扫描
            [self startScan];
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            break;
        default:
            break;
    }
}

- (void)stopScan {
    [self.scanTimer invalidate];
    self.timerIsOn = NO;
    [self.cbcManager stopScan];
    // [[AudioManager sharedAudioManager] stopSound];
    
}

- (void)startScan {
    
    if(self.timerIsOn) {
        [self stopScan];
    }
    
    self.timerIsOn = YES;
    tapCount = 0;
    [self.peripheralsMArray removeAllObjects];
    [self.peripheralDic removeAllObjects];
    [self.tableView reloadData];
    [self scan];
    self.scanTimer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(scan) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.scanTimer forMode:NSDefaultRunLoopMode];
}

- (void)scan {
    [self.cbcManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)playSoundWithPreipheral:(NSString *)preipheralName {

    NSString *soundName = self.prefrenceDic[preipheralName];
    
    if(nil == soundName || soundName.length == 0) {
        [[AudioManager sharedAudioManager] playSound:self.prefrenceDic[@"default"] numberOfLoops:-1];
    } else {
        [[AudioManager sharedAudioManager] playSound:soundName numberOfLoops:-1];
    }
}

- (void)setUpCell:(diyCell *)cell withName:(NSString *)name identify:(NSString *)UUIDString RSSI:(int)RSSI distance:(float)distance {
    cell.nameLabel.text = name;
    cell.UUIDLabel.text = UUIDString;
    cell.RSSILabel.text = [NSString stringWithFormat:@"%d", RSSI];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.2fm", distance];
}

- (void)setUpCell:(diyCell *)cell RSSI:(int)RSSI distance:(float)distance {
    cell.RSSILabel.text = [NSString stringWithFormat:@"%d", RSSI];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.2fm", distance];
}

/**
 发现设备
 
 @param central 回调这个方法的中心设备
 @param peripheral 发现的外设对象CBPeripheral
 @param advertisementData 字典类型广播数据
 @param RSSI 当前外设的信号强度，单位是dbm
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    /***************** 自定义过滤规则 ↓ *****************/
    // 指定开头的 蓝牙 服务, 过滤信号太差的 服务
    if((self.nameFilterate.length > 0 && ![peripheral.name containsString:self.nameFilterate]) || abs(RSSI.intValue) > RSSISTANDERED) {
        return;
    }
    
    NSLog(@"name:%@, UUID:%@, RSSI:%d", peripheral.name, peripheral.identifier.UUIDString, RSSI.intValue);
    //NSLog(@"-----------------------------------------");
    
    /***************** 自定义过滤规则 ↑ *****************/
    
    // 保存发现的设备
    
    // 如果之前扫描过这个设备
    if([self.peripheralDic objectForKey:peripheral.identifier.UUIDString]) {
        
        //
        NSMutableDictionary *periMDic = self.peripheralDic[peripheral.identifier.UUIDString];
        
        PeriModel *model = periMDic[@"info"];
        
//        NSNumber *totCouNum = periMDic[@"totalCount"];
//        int totaCount = totCouNum.intValue;
//        totaCount ++;
//        [periMDic setValue:@(totaCount) forKey:@"totalCount"];
        
        // 用于计算均值 的数组
        NSMutableArray *RSSIMArray = periMDic[@"data"];
        // 先算一下平均值
        NSNumber *avgPre = [RSSIMArray valueForKeyPath:@"@avg.floatValue"];
        // NSLog(@"avgPre:%@, avgPreF:%f", avgPre, avgPre.floatValue);
        // NSLog(@"%d", RSSI.intValue);
        // 误差一定指数以上的过滤
        if(abs(abs(RSSI.intValue) - abs(avgPre.intValue)) < RSSIWUCHA) {
            [RSSIMArray addObject:RSSI];
            // NSNumber *avgLas = [RSSIMArray valueForKeyPath:@"@avg.floatValue"];
            // NSLog(@"avgLas:%@, avgLasF:%f", avgLas, avgLas.floatValue);
            // NSLog(@"%ld", RSSIMArray.count);
        }
        
        
        // 如果超过 指定 个数, 移除第一个
        if(RSSIMArray.count > RSSIUSEFULCOUNT) {
            [RSSIMArray removeObjectAtIndex:0];
        }
        
        // 获取数据 平均值
        NSNumber *avgLas = [RSSIMArray valueForKeyPath:@"@avg.floatValue"];

        // 更新模型
        model.aRSSI = RSSI.intValue;
        model.avgRSSIf = avgLas.floatValue;
        
        // 更新界面
        diyCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:model.index inSection:0]];
        [self setUpCell:cell RSSI:model.aRSSI distance:model.distance];
        
        // 动画, 显示变动
        [UIView animateWithDuration:0.2 animations:^{
            cell.backgroundColor = [UIColor lightGrayColor];
        } completion:^(BOOL finished) {
            cell.backgroundColor = [UIColor whiteColor];
        }];
        
        //
        NSInteger periphCount = self.peripheralsMArray.count;
        // if(periphCount >= 1 && totaCount >= RSSICHECKCOUNT) {
            // 扫描到足够多的设备的时候
            // 当有的设备扫描的足够多次之后
            
            // [self stopScan];
            
            // 来算一下那个是信号最好的
            PeriModel *indexModel = self.peripheralsMArray[0];
            NSInteger index = 0;
            
            // 比较得出信号最好的 设备
            for(NSInteger i = 1; i < periphCount; i ++) {
                PeriModel *chModel = self.peripheralsMArray[i];
                
                if(fabsf(indexModel.avgRSSIf) > fabs(chModel.avgRSSIf)) {
                    indexModel = chModel;
                    index = i;
                }
            }
        
            // 如果信号最好的设备变化了
            if(![self.peripheral.identifier.UUIDString isEqualToString:indexModel.peripheral.identifier.UUIDString]) {
        
                indexModel.aRSSI = (int)indexModel.avgRSSIf;
                
                CBPeripheral *targetPeri = indexModel.peripheral;
                // NSMutableDictionary *targetMPerDic = self.peripheralDic[targetPeri.identifier.UUIDString];
                
                NSLog(@"就决定是这个了:%@", targetPeri.description);
                [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@", targetPeri.name] toView:self.view];
                
                // 连接
                if(self.isConnect || (self.peripheral && ![self.peripheral.identifier isEqual:targetPeri.identifier])) {
                    [self.cbcManager cancelPeripheralConnection:self.peripheral];
                }
                // totaCount = 0;
                [self.cbcManager connectPeripheral:targetPeri options:nil];
                NSLog(@"连接外设:%@", targetPeri.description);
                self.peripheral = targetPeri;
                
                [self playSoundWithPreipheral:targetPeri.name];
                
                // [self stopScan];
                
    //            [self.peripheralsMArray removeAllObjects];
    //            [self.peripheralDic removeAllObjects];
    //            
    //            
    //            [self.peripheralsMArray addObject:indexModel];
    //
    //            targetMPerDic[@"totalCount"] = @(0);
    //            [self.peripheralDic setObject:targetMPerDic forKey:targetPeri.identifier.UUIDString];
    //            
    //            [self.tableView reloadData];
    //            
    //            diyCell *targetCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    //            targetCell.RSSILabel.text = [NSString stringWithFormat:@"%d", indexModel.aRSSI];
    //            targetCell.distanceLabel.text = [NSString stringWithFormat:@"%.2fm", indexModel.distance];
                }
        // }
    } else {
        
        // 如果 新发现的设备
        NSInteger count = self.peripheralsMArray.count;
        
        // 创建新的模型
        PeriModel *model = [PeriModel ModelWithPeripheral:peripheral index:count aRSSI:RSSI.intValue];
        
        // 先保存在界面数据源
        [self.peripheralsMArray addObject:model];
        
        // 构造比对字典
        NSMutableDictionary *periMDic = [NSMutableDictionary dictionary];
        [periMDic setObject:model forKey:@"info"];
        NSMutableArray *RSSIMArray = [NSMutableArray array];
        [RSSIMArray addObject:RSSI];
        [periMDic setObject:RSSIMArray forKey:@"data"];
        [periMDic setValue:@(1) forKey:@"totalCount"];
        
        [self.peripheralDic setObject:periMDic forKey:peripheral.identifier.UUIDString];
        
        // 刷新界面
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        diyCell *newCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:count inSection:0]];
        [self setUpCell:newCell withName:peripheral.name identify:peripheral.identifier.UUIDString RSSI:model.aRSSI distance:model.distance];
        
    }
    
}

// 连接到外设后
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"已经连接到:%@", peripheral.description);
    peripheral.delegate = self;
    // [central stopScan];
    
    self.isConnect = YES;
    // 一旦连接好外设，我们就可以马上停止扫描。然后发起对服务的搜索
    
    [self.cbcManager cancelPeripheralConnection:peripheral];
    
    self.isConnect = NO;
    // [self startScan];
    NSLog(@"已经停止连接了");
    
    // 若该参数为nil，将会扫描所有的服务。
    // [peripheral discoverServices:nil];
}

/**
 连接失败后
 在连接外设失败的回调方法中，提供了error参数，可根据实际需要来做异常处理，在此不做过多说明
 
 @param central 回调这个方法的中心设备
 @param peripheral 发现的外设对象
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"连接%@失败, error:%@", peripheral.description, error);
}

// 搜索到蓝牙设备的服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if(error) {
        NSLog(@"搜索到蓝牙设备:%@, 服务出错:%@", peripheral.description, [error localizedDescription]);
        return;
    }
    
    // 扫描服务
    // 由于服务在peripheral里是以NSArray的形式存在的，所以我们要对peripheral中的所有服务进行遍历：
    for(CBService *service in peripheral.services) {
        NSLog(@"serviceUUID:%@", service.UUID.UUIDString);
        //if([service.UUID isEqual:[CBUUID UUIDWithString:@""]]) {
        //        //if([self.kServiceUUIDs containsObject:service.UUID.UUIDString]) {
        //            NSLog(@"发现服务:%@", service.UUID);
        //
        //            // 扫描特征值
        //            // 若扫描所有的特征值，直接传入nil作为参数即可。
        //            [peripheral discoverCharacteristics:nil forService:service];
        //            break;
        //        }
    }
    
}

// 扫描特征值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"搜索特征%@时发生错误:%@", service.UUID, [error localizedDescription]);
        return;
    }
    
    // characteristics也是一个数组，我们利用像遍历services一样的方式来遍历所有的特征值。
    for(CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"特征:%@",characteristic);
        
        // 不同的蓝牙设备有不同的服务和特征值。write特征、read特征、notify特征，所以在此根据自身需要，来对不同的特征值进行操作。
        
        // 发现特征值
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:self.kCharacteristicWriteUUID]]) {
            self.writeCharacteristic = characteristic;
        }
        
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:self.kCharacteristicNotifyUUID]]) {
            NSLog(@"监听特征:%@",characteristic);//监听特征
            [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
            self.isConnect = YES;
        }
    }
}

// 设置监听
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"更新特征值%@时发生错误:%@", characteristic.UUID, [error localizedDescription]);
        return;
    }
    
    // 收到数据
    // [self didGetDataForString:[self hexadecimalString:characteristic.value]];
    NSLog(@"%@",[self hexadecimalString:characteristic.value]);
    
}

//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data{
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return result;
}
//将传入的NSString类型转换成NSData并返回
- (NSData*)dataWithHexstring:(NSString *)hexstring{
    NSData *aData;
    return aData = [hexstring dataUsingEncoding: NSASCIIStringEncoding];
}

#pragma mark tableView delegate, dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // return self.dataMArray.count;
    return self.peripheralsMArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    diyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    PeriModel *model = self.peripheralsMArray[indexPath.row];
    CBPeripheral *peripheral = model.peripheral;
    cell.nameLabel.text = peripheral.name;
    cell.UUIDLabel.text = peripheral.identifier.UUIDString;
    cell.RSSILabel.text = [NSString stringWithFormat:@"%d", model.aRSSI];
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.2fm", model.distance];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
