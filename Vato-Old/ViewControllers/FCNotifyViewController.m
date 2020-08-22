//
//  FCNotifyViewController.m
//  FC
//
//  Created by facecar on 7/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCNotifyViewController.h"
#import "APIHelper.h"
#import "FCInvoiceManagerViewController.h"
#import "FCWebViewController.h"
#import "FacecarNavigationViewController.h"
#import "FCWarningNofifycationView.h"
#import "ProfileViewController.h"
#import "FCWalletViewController.h"
#import "UserDataHelper.h"
#import "UITableView+ENFooterActivityIndicatorView.h"
#import "FCInvoiceDetailViewController.h"
#import "FCHomeViewModel.h"
#import "FCNotifyPageViewController.h"
#import "FCNotifyTableViewCell.h"

#define CELL @"FCNotifyTableViewCell"

@interface FCNotifyViewController ()

@end

@implementation FCNotifyViewController {
    UIRefreshControl* refresh;
    NSMutableArray* _listData;
    NSInteger _page;
    BOOL _more;
    BOOL _loadMoring;
}

- (void)setHomeViewModel:(FCHomeViewModel *)homeViewModel {
    _homeViewModel = homeViewModel;
}

- (instancetype) initView {
    self = [self initWithNibName:@"FCNotifyViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![self tabBarController]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_back"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
        self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    }
    self.navigationItem.title = localizedFor(@"Thông báo");
    _listData = [[NSMutableArray alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:CELL bundle:nil]
         forCellReuseIdentifier:CELL];
    self.tableView.estimatedRowHeight = 200;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.hidden = YES;
   
    // header
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        refresh =  [[UIRefreshControl alloc] init];
        [refresh addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
        self.tableView.refreshControl = refresh;
    }
    
    // footer
    [self.tableView setTableScrolledDownBlock:^void() {
        if (_more) {
            if (![self.tableView footerActivityIndicatorView])
                [self.tableView addFooterActivityIndicatorWithHeight:80.f];
            
            if (!_loadMoring) {
                _page ++;
                _loadMoring = TRUE;
                [self getListNotification];
            }
        } else {
            [self.tableView removeFooterActivityIndicator];
        }
    }];
    
    [IndicatorUtils show];
    [self getListNotification];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) onRefresh: (id) sender {
    _page = 0;
    [self getListNotification];
    [refresh endRefreshing];
}

- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Data handler
- (void) getListNotification {
    [self apiGetListNotification:^(NSMutableArray *list, BOOL more) {
        _more = more;
        _loadMoring = NO;
        if (_page == 0) {
            [_listData removeAllObjects];
        }
        
        [_listData addObjectsFromArray: list];
        [self.tableView reloadData];
        self.tableView.hidden = NO;
        [self checkingData];
    }];
}

- (void) apiGetListNotification : (void (^) (NSMutableArray* arr, BOOL more)) block{
    
    [self.pageVC.progressBar show];
    long long to = (long long)[self getCurrentTimeStamp];
    long long from = (long long) (to - limitdays);
    NSDictionary* body = @{@"from":@(from),
                           @"to" : @(to),
                           @"page":@(_page),
                           @"size":@(10)};
    [[APIHelper shareInstance] get:API_GET_LIST_NOTIFY
                               params:body
                           complete:^(FCResponse *response, NSError *error) {
                               [IndicatorUtils dissmiss];
                               @try {
                                   [self.pageVC.progressBar dismiss];
                                   NSMutableArray* list = [[NSMutableArray alloc] init];
                                   NSArray* datas = [response.data objectForKey:@"notifications"];
                                   BOOL more = [[response.data objectForKey:@"more"] boolValue];
                                   NSInteger lastest = 0;
                                   for (id item in datas) {
                                       FCNotification* noti = [[FCNotification alloc] initWithDictionary:item error:nil];
                                       if ([item isKindOfClass:[NSDictionary class]]) {
                                           noti.rawData = (NSDictionary*) item;
                                       }

                                       if (noti) {
                                           [list addObject:noti];
                                           if (lastest < noti.createdAt) {
                                               lastest = noti.createdAt;
                                           }
                                       }
                                   }
                                   
                                   [[UserDataHelper shareInstance] saveLastestNotification:lastest];
                                   [self.homeViewModel setNotifyBadge:0];
                                   block(list, more);
                               }
                               
                               @catch (NSException* e) {
                                   DLog(@"Error: %@", e);
                                   block (nil, NO);
                               }
                               
    }];
}

- (void) checkingData {
    if (_listData.count == 0) {
        FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] initView];
        view.lblTitle.text = @"";
        view.bgColor = [UIColor whiteColor];
        view.messColor = [UIColor darkGrayColor];
        [view show:self.view
             image:[UIImage imageNamed:@"no-notify"]
             title:nil
           message: localizedFor(@"Hiện tại, bạn không có thông báo mới nào.")];
        [self.tableView setScrollEnabled:NO];
    }
}

#pragma mark - Tableview Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.tableView tableViewDidScroll];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listData.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCNotifyTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CELL forIndexPath:indexPath];
    [cell loadData:[_listData objectAtIndex:indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCNotification* noti = [_listData objectAtIndex:indexPath.row];
    if (noti.status == NEW) {
        noti.status = READ;
        
        self.homeViewModel.totalUnreadNotify -= 1;
        
        FCNotifyTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            [cell loadNewStatus:noti];
        }
    }
    
    int type = noti.type;
    UIViewController* vc = nil;
    if (type == NotifyTypeReferal) {
        vc = [[FCInvoiceManagerViewController alloc] initViewForPresent];
    }
    else if (type == NotifyTypeBalance) {
        vc = [[FCWalletViewController alloc] initView:self.homeViewModel];
    }
    else if (type == NotifyTypeTranferMoney) {
        vc = [[FCInvoiceDetailViewController alloc] init];
        ((FCInvoiceDetailViewController*) vc).invoiceId = [noti.referId integerValue];
    }
    else if (type == NotifyTypeLink && noti.url.length > 0) {
        FCWebViewModel* model = [[FCWebViewModel alloc] initWithUrl:noti.url];
        vc = [[FCWebViewController alloc] initViewWithViewModel:model];
    }
    else if (type == NotifyTypeWeb) {
        NSURL *url = [NSURL URLWithString:noti.extra ?: @""];
        [WebVC loadWebOn:self url:url title:noti.title];
//        FCWebViewModel* model = [[FCWebViewModel alloc] initWithUrl:noti.extra];
//        vc = [[FCWebViewController alloc] initViewWithViewModel:model];
//        ((FCWebViewController*)vc).title = noti.title;
    }
    else if (type == NotifyTypeManifest) {
        if ([self.delegate respondsToSelector:@selector(onSelectedNotification:)]) {
//            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            [self.delegate onSelectedNotification:noti];
        }
    }
    
    if (vc) {
        FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
        [self  presentViewController:navController animated:TRUE completion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 16.0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 16.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.frame.size.width, 16.0)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}


@end
