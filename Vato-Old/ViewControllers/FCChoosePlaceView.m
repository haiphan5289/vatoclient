//
//  FCChoosePlaceView.m
//  FaceCar
//
//  Created by facecar on 12/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCChoosePlaceView.h"
#import "GoogleAutoCompleteViewController.h"
#import "FCHomeSubView.h"
#import "GoogleMapsHelper.h"
#import <Realm/Realm.h>
#import "FCBookViewModel.h"

#if DEV
#import "VATO_DEV-Swift.h"
#elif STG
#import "VATO_Staging-Swift.h"
#else
#import "VATO-Swift.h"
#endif

#define SEARCHING @"Đang tìm ..."
#define kBgDisable UIColorFromRGB(0xFAFAFA)
#define kBgEnable UIColorFromRGB(0xE8EAF6)

typedef enum : NSUInteger {
    START_PLACE = 1,
    END_PLACE = 2
} FCPlaceType;


typedef void(^GooglePlaceSearchCallback) (FCPlace* place);

@interface FCChoosePlaceView () {

    RACDisposable *googlePlacedisposable_;
}
@property (weak, nonatomic) IBOutlet FCHomeSubView *headerView;
@property (weak, nonatomic) IBOutlet FCGGMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *searchCustomView; // only start or end info
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet FCTextField *tfCustomAddress; // for edit only start or end
@property (weak, nonatomic) IBOutlet FCButton *btnComplete;
@property (weak, nonatomic) IBOutlet FCButton *btnLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblMarkerInfo;
@property (weak, nonatomic) IBOutlet FCView *windowInfo;

@property (nonatomic) BOOL isUsingHistory;
@property (nonatomic) FCPlaceType choosedType;
@property (nonatomic, weak) GoogleAutoCompleteViewController* searchPlaceView;
@property (nonatomic) GooglePlaceSearchCallback googlePlaceSearchCallback;

@end


@implementation FCChoosePlaceView {



}

- (id) init {
    self = [super init];
    if (self) {
//        self = (FCChoosePlaceView*)[[[NSBundle mainBundle] loadNibNamed:@"FCChoosePlaceView"
//                                                                 owner:self
//                                                               options:nil] firstObject];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_handleLocationUpdatedNotification:)
                                                     name:NOTIFICATION_LOCAITON_UPDATEED
                                                   object:nil];
    }

    return self;
}

- (void)dealloc {
    [googlePlacedisposable_ dispose];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
}

- (void) setHomeViewModel:(FCHomeViewModel *)homeViewModel {
    _homeViewModel = homeViewModel;

    if (_searchType == FCPlaceSearchTypeStart) {
        [self getPlaceStartFromHistory: nil];
    }
    
    [self configView];
}

- (void) getPlaceStartFromHistory: (void (^)(FCPlace* place)) block {
    __weak FCPlace *start = self.homeViewModel.bookViewModel.start;
    CLLocation* location = nil;
    if (start) {
        location = [[CLLocation alloc] initWithLatitude:start.location.lat longitude:start.location.lon];
    }
    if (!location) {
        location = [GoogleMapsHelper shareInstance].currentLocation;
    }
    
    [[FirebaseHelper shareInstance] getAppConfigure:^(FCAppConfigure * _Nullable appconfigure) {
        if (location) {
            double_t maxDistance = appconfigure.booking_configure.suggestion_max_distance;
            NSInteger maxDay = appconfigure.booking_configure.suggestion_max_day;
            __autoreleasing LocationHistory *history = [LocationHistory searchWithLatitude:location.coordinate.latitude
                                                                                 longitude:location.coordinate.longitude
                                                                               maxDistance:maxDistance
                                                                                    maxDay:maxDay];
            if (history) {
                FCPlace* tempStart = [[FCPlace alloc] init];
                tempStart.zoneId = history.zoneID;
                tempStart.name = history.name;
                tempStart.address = history.address;
                tempStart.location = [[ FCLocation alloc] initWithLat:history.lat lon:history.lng];
                
                self.isUsingHistory = YES;
                
                self.tempPlace = tempStart;
//                self.tempPlaceStart = tempStart;
                [self setCustomPlaceView:tempStart];
                
                _btnComplete.enabled = YES;
                
                if (block) {
                    block(tempStart);
                }
            }
            else if (block) {
                block(nil);
            }
        }
        else if (block) {
            block(nil);
        }
    }];
}

