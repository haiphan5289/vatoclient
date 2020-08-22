//
//  FCGiftViewController.m
//  FaceCar
//
//  Created by facecar on 8/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCGiftViewController.h"
#import "APIHelper.h"
#import "FCGift.h"
#import "FCGiftTableViewCell.h"
#import "FCGiftDetailViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCWarningNofifycationView.h"
#import "FCGiftViewModel.h"

#define CELL @"FCGiftTableViewCell"

@interface FCGiftViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray* listGift;

@end

@implementation FCGiftViewController {
    UIRefreshControl* refresh;
}


- (instancetype) initView {
    self = [self initWithNibName:@"FCGiftViewController" bundle:nil];
    return self;
}

- (instancetype) initViewWithNavi {
    self = [self initWithNibName:@"FCGiftViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close-w"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Khuyến mãi";
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableview registerNib:[UINib nibWithNibName:CELL
                                               bundle:nil]
         forCellReuseIdentifier:CELL];
    self.tableview.estimatedRowHeight = 310.0f;
    self.tableview.rowHeight = UITableViewAutomaticDimension;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        refresh =  [[UIRefreshControl alloc] init];
        [refresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
        self.tableview.refreshControl = refresh;
    }
    
    if (self.stationEvents) {
        self.listGift = [[NSMutableArray alloc] initWithArray:self.stationEvents.list];
        [self.tableview reloadData];
        [self checkingData];
    }
    else {
        [self getGifts];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) onRefresh: (id) sender {
    if (!self.stationEvents) {
        [self getGifts];
    }
    [refresh endRefreshing];
}

- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) getGifts {
    if (!self.listGift) {
        self.listGift = [[NSMutableArray alloc] init];
    }
    else {
        [self.listGift removeAllObjects];
    }
    
    // load danh sach tu chuong trinh danh cho station
    if (self.pageVC)
        [self.pageVC.progressBar show];
    else
        [IndicatorUtils show];
    
    FCGiftViewModel* giftViewModel = [[FCGiftViewModel alloc] initWithRootVC:self homeViewModel:self.homeViewModel];
    [giftViewModel getGift: @[@(ALL)] complete:^(NSMutableArray* gifts) {
        
        [IndicatorUtils dissmiss];
        [self.pageVC.progressBar dismiss];
        
        [self.listGift removeAllObjects];
        [self.listGift addObjectsFromArray:gifts];
        [self.tableview reloadData];
        
        [self checkingData];
    }];
}

- (void) checkingData {
    if (self.listGift.count == 0) {
        FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] initView];
        view.lblTitle.text = @"";
        view.bgColor = [UIColor whiteColor];
        view.messColor = [UIColor darkGrayColor];
        [view show:self.tableview
             image:[UIImage imageNamed:@"gift-large"]
             title:nil
           message:@"Hiện tại chưa có chương trình khuyến mãi nào dành cho bạn."];
        [self.tableview setScrollEnabled:NO];
    }
}

#pragma mark - TableView Delegate
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCGiftTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL forIndexPath:indexPath];
    [cell loadGift:[self.listGift objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listGift.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCGiftDetailViewController* detailVC = [[FCGiftDetailViewController alloc] initView];
    detailVC.gift = [self.listGift objectAtIndex:indexPath.row];
    detailVC.stationEvents = self.stationEvents;
    detailVC.homeViewModel = self.homeViewModel;
    FacecarNavigationViewController* nav = [[FacecarNavigationViewController alloc] initWithRootViewController:detailVC];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
