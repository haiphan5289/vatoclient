    //
//  FCHomeViewController.m
//  FaceCar
//
//  Created by facecar on 12/4/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCHomeViewController.h"
#import "KYDrawerController.h"
#import "FCLoaderView.h"
#import "FCHomeSubView.h"
#import "GoogleMapsHelper.h"
#import "AppDelegate.h"
#import "FCMapViewModel.h"
#import "MenusTableViewController.h"
#import "FCGGMapView.h"
#import "FCMainHomeView.h"
#import "FCChoosePlaceView.h"
#import "FCHomeSubMenuView.h"
#import "FCBookViewModel.h"

@interface FCHomeViewController ()
@property (weak, nonatomic) IBOutlet FCGGMapView *googleMap;
@property (weak, nonatomic) IBOutlet FCHomeSubView *headerView;
@property (weak, nonatomic) IBOutlet FCHomeSubView *footerView;
@property (weak, nonatomic) IBOutlet FCHomeSubMenuView *subMenuView;
@property (weak, nonatomic) IBOutlet UIView *loadingView; // for waiting get start
@property (weak, nonatomic) IBOutlet FCButton *btnLocation;

@property (strong, nonatomic) FCMapViewModel* mapViewModel;
@end

@implementation FCHomeViewController {
    FCLoaderView* _animationLoaderView;
    KYDrawerController *_menuViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.homeViewModel = [[FCHomeViewModel alloc] initViewModle:self];
    self.mapViewModel = [[FCMapViewModel alloc] init:self.googleMap];
    self.mapViewModel.homeViewModel = self.homeViewModel;
    
    [self bindingLocation];
    
    // register resume app
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAppResume:)
                                                 name:NOTIFICATION_RESUME_APP
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearHome)
                                                 name:NOTIFICATION_COMPLETE_BOOKING
                                               object:nil];
    
    UITapGestureRecognizer* loadingTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onLoadingTap)];
    [self.loadingView addGestureRecognizer:loadingTap];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self animationLoadHome];
    [self.view layoutSubviews];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_menuViewController) {
        [self configsView];
        [self configGoogleMap];
        
        // checking lastest booking
        [self.homeViewModel checkingLastestBooking];
    }
    
    [self.homeViewModel checkingValidAuth];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void) onAppResume: (id) sender {
    if ([self shouldReload]) {
        [self bindingLocation];
    }
}

- (BOOL) shouldReload {
    for (UIView* view in self.view.subviews) {
        if ([view isKindOfClass:[FCMainHomeView class]]) {
            return NO;
        }
    }
    
    return YES;
}

- (void) zoomMapToBoundDrivers {
    [RACObserve(self.homeViewModel, listDriverOnline) subscribeNext:^(NSMutableArray* list) {
        if (list.count > 0) {
            NSInteger count = MIN(5, list.count);
            GMSCoordinateBounds* bounds = [[GMSCoordinateBounds alloc] init];
            for (int i = 0; i < count; i++) {
                FCDriverSearch* driver = [list objectAtIndex:i];
                FCLocation* location = driver.location;
                if (location && location.lat > 0 && location.lon > 0) {
                    bounds = [bounds includingCoordinate:CLLocationCoordinate2DMake(location.lat, location.lon)];
                }
            }
            
            CLLocation* curr = [GoogleMapsHelper shareInstance].currentLocation;
            if (curr && curr.coordinate.latitude > 0) {
                bounds = [bounds includingCoordinate:curr.coordinate];
            }
            
            [self.mapViewModel zommMapToBound:bounds];
        }
    }];
}

- (void) configsView {
    
    ((AppDelegate*) [UIApplication sharedApplication].delegate).homeViewModel = self.homeViewModel;
    
    _menuViewController = (KYDrawerController*)self.parentViewController;
    MenusTableViewController* menuview = (MenusTableViewController*) _menuViewController.drawerViewController;
    menuview.homeViewModel = self.homeViewModel;
    [menuview bindingData];
    
    // menu footer view
    [self.subMenuView setHomeViewModel:self.homeViewModel];
    [self.subMenuView addItems:@[@(FCHomeSubMenuBookNow), @(FCHomeSubMenuPromotion)]];
    
}

- (void) configGoogleMap {
    [self.googleMap addLocationButton: self.btnLocation];
}