- (void) configView {
    [self configMapView];
    [self configSearchView];
    [self configCustomType];
    [self setGoogleMapGeocodingCallback];

    if ([self isIpad]) {
        self.windowInfo.hidden = YES;
    }
}

- (void) configCustomType {
    self.searchCustomView.hidden = NO;
    
    if (_searchType == FCPlaceSearchTypeFull) {
        [self showConfirmEndView];
    }
    else if ((_searchType & FCPlaceSearchTypeStart) == FCPlaceSearchTypeStart) {
        
        [self showConfirmStartView];
    }
    else if ((_searchType & FCPlaceSearchTypeEnd) == FCPlaceSearchTypeEnd) {
        [self showConfirmEndView];
    }
}

- (void) showConfirmStartView {
    _choosedType = START_PLACE;

    self.lblTitle.text = @"Xác nhận điểm đón của bạn";
    self.tfCustomAddress.placeholder = @"Nhập điểm đón";
    self.lblMarkerInfo.text = @"Di chuyển điểm đón";
    [self.btnComplete setTitle:@"Xác nhận điểm đón" forState:UIControlStateNormal];
    [self.btnComplete setEnableColor:DARK_GREEN];

    // move map to current start place
    FCPlace* start = _tempPlaceStart != nil ? _tempPlaceStart : self.homeViewModel.bookViewModel.start;
    if (start && start.location.lat != 0) {
        [_mapView reset];
        [self.mapView animationCameraTo:[[CLLocation alloc] initWithLatitude:start.location.lat
                                                                   longitude:start.location.lon]
                                   zoom:17];
        
        if (start.name.length > 0) {
            self.tempPlace = start;
            self.tfCustomAddress.text = start.name;
        }
    }
    else {
        [self getPlaceStartFromHistory:^(FCPlace *place) {
            if (place) {
                [_mapView reset];
                [self.mapView animationCameraTo:[[CLLocation alloc] initWithLatitude:place.location.lat
                                                                           longitude:place.location.lon]
                                           zoom:17];
            }
            else {
                CLLocation* location = [GoogleMapsHelper shareInstance].currentLocation;
                [self.mapView animationCameraTo:location zoom:17];
                
                [GoogleMapsHelper getFCPlaceByLocation:location block:^(FCPlace * place) {
                    if (place) {
                        self.tempPlace = place;
                        self.tfCustomAddress.text = place.name;
                    }
                }];
            }
        }];
        
    }
    
    [_searchPlaceView hide];
    [self listenerMapDidMove];
}

- (void) showConfirmEndView {
    _choosedType = END_PLACE;

    self.lblTitle.text = @"Bạn muốn đến đâu?";
    self.tfCustomAddress.text = @"";
    self.tfCustomAddress.placeholder = @"Nhập điểm đến";
    self.lblMarkerInfo.text = @"Di chuyển điểm đến";
    [self.btnComplete setTitle:@"Xác nhận điểm đến" forState:UIControlStateNormal];
    [self.btnComplete setEnableColor:[UIColor orangeColor]];

    [self.tfCustomAddress becomeFirstResponder];
    [self customAddressBeginEditing:nil];

    // move map to current start place
    FCPlace* end = _tempPlaceEnd != nil ? _tempPlaceEnd : self.homeViewModel.bookViewModel.end;
    if (end != nil) {
        [_mapView reset];
        [self.mapView animationCameraTo:[[CLLocation alloc] initWithLatitude:end.location.lat
                                                                   longitude:end.location.lon]
                                   zoom:17];

        _tempPlace = end;
        self.btnComplete.enabled = YES;
    } else {
        self.btnComplete.enabled = NO;
    }

    if (end.name.length > 0) {
        self.tfCustomAddress.text = end.name;
    }
}

