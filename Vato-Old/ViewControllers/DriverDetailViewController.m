//
//  DriverDetailViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/4/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "DriverDetailViewController.h"
#import "NavigatorHelper.h"
#import "AppDelegate.h"
#import "TripMapsViewController.h"
#import "UIView+Border.h"

#define waiting_timeout 30

@interface DriverDetailViewController ()
@property (strong, nonatomic) FCFavorite* favoriteInfo;
@end

@implementation DriverDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationItem.title = localizedFor(@"Thông tin lái xe");
    [_btnAddnewOne setTitle:[localizedFor(@"Thêm lái xe riêng") uppercaseString] forState:UIControlStateNormal];
    [_btnAddBlackList setTitle:[localizedFor(@"Chặn lái xe này") uppercaseString] forState:UIControlStateNormal];
    [_btnRemoveDriver setTitle:[localizedFor(@"Xoá lái xe") uppercaseString] forState:UIControlStateNormal];
}

- (void) setup {
    [self loadDriverInfo];
    
    // get fav info
    [[FirebaseHelper shareInstance] getFavoriteInfo:self.favorite.userFirebaseId handler:^(FCFavorite * fav) {
        self.favoriteInfo = fav;
        [self reloadUI];
    }];
    
    [self.tableView reloadData];
}

- (void) reloadUI {
    self.btnAddnewOne.hidden = YES;
    self.btnAddBlackList.hidden = YES;
    self.btnRemoveDriver.hidden = YES;
    
    if (!self.favoriteInfo) {
        if (self.type == ViewTypeFavorite) {
            self.btnAddnewOne.hidden = NO;
        }
        else {
            self.btnAddBlackList.hidden = NO;
        }
    }
    else {
        self.btnRemoveDriver.hidden = NO;
        if (self.favoriteInfo.isFavorite) {
            [self.btnRemoveDriver setTitle:[localizedFor(@"Xóa khỏi lái xe riêng") uppercaseString] forState:UIControlStateNormal];
        }
        else {
            [self.btnRemoveDriver setTitle:[localizedFor(@"Xoá khỏi danh sách chặn") uppercaseString] forState:UIControlStateNormal];
        }
    }
}

#pragma mark - Inits
- (void) loadDriverInfo {
    [self.avatar circleView:ORANGE_COLOR];
    
    self.lblName.text = self.favorite.userName;
    self.lblPhone.text = self.favorite.userPhone;
//    [self.avatar setImageWithURL:[NSURL URLWithString:self.favorite.userAvatar]
//                placeholderImage:[UIImage imageNamed:@"avatar-holder"]];
    
    @try {
        NSString* phone = [self.favorite.userPhone stringByReplacingCharactersInRange:NSMakeRange(self.favorite.userPhone.length-3, 3) withString:@"xxx"];
        self.lblPhone.text = phone;
    }
    @catch (NSException* e) {
    }
}

#pragma mark - TableView Delegate
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return 30;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    }
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = localizedFor(cell.textLabel.text);
}

#pragma mark - Handler actions

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addAddDriverToFavoriteClicked:(id)sender {
    [self apiAddToFav];
}

- (IBAction)addDriverToBlackListClicked:(id)sender {
    [self apiAddBlackList];
}

- (IBAction)removeDriverFromMyListClicked:(id)sender {
    if (self.favoriteInfo) {
        if (self.favoriteInfo.isFavorite) {
            [self apiRemoveFav];
        }
        else {
            [self apiRemoveBlackList];
        }
    }
}

#pragma mark - APIs

- (void) addDriverToMyList: (BOOL) isFav {
    self.favorite.isFavorite = isFav;
    [[FirebaseHelper shareInstance] requestAddFavorite:self.favorite
                                   withCompletionBlock:^(NSError * error, FIRDatabaseReference * ref) {
                                       [IndicatorUtils dissmiss];
                                       [self.navigationController popViewControllerAnimated:YES];
                                       
                                       NSString* mess;
                                       if (isFav)
                                           mess = [NSString stringWithFormat:localizedFor(@"Đã thêm '%@' vào danh sách Lái xe riêng của bạn."), self.favorite.userName];
                                       else
                                           mess = [NSString stringWithFormat:localizedFor(@"Đã thêm '%@' vào danh sách Danh sách chặn của bạn."), self.favorite.userName];
                                       [[FCNotifyBannerView banner] show:nil
                                                                 forType:FCNotifyBannerTypeSuccess
                                                                autoHide:YES
                                                                 message:mess
                                                              closeClick:nil
                                                             bannerClick:nil];
                                   }];
}

- (void) removeDriverFromMyList {
    [[FirebaseHelper shareInstance] removeFromFavoritelist:self.favoriteInfo
                                                   handler:^(NSError * error, FIRDatabaseReference * ref) {
                                                       [IndicatorUtils dissmiss];
                                                       [self.navigationController popViewControllerAnimated:YES];
                                                       
                                                       NSString* mess = [NSString stringWithFormat:localizedFor(@"Đã xoá '%@' khỏi danh sách của bạn."), self.favorite.userName];
                                                       [[FCNotifyBannerView banner] show:nil
                                                                                 forType:FCNotifyBannerTypeSuccess
                                                                                autoHide:YES
                                                                                 message:mess
                                                                              closeClick:nil
                                                                             bannerClick:nil];
                                                   }];
}

- (void) apiAddToFav {
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_ADD_FAV
                               body:@{@"driverId":@(self.favorite.userId)}
                           complete:^(FCResponse *response, NSError *error) {
                               [IndicatorUtils dissmiss];
                               BOOL ok = [(NSNumber*) response.data boolValue];
                               if (response.status == APIStatusOK && ok) {
                                   [self addDriverToMyList:YES];
                               }
                               else {
                                   [IndicatorUtils dissmiss];
                               }
                           }];
}

- (void) apiRemoveFav {
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_REMOVE_FAV
                               body:@{@"driverId":@(self.favorite.userId)}
                           complete:^(FCResponse *response, NSError *error) {
                               BOOL ok = [(NSNumber*) response.data boolValue];
                               if (response.status == APIStatusOK && ok) {
                                   [self removeDriverFromMyList];
                               }
                               else {
                                   [IndicatorUtils dissmiss];
                               }
                           }
     ];
}

- (void) apiAddBlackList {
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_ADD_TO_BLACK_LIST
                               body:@{@"userId":@(self.favorite.userId)}
                           complete:^(FCResponse *response, NSError *error) {
                               [IndicatorUtils dissmiss];
                               BOOL ok = [(NSNumber*) response.data boolValue];
                               if (response.status == APIStatusOK && ok) {
                                   [self addDriverToMyList:NO];
                               }
                               else {
                                   [IndicatorUtils dissmiss];
                               }
                           }];
}

- (void) apiRemoveBlackList {
    [IndicatorUtils show];
    [[APIHelper shareInstance] post:API_REMOVE_FROM_BLACK_LIST
                               body:@{@"userId":@(self.favorite.userId)}
                           complete:^(FCResponse *response, NSError *error) {
                               BOOL ok = [(NSNumber*) response.data boolValue];
                               if (response.status == APIStatusOK && ok) {
                                   [self removeDriverFromMyList];
                               }
                               else {
                                   [IndicatorUtils dissmiss];
                               }
                           }
     ];
}

@end