- (void) bindingLocation {
    CLLocation* location = [GoogleMapsHelper shareInstance].currentLocation;
    if (location) {
        [self onStartChanged:location];
    }
    else {
        __block RACDisposable *handler = [RACObserve([GoogleMapsHelper shareInstance], currentLocation) subscribeNext:^(CLLocation* location) {
            if (location) {
                [self onStartChanged:location];
                [handler dispose];
            }
        }];
    }
    
    // checking location enable
    [RACObserve([GoogleMapsHelper shareInstance], locationError) subscribeNext:^(id x) {
        NSInteger stt = [CLLocationManager authorizationStatus];
        [self.homeViewModel loadLocationServiceNotifyView: (stt == kCLAuthorizationStatusAuthorizedWhenInUse
                                                            ||stt == kCLAuthorizationStatusAuthorizedAlways)];
    }];
}

- (void) clearHome {
    self.homeViewModel.currentSearchData = nil;
    [self.homeViewModel.bookViewModel clear]; // clear and reinit
    [self bindingLocation];
}

#pragma mark - Action Handler
- (IBAction)onMenuClicked:(id)sender {
    [_menuViewController setDrawerState:KYDrawerControllerDrawerStateOpened
                               animated:YES];
}

- (IBAction)bookClicked:(id)sender {
    [self onBookClicked];
}

- (void)onBookClicked {
//    self.loadingView.hidden = NO;
//    __block BOOL require = YES;
//    __autoreleasing RACDisposable* handler = [RACObserve(self.homeViewModel.bookViewModel, start) subscribeNext:^(FCPlace* x) {
//        if (x && x.name.length > 0 && require) {
//            require = NO;
//            self.loadingView.hidden = YES;
            [self loadMainBookView];
//        }
//    }];
//    [handler dispose];
}

- (IBAction)addressClicked:(id)sender {
//    self.loadingView.hidden = NO;
//    __block BOOL require = YES;
//    __autoreleasing RACDisposable* handler = [RACObserve(self.homeViewModel.bookViewModel, start) subscribeNext:^(FCPlace* x) {
//        if (x && x.name.length > 0 && require) {
//            require = NO;
//            self.loadingView.hidden = YES;
            [self loadSearchPlaceView: FCPlaceSearchTypeFull];
//        }
//    }];
//    [handler dispose];
}

- (void) animationLoadHome {
    if (!_animationLoaderView) {
        _animationLoaderView = [[FCLoaderView alloc] init];
        [self.view addSubview:_animationLoaderView];
        [_animationLoaderView start:^{
            [self animationLoadMenus];
        }];
    }
}

- (void) animationLoadMenus {
    [self.headerView animationShow];
    [self.footerView animationShow];
}

- (void) forceAnimationReloadMenus {
    [self.footerView resetAnimationShow];
    [self.headerView resetAnimationShow];
    [self animationLoadMenus];
}

- (void) loadMainBookView {
    [self.homeViewModel loadMainBookView];
}

- (void) loadSearchPlaceView: (FCPlaceSearchType) type {
    [self.homeViewModel loadSearchPlaceView:type
                                     inView:self.view
                                      block:^(BOOL cancelView, BOOL completedView) {
                                          if (cancelView) {
                                              [self forceAnimationReloadMenus];
                                          }
                                          else if (completedView) {
                                              [self loadMainBookView];
                                          }
                                      }];
}

- (void) onLoadingTap {
    self.loadingView.hidden = YES;
}

#pragma mark - Booking Info
- (void) onStartChanged:(CLLocation*)location
{
    self.loadingView.hidden = YES;
    
    // place
    [GoogleMapsHelper getFCPlaceByLocation:location
                                     block:^(FCPlace * place) {
//                                         self.homeViewModel.bookViewModel.start = place;
                                         [self.homeViewModel checkingStartChanged:place];

                                         // marker start
//                                         GMSMarker* marker = [self.mapViewModel addStartMarker:place];
//                                         [(FCMapMarker*) marker.iconView setMarkerStyle:FCMarkerStyleStartOnlyIcon];
//                                         [(FCMapMarker*) marker.iconView setHidden:YES];
                                     }];


    
    // reload map
    [self.googleMap moveCameraTo:location];
    
    // update zoneid info
//    [[FirebaseHelper shareInstance] updateLocationInfo:location];
}

@end
