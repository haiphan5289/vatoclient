//
//  FavoriteViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/2/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "FavoriteViewController.h"
#import "DriverDetailViewController.h"
#import "FavoriteTableViewCell.h"
#import "FacecarNavigationViewController.h"
#import "FCFindView.h"
#import "FCWarningNofifycationView.h"

@interface FavoriteViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray* listDrivers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnAddNewOne;
@property (strong, nonatomic) FCWarningNofifycationView* nodataView;
@property (strong, nonatomic) FCHomeViewModel* homeViewModel;
@property (assign, nonatomic) FavViewType viewType;
@end

@implementation FavoriteViewController {
}

- (instancetype) initView:(FCHomeViewModel *)homeModel
                     type:(FavViewType)type {
    self = [self initWithNibName:@"FavoriteViewController" bundle:nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close-w"] style:UIBarButtonItemStylePlain target:self action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.homeViewModel = homeModel;
    self.viewType = type;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FavoriteTableViewCell" bundle:nil] forCellReuseIdentifier:@"FavoriteTableViewCell"];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    if (self.viewType == ViewTypeFavorite) {
        self.navigationItem.title = localizedFor(@"Lái xe riêng");
        [self.btnAddNewOne setTitle:[localizedFor(@"THÊM LÁI XE") uppercaseString] forState:UIControlStateNormal];
    } else if (self.viewType == ViewTypeBlock) {
        self.navigationItem.title = localizedFor(@"Danh sách chặn");
        [self.btnAddNewOne setTitle:[localizedFor(@"Chặn lái xe này") uppercaseString] forState:UIControlStateNormal];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [IndicatorUtils show];
    [self getData];
}

- (void) closePressed: (id) sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRemovedFavorite:(FCFavorite *)favorite{
    [[FirebaseHelper shareInstance] removeFromBacklist:favorite handler:^(NSError * _Nullable error, FIRDatabaseReference * ref) {
        if (error) {
            [[FCNotifyBannerView banner] show:nil
                                      forType:FCNotifyBannerTypeError
                                     autoHide:YES
                                      message:localizedFor(@"Đã xảy ra lỗi. Bạn vui lòng thử lại sau!")
                                   closeClick:nil
                                  bannerClick:nil];
        }
    }];
}

- (void) getData {
    if (self.viewType == ViewTypeFavorite) {
        [[FirebaseHelper shareInstance] getListFavorite:^(NSMutableArray * list) {
            [IndicatorUtils dissmiss];
            self.listDrivers = list;
            [self reloadData];
        }];
    }
    else if (self.viewType == ViewTypeBlock) {
        [[FirebaseHelper shareInstance] getListBackList:^(NSMutableArray * list) {
            [IndicatorUtils dissmiss];
            self.listDrivers = list;
            [self reloadData];
        }];
    }
}

- (void) reloadData {
    [self.tableView reloadData];
    if (_listDrivers && _listDrivers.count == 0) {
        if (!self.nodataView) {
            FCWarningNofifycationView* view = [[FCWarningNofifycationView alloc] initView];
            view.lblTitle.text = @"";
            view.cusframe = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            view.bgColor = [UIColor whiteColor];
            view.messColor = [UIColor darkGrayColor];
            
            NSString* message;
            if (self.viewType == ViewTypeBlock) {
                message = localizedFor(@"Để không gặp lại lái xe có dịch vụ kém, bạn có thể lưu lái xe vào danh sách này bằng cách chọn Thêm lái xe.");
            }
            else {
                message = localizedFor(@"Hiện tại bạn chưa có lái xe riêng nào. Để tạo danh sách lái xe riêng, bạn chọn Thêm lái xe.");
            }
            [view show:self.view
                 image:[UIImage imageNamed:@"driver-icon"]
                 title:nil
               message:message];
            self.nodataView = view;
        }
        
        [self.view addSubview:self.nodataView];
        [self.tableView setScrollEnabled:NO];
        
        [self.view bringSubviewToFront:self.btnAddNewOne];
        [self.view layoutIfNeeded];
    }
    else {
        [self.tableView setScrollEnabled:YES];
        if (self.nodataView) {
            [self.nodataView removeFromSuperview];
            self.nodataView = nil;
        }
    }
}

- (IBAction)addNewDriverClicked:(id)sender {
    FCFindView* view = [[FCFindView alloc] initView:self];
    [view setupView];
    [self.navigationController.view addSubview:view];
    
    [RACObserve(view, userInfo) subscribeNext:^(FCUserInfo* info) {
        if (info) {
            FCFavorite* fav = [[FCFavorite alloc] init];
            fav.userFirebaseId = info.firebaseId;
            fav.userAvatar = info.avatar;
            fav.userPhone = info.phoneNumber;
            fav.userName = info.fullName;
            fav.userId = info.id;
            [self loadFavoriteView:fav];
            [view removeFromSuperview];
        }
    }];
}

- (void) loadFavoriteView: (FCFavorite*) fav {
    DriverDetailViewController* vc = (DriverDetailViewController*)[[NavigatorHelper shareInstance] getViewControllerById:@"DriverDetailViewController" inStoryboard:@"DriverDetailViewController"];
    vc.favorite = fav;
    vc.type = self.viewType;
    vc.homeViewModel = self.homeViewModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listDrivers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavoriteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FavoriteTableViewCell class]) forIndexPath:indexPath];
    
    FCFavorite* fav = [self.listDrivers objectAtIndex:indexPath.row];
    [cell loadData:fav];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FCFavorite* fav = [self.listDrivers objectAtIndex:indexPath.row];
    [self loadFavoriteView: fav];
}


@end