- (void) checkFinished: (FCPlace*) place {
    if (_choosedType == START_PLACE) {
        self.tempPlaceStart = place;
    }
    else if (_choosedType == END_PLACE) {
        self.tempPlaceEnd = place;
    }
    
    if (_searchType == FCPlaceSearchTypeFull) {
        if (!_tempPlaceStart) {
            [self showConfirmStartView];
        }
        else if (!_tempPlaceEnd) {
            [self showConfirmEndView];
        }
        else {
            [self finished];
        }
    }
    else {
        if ((_searchType & FCPlaceSearchTypeStart) == FCPlaceSearchTypeStart) {
            if (_tempPlaceStart) {
                [self finished];
            }
        }
        else if ((_searchType & FCPlaceSearchTypeEnd) == FCPlaceSearchTypeEnd) {
            if (_tempPlaceEnd) {
                [self finished];
            }
        }
    }
}

#pragma mark - Maps handler
- (void) configMapView {
    
    // move to current location which change
    __autoreleasing CLLocation* location = nil;
    if (self.homeViewModel.bookViewModel.start.location.lat != 0 && self.homeViewModel.bookViewModel.start.location.lon != 0) {
        location = [[CLLocation alloc] initWithLatitude:self.homeViewModel.bookViewModel.start.location.lat
                                              longitude:self.homeViewModel.bookViewModel.start.location.lon];
    }
    else {
        location = [GoogleMapsHelper shareInstance].currentLocation;
    }
    
    if ((_searchType & FCPlaceSearchTypeEnd) == FCPlaceSearchTypeEnd) {
        location = [[CLLocation alloc] initWithLatitude:self.homeViewModel.bookViewModel.end.location.lat
                                              longitude:self.homeViewModel.bookViewModel.end.location.lon];
    }

//    __autoreleasing CLLocation* location = GoogleMapsHelper.shareInstance.currentLocation;
    [self.mapView moveCameraTo:location
                          zoom:16];

    
    // button location
    self.mapView.btnLocationPosition = CGPointMake(self.frame.size.width - kBtnLocationSize - 25 * [UIScreen mainScreen].scale/2, self.frame.size.height - 100 * [UIScreen mainScreen].scale/2);
    [self.mapView addLocationButton: self.btnLocation];
}

#pragma mark - Map Move
- (void) listenerMapDidMove {
    __weak FCChoosePlaceView * const weakSelf = self;
    __block BOOL firstTime = YES;
    [self.mapView setCameraChangedCallback:^(GMSCameraPosition * x) {
        weakSelf.btnComplete.enabled = NO;
        if (!firstTime) {
            [weakSelf setCustomPlaceView:nil];
        }
        firstTime = NO;
    }];
}

- (void) removeMapMoveListener {
    [self.mapView setCameraChangedCallback:nil];
}

- (void) setGoogleMapGeocodingCallback {
    __weak FCChoosePlaceView const *weakSelf = self;

    [_mapView setGeocodingCallback:^(FCPlace* place) {
        if (!place) return;
        weakSelf.tempPlace = place;
        [weakSelf setCustomPlaceView:place];
    }];
}

- (void) removeGoogleMapGeocodingCallback {
    if (!googlePlacedisposable_) [googlePlacedisposable_ dispose];
    [self.mapView setGeocodingCallback: nil];
}


#pragma mark - Google autoplace search

- (void) configSearchView {
    // init
    GoogleAutoCompleteViewController *searchView = [[[NSBundle mainBundle] loadNibNamed:@"GoogleAutoCompleteViewController" owner:nil options:nil] firstObject];
    [self addSubview:searchView];

    _searchPlaceView = searchView;
    [_searchPlaceView setMapview:self.mapView];
    [_searchPlaceView setMarginTop:220];
    [_searchPlaceView setMarginBottom:0];

    [_searchPlaceView setSuperView:self withBackgound:nil];


    [self bringSubviewToFront:self.headerView];

    // result callback
    [self listenerGooglePlaceCallback];
}

- (void) enableContinue {
    self.btnComplete.enabled = YES;
    [self setGoogleMapGeocodingCallback];
}

