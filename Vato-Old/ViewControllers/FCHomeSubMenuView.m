//
//  FCHomeSubMenuView.m
//  FaceCar
//
//  Created by facecar on 12/10/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCHomeSubMenuView.h"
#import "FCWarningNofifycationView.h"
#import "FCHomeSubMenuItem.h"
#import "FCHomeViewController.h"
#import "FCBookViewModel.h"

@interface FCHomeSubMenuView ()
@end

@implementation FCHomeSubMenuView {
    void (^_subMenuClickedCallback) (NSInteger);
    BOOL _isFavDriver;
    NSMutableDictionary* _listMenus;
}


- (void) addItems:(NSArray *)items {
    if (items <= 0) {
        return;
    }
    
    if (!_listMenus) {
        _listMenus = [[NSMutableDictionary alloc] init];
    }
    
    CGFloat w = self.frame.size.width/items.count;
    CGFloat h = self.frame.size.height;
    
    for (int i = 0; i < items.count; i++) {
        CGRect frame = CGRectMake(i*w, 0, w, h);
        NSInteger type = [[items objectAtIndex:i] integerValue];
        FCHomeSubMenuItem* itemView = [[FCHomeSubMenuItem alloc] init];
        itemView.frame = frame;
        
        if (type == FCHomeSubMenuBookNow) {
            [itemView itemWithIcon:@[[UIImage imageNamed:@"phone-g"]]
                             lable:@[localizedFor(@"Gọi xe\nnhanh")]
                             click:^{
                                 [self bookNowClicked:nil];
                             }];
        }
        else if (type == FCHomeSubMenuFavDriver) {
            NSArray* icons = @[[UIImage imageNamed:@"fav-driver"], [UIImage imageNamed:@"fav-driver-b"]];
            NSArray* titles = @[localizedFor(@"Tất cả lái xe"), localizedFor(@"Tài xế riêng")];
            [itemView itemWithIcon: icons
                             lable: titles
                             click:^{
                                 [self favDriverClicked:nil];
                             }];
        }
        else if (type == FCHomeSubMenuPromotion) {
            [itemView itemWithIcon:@[[UIImage imageNamed:@"gift-w"]]
                             lable:@[localizedFor(@"Khuyến\nmãi")]
                             click:^{
                                 [self giftClicked:nil];
                             }];
        }
        else if (type == FCHomeSubMenuTaxi) {
            [itemView itemWithIcon:@[[UIImage imageNamed:@"taxi"]]
                             lable:@[@"Taxi"]
                             click:^{
                                 [self taxiClicked:nil];
                             }];
        }
        
        [self addSubview:itemView];
        [_listMenus setObject:itemView forKey:@(type)];
    }
}

- (void) setHomeViewModel:(FCHomeViewModel*)homeViewModel {
    
    [RACObserve(homeViewModel, countGift) subscribeNext:^(id x) {
        [self loadGiftStatus: [x integerValue]];
    }];
    
    _homeViewModel = homeViewModel;
}

- (void) loadGiftStatus: (NSInteger) count {
    FCHomeSubMenuItem* menuView = [_listMenus objectForKey:@(FCHomeSubMenuPromotion)];
    [menuView showBadge:count];
}

#pragma mark - Action handler
- (void) setMenuClickCallback:(void (^)(NSInteger))block {
    _subMenuClickedCallback = block;
}

- (IBAction)bookNowClicked:(id)sender {
     [(FCHomeViewController*)self.homeViewModel.viewController onBookClicked];
}

- (IBAction)favDriverClicked:(id)sender {
    BOOL fav = self.homeViewModel.bookViewModel.favDriver;
    fav = !fav;
    self.homeViewModel.bookViewModel.favDriver = fav;
    
    if (_subMenuClickedCallback) {
        _subMenuClickedCallback(FCHomeSubMenuFavDriver);
    }
}

- (IBAction)giftClicked:(id)sender {
    
    [self.homeViewModel loadListPromotionView: NO];
    
    if (_subMenuClickedCallback) {
        _subMenuClickedCallback(FCHomeSubMenuPromotion);
    }
}

- (IBAction)taxiClicked:(id)sender {
    FCHomeSubMenuItem* menuView = [_listMenus objectForKey:@(FCHomeSubMenuTaxi)];
    CGPoint originGlobal = [menuView.superview convertPoint:menuView.frame.origin
                                                     toView:nil];
    originGlobal.x += menuView.frame.size.width/2;
    
    [self.homeViewModel loadListTaxiView:originGlobal];
    
    if (_subMenuClickedCallback) {
        _subMenuClickedCallback(FCHomeSubMenuTaxi);
    }
}

@end
