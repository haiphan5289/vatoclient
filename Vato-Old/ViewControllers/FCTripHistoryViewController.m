//
//  FCTripHistoryViewController.m
//  FC
//
//  Created by facecar on 5/31/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCTripHistoryViewController.h"
#import "FCTripManagerTableViewCell.h"
#import "TripMapsViewController.h"
#import "FCWarningNofifycationView.h"
#import "UserDataHelper.h"
#import "FCTripHistory.h"
#import "FCBookingService.h"
#import "FCBookViewModel.h"
#import "UITableView+ENFooterActivityIndicatorView.h"
#import "FCTripViewModel.h"
#if DEV
#import "VATO_DEV-Swift.h"
#elif STG
#import "VATO_Staging-Swift.h"
#else
#import "VATO-Swift.h"
#endif

#define CELL @"FCTripManagerTableViewCell"

@interface FCTripHistoryViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableArray* listData;
@property (nonatomic) TripHistoryType tripHistoryType;
@property (nonatomic) NoItemView *noItemView;
@end

@implementation FCTripHistoryViewController {
    NSInteger _page;
    BOOL _more;
    BOOL _loadMoring;
    UIRefreshControl* refresh;
}

- (instancetype) initView {
    self = [self initWithNibName:@"FCTripHistoryViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close-w"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = localizedFor(@"Lịch sử đặt xe");
    return self;
}

- (instancetype)initWithType:(TripHistoryType)type
{
    self = [super init];
    if (self) {
        self.tripHistoryType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listData = [[NSMutableArray alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:CELL bundle:nil] forCellReuseIdentifier:CELL];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // header
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        refresh =  [[UIRefreshControl alloc] init];
        [refresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
        self.tableView.refreshControl = refresh;
    }
    
    // footer
    @weakify(self);
    [self.tableView setTableScrolledDownBlock:^void() {
        @strongify(self);
        if (_more) {
            if (![self.tableView footerActivityIndicatorView])
                [self.tableView addFooterActivityIndicatorWithHeight:80.f];
            
            if (!_loadMoring) {
                _page ++;
                _loadMoring = TRUE;
                [self getListTrip];
            }
        }
        else {
            [self.tableView removeFooterActivityIndicator];
        }
    }];
    
    [IndicatorUtils show];
    [self getListTrip];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) onRefresh: (id) sender {
    _page = 0;
    [self getListTrip];
    [refresh endRefreshing];
}

- (void) getListTrip {
    @weakify(self);
    [self getListTrip:^(NSMutableArray *list, BOOL more) {
        @strongify(self);
        _more = more;
        _loadMoring = NO;
        if (_page == 0) {
            [self.listData removeAllObjects];
        }
        
        [self.listData addObjectsFromArray:list];
        [self.tableView reloadData];
        [self checkingData];
    }];
}

- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) getListTrip: (void (^) (NSMutableArray* list, BOOL more)) block {
    long long to = (long long)[self getCurrentTimeStamp];
    long long from = (long long) (to - limitdays);
    
    NSString *serviceIds = [NSString stringWithFormat:@"%ld,%ld,%ld,%ld,%ld,%ld,%ld",
                           VatoServiceCar,
                           VatoServiceCarPlus,
                           VatoServiceCar7,
                           VatoServiceMoto,
                           VatoServiceMotoPlus,
                           VatoServiceTaxi,
                           VatoServiceTaxi7];
    
    if (self.tripHistoryType == TripHistoryExpress) {
        serviceIds = [NSString stringWithFormat:@"%ld", VatoServiceDelivery];
    }
        
    NSDictionary* body = @{@"from": @(from),
                           @"to": @(to),
                           @"page": @(_page),
                           @"serviceId": serviceIds,
                           @"size": @10};
    [[APIHelper shareInstance] get:API_GET_TRIP_DAY
                            params:body
                          complete:^(FCResponse *response, NSError *error) {
                              [IndicatorUtils dissmiss];
                              @try {
                                  NSMutableArray* list = [[NSMutableArray alloc] init];
                                  NSDictionary *data = response.data;
                                  NSArray* datas = [data objectForKey:@"trips"];
                                  BOOL more = [[data objectForKey:@"more"] boolValue];
                                  for (id item in datas) {
                                      NSError* err;
                                      FCTripHistory* book = [[FCTripHistory alloc] initWithDictionary:item  error:&err];
                                      if (book) {
                                          [list addObject:book];
                                      }
                                  }
                                  block(list, more);
                              }
                              @catch (NSException* e) {
                                  DLog(@"Error: %@", e);
                                  block (nil, NO);
                              }
                              
                          }];
}

- (void) checkingData {
    if (self.noItemView == nil) {
        self.noItemView = [[NoItemView alloc] initWithImageName:@"no-trip" message:localizedFor(@"Bạn chưa có chuyến đi nào.") subMessage:@"" on:self.tableView customLayout:nil];
    }
    self.listData.count > 0 ? [self.noItemView detach] : [self.noItemView attach];
}

#pragma mark - TableView Delegate
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listData.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 205;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCTripManagerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL forIndexPath:indexPath];
    FCTripHistory* trip = [self.listData objectAtIndex:indexPath.row];
    [cell loadData:trip];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCTripHistory* tripHistory = [self.listData objectAtIndex:indexPath.row];
    if (!tripHistory) {
        return;
    }

    if ([tripHistory isInTrip]) {
        @weakify(self);
        [IndicatorUtils show];
        [[FCBookingService shareInstance] getBookingDetail:tripHistory
                                                   handler:^(FCBooking * trip) {
                                                        @strongify(self);
                                                       [IndicatorUtils dissmiss];
                                                       if (trip) {
                                                           [self loadTrip: trip];
                                                       }
                                                   }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView tableViewDidScroll];
}

- (void) loadTrip: (FCBooking*) trip {
    [self playsound:@"success"];
    FCTripViewModel* model = [[FCTripViewModel alloc] initViewModel:trip
                                                            cartype:trip.info.serviceId fromManager:YES];
    TripMapsViewController* mapsTrip = [[TripMapsViewController alloc] initViewController:model];
    mapsTrip.fromHistory = TRUE;
    if (model.booking.info.serviceId == VatoServiceDelivery) {
        mapsTrip.fromDelivery = TRUE;
    }
//    FCBookViewModel* bookModel = [[FCBookViewModel alloc] init];
    mapsTrip.book = trip;
//    [bookModel setBooking:trip];
    mapsTrip.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    mapsTrip.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.tabBarController presentViewController:mapsTrip
                       animated:YES
                     completion:nil];
    
    @weakify(self);
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:NOTIFICATION_FINISHED_TRIP object:nil] subscribeNext:^(id x) {
        @strongify(self);
        [self onRefresh:x];
    }];
}

@end