- (void) listenerGooglePlaceCallback {
    if (!googlePlacedisposable_) [googlePlacedisposable_ dispose];

    __weak FCChoosePlaceView * const weakSelf = self;
    googlePlacedisposable_ = [RACObserve(_searchPlaceView.googleViewModel, place) subscribeNext:^(FCPlace* place) {
        if (place && weakSelf) {
            [weakSelf removeGoogleMapGeocodingCallback];

            if (weakSelf.searchType == FCPlaceSearchTypeFull) {
                if (weakSelf.choosedType == END_PLACE) {
                    [weakSelf.mapView animationCameraTo:[[CLLocation alloc] initWithLatitude:place.location.lat
                                                                                   longitude:place.location.lon]
                                                   zoom:17];

                    weakSelf.tempPlace = place;
                    [weakSelf.searchPlaceView.progressView dismiss];
                    [weakSelf.searchPlaceView hide];
                    weakSelf.tfCustomAddress.text = place.name;
                    [weakSelf.tfCustomAddress resignFirstResponder];
                    [weakSelf bringSubviewToFront:weakSelf.btnComplete];
                    [weakSelf.btnComplete setTitle:@"Xác nhận điểm đến" forState:UIControlStateNormal];
                    [weakSelf.btnComplete setEnableColor:[UIColor orangeColor]];
                    weakSelf.lblMarkerInfo.text = @"Di chuyển điểm đến";
                    [NSTimer scheduledTimerWithTimeInterval:1.5 target:weakSelf selector:@selector(enableContinue) userInfo:nil repeats:NO];
                    [weakSelf listenerMapDidMove];
                }
                else {
                    [weakSelf checkFinished: place];
                }
            } else {
                [weakSelf checkFinished: place];
            }

            if (weakSelf.googlePlaceSearchCallback) {
                weakSelf.googlePlaceSearchCallback(place);
            }
        }
    }];

    RAC(self.btnComplete, enabled) = [RACSignal combineLatest:@[RACObserve(self, tempPlace)]
                                                       reduce:^(FCPlace* place){
                                                           return @(place != nil);
                                                       }];
}

- (void) loadSearchPlaceView: (void (^) (FCPlace*)) block {
    // search reseult callback
    _googlePlaceSearchCallback = block;
    
    // layout callback
    __weak FCChoosePlaceView *weakSelf = self;
    [_searchPlaceView setInteractionListener:^(BOOL isHiden, BOOL isShowed) {
        if (isHiden) {
            [weakSelf.tfCustomAddress resignFirstResponder];
            [weakSelf setGoogleMapGeocodingCallback];
        }
        else if (isShowed) {
            [weakSelf removeGoogleMapGeocodingCallback];
        }
    }];
    
    [_searchPlaceView setSearchView:self.tfCustomAddress];
    
    // show google place picker
    [_searchPlaceView show];
    [self removeMapMoveListener];
}


#pragma mark - Layout
- (void) setCustomPlaceView: (FCPlace*) place {
    if (place && place.name.length > 0) {
        self.tfCustomAddress.text = place.name;
        self.tfCustomAddress.textColor = [UIColor blackColor];
    }
    else {
        self.tfCustomAddress.text = SEARCHING;
        self.tfCustomAddress.textColor = [UIColor lightGrayColor];
    }
}


#pragma mark - Action Handler

- (IBAction)onGeocodingTap:(id)sender {
    [_searchPlaceView hide];
    [self listenerMapDidMove];
}

- (IBAction)backClicked:(id)sender {
    if (_searchType == FCPlaceSearchTypeFull) {
        if (_choosedType == START_PLACE) {
            _tempPlaceEnd = nil; // clear
            [self showConfirmEndView];
            return;
        }
    }
    self.isFinishedView = YES;
    [self removeFromSuperview];
    if (!googlePlacedisposable_) [googlePlacedisposable_ dispose];
}

- (IBAction)doneClicked:(id)sender {
    
    // save history
//    if (_choosedType == START_PLACE) {
//        [_searchPlaceView.googleViewModel saveHistory:_tempPlace];
//    }
    
    [self checkFinished:_tempPlace];
}

