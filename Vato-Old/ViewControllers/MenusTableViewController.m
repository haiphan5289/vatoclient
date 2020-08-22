//
//  MenusTableViewController.m
//  FaceCar
//
//  Created by Vu Dang on 6/1/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "MenusTableViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "KYDrawerController.h"
#import "FacecarNavigationViewController.h"
#import <GoogleSignIn/GoogleSignIn.h>
#import "CustomMenuHeader.h"
#import "UIView+Border.h"
#import "FCNotifyViewController.h"
#import "FCWalletViewController.h"
#import "FCNotifyPageViewController.h"
#import "ProfileViewController.h"
#import "FavoriteViewController.h"
#import "InviteViewController.h"
#import "FCHelpViewController.h"
#import "ProfileDetailViewController.h"
#import "UIImageView+Helper.h"
@interface MenusTableViewController () <FCNotifyViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblUnreadNotify;
@end

@implementation MenusTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KYDrawerController *elDrawer = (KYDrawerController*)self.parentViewController;
    self.homeViewModel = [[FCHomeViewModel alloc] initViewModle:elDrawer];
    [self bindingData];
    [self.lblUnreadNotify circleView:[UIColor clearColor]];
    self.lblUnreadNotify.hidden = YES;
    
    // init icon profile
    self.navigationController.navigationBar.hidden = YES;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    if (self.tableView.contentSize.height > [UIScreen mainScreen].bounds.size.height) {
        [self.tableView setScrollEnabled:YES];
        self.tableView.contentOffset = CGPointMake(0, 20);
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) bindingData {
    @weakify(self);
    [RACObserve(self.homeViewModel, totalUnreadNotify) subscribeNext:^(id x) {
        @strongify(self);
        if (x && [x isKindOfClass:[NSNumber class]]) {
            NSInteger unread = [x integerValue];
            [self.lblUnreadNotify setHidden:unread <= 0];
            [self.lblUnreadNotify setText:unread > 9 ? @"9+" : [NSString stringWithFormat:@"%ld", (long)unread]];
        }
    }];
    
    [RACObserve(self.homeViewModel, client) subscribeNext:^(FCClient* x) {
        if (x) {
            @strongify(self);
            [self.tableView reloadData];
        }
    }];
}

- (void) onProfileClicked: (id) sender {
    UIViewController * vc = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileDetailViewController"];
    FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
    [self presentViewController:navController animated:TRUE completion:nil];
}

- (void) showHome {
    KYDrawerController *elDrawer = (KYDrawerController*)self.parentViewController;
    [elDrawer setDrawerState:KYDrawerControllerDrawerStateClosed animated:YES];
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender {
    DLog(@"")
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 170;
    }
    
    return 44;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CustomMenuHeader *headerView = [[[NSBundle mainBundle] loadNibNamed:@"CustomMenuHeader" owner:self options:nil] objectAtIndex:0];
    
    headerView.homViewModel = self.homeViewModel;
    [headerView setProfileClickCallback:^{
        [self onProfileClicked:nil];
    }];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UILabel *label = [UILabel castFrom:[cell viewWithTag:1000]];
    if (label.text) {
        label.text = localizedFor(label.text);
    }

    UIImageView *imgView = [cell.contentView.subviews firstBy:^BOOL(__kindof UIView * _Nonnull view) {
        return [view isKindOfClass:[UIImageView class]];
    }];
    if (imgView) {
        UIColor *color = [UIColor colorWithRed:140/255.f green:140/255.f blue:140/255.f alpha:1];
        [imgView setImageColor:color];
    }
    
}

- (NSString*) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        return [NSString stringWithFormat:@"%@ %@", localizedFor(@"Phiên bản"), version];
    }
    
    return @"";
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UIViewController *vc;
        
        if (indexPath.row == HistoryBook) {
            vc = [[FCTripManagerViewController alloc] init];
        } else if (indexPath.row == Wallet) {
//            vc = [[FCWalletViewController alloc] initView:self.homeViewModel];
        } else if (indexPath.row == Favorite) {
            vc = [[FavoriteViewController alloc] initView:self.homeViewModel
                                                     type:ViewTypeFavorite];
        } else if (indexPath.row == Block) {
            vc = [[FavoriteViewController alloc] initView:self.homeViewModel
                                                     type:ViewTypeBlock];
        } else if (indexPath.row == Invite) {
//            vc = [[InviteViewController alloc] init];
//            [(InviteViewController*)vc setHomeviewModel:self.homeViewModel];
        } else if (indexPath.row == Notify) {
            FCNotifyViewController *notifyVC = [[FCNotifyViewController alloc] initView];
            notifyVC.delegate = self;
            notifyVC.homeViewModel = self.homeViewModel;
            vc = notifyVC;
        } else if (indexPath.row == Supporter) {
            vc = [[FCHelpViewController alloc] init];
        } else if (indexPath.row == FavoritePlace   ) {
            vc = [[FavoritePlaceViewController alloc] init];
        }
        
        if (vc) {
            FacecarNavigationViewController *navController = [[FacecarNavigationViewController alloc]initWithRootViewController:vc];
            [self presentViewController:navController animated:TRUE completion:nil];
//            [self showHome];
        }
        
        if ([self.delegate respondsToSelector:@selector(onSelectedMenu:)]) {
            [self.delegate onSelectedMenu:indexPath.row];
        }
    }
}

- (void) onSelectedNotification:(FCNotification *)data {
    if ([self.delegate respondsToSelector:@selector(onSelectedNotification:)]) {
        [self.delegate onSelectedNotification:data];
    }
}

- (void)dealloc {
    DLog(@"%s", __FUNCTION__);
}

@end