- (void) finished {
    if (![self canFinished]) {
        return;
    }
    
    if (_tempPlaceStart) {
        self.homeViewModel.bookViewModel.start = _tempPlaceStart;
    }
    if (_tempPlaceEnd) {
        self.homeViewModel.bookViewModel.end = _tempPlaceEnd;
    }

    // Insert both start & end location into database for next time usage
    // PS: We only care about user's experience, we don't really care about exact location

    __autoreleasing RLMRealm *realm = [RLMRealm defaultRealm];
    __autoreleasing LocationHistory *startHistory = nil;
    if (_tempPlaceStart) {
        [_searchPlaceView.googleViewModel saveHistory:_tempPlaceStart];
        startHistory = [LocationHistory search:_tempPlaceStart.name];
        if (!startHistory) {
            startHistory = [[LocationHistory alloc] init];
            startHistory.address = _tempPlaceStart.address;
            startHistory.name = _tempPlaceStart.name;
            startHistory.counter = 1;
            startHistory.lastUsedTime = [NSDate date];

            startHistory.zoneID = _tempPlaceStart.zoneId;
            startHistory.lat = _tempPlaceStart.location.lat;
            startHistory.lng = _tempPlaceStart.location.lon;

            [realm beginWriteTransaction];
            [realm addObject:startHistory];

            __autoreleasing NSError *err;
            [realm commitWriteTransaction:&err];

            if (err) {
                DLog(@"%@", err.localizedDescription);
            }
        } else {
            [realm beginWriteTransaction];
            startHistory.counter += 1;
            startHistory.lastUsedTime = [NSDate date];

            __autoreleasing NSError *err;
            [realm commitWriteTransaction:&err];

            if (err) {
                DLog(@"%@", err.localizedDescription);
            }
        }
    }

    __autoreleasing LocationHistory *endHistory = nil;
    if (_tempPlaceEnd) {
        [_searchPlaceView.googleViewModel saveHistory:_tempPlaceEnd];
        endHistory = [LocationHistory search:_tempPlaceEnd.name];
        if (!endHistory) {
            endHistory = [[LocationHistory alloc] init];
            endHistory.address = _tempPlaceEnd.address;
            endHistory.name = _tempPlaceEnd.name;
            endHistory.counter = 1;
            endHistory.lastUsedTime = [NSDate date];

            endHistory.zoneID = _tempPlaceEnd.zoneId;
            endHistory.lat = _tempPlaceEnd.location.lat;
            endHistory.lng = _tempPlaceEnd.location.lon;

            [realm beginWriteTransaction];
            [realm addObject:endHistory];

            __autoreleasing NSError *err;
            [realm commitWriteTransaction:&err];

            if (err) {
                DLog(@"%@", err.localizedDescription);
            }
        } else {
            [realm beginWriteTransaction];
            endHistory.counter += 1;
            endHistory.lastUsedTime = [NSDate date];

            __autoreleasing NSError *err;
            [realm commitWriteTransaction:&err];

            if (err) {
                DLog(@"%@", err.localizedDescription);
            }
        }
    }

    self.isDone = YES;
    [self removeFromSuperview];
}

- (BOOL) canFinished {
    FCPlace* start = _tempPlaceStart;
    FCPlace* end = _tempPlaceEnd;
    if (_searchType == FCPlaceSearchTypeFull) {
        return start != nil && end != nil;
    }
    else if ((_searchType & FCPlaceSearchTypeEnd) == FCPlaceSearchTypeEnd) {
        return end != nil;
    }
    else if ((_searchType & FCPlaceSearchTypeStart) == FCPlaceSearchTypeStart) {
        return start != nil;
    }
    
    return NO;
}

- (IBAction)customAddressBeginEditing:(id)sender {
    [self.tfCustomAddress selectAll:sender];
    
    [self loadSearchPlaceView:^(FCPlace* place) {

    }];
}

#pragma mark - Class's private methods
- (void)_handleLocationUpdatedNotification:(NSNotification *)notification {
    /* Condition validation: we only accepted CLLocation */
    if (![notification.object isKindOfClass:[CLLocation class]]) return;

    /* Condition validation: we only receive the update when user is in added mode */
    if ((_searchType & FCPlaceSearchTypeEnd) != FCPlaceSearchTypeEnd) return;

    /* Condition validation: ignore event if user is manual pick location */
    if (!self.mapView.isManualMoved) {
        return;
    }

    __autoreleasing CLLocation *newLocation = (CLLocation *) notification.object;
    [self.mapView moveCameraTo:newLocation zoom:16];
}

@end
