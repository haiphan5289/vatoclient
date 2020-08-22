//
//  GoogleViewModel.m
//  FaceCar
//
//  Created by facecar on 5/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "GoogleViewModel.h"
#import "FCPlaceHistory.h"
#import "GoogleMapsHelper.h"

@interface GoogleViewModel ()

@property (nonatomic, strong) NSError *googlePlaceError;

@end

@implementation GoogleViewModel {
    __weak FCGGMapView* _mapview;
    long long _lastimeRequest;
    NSTimer* _requestTimeout;
    NSString* _currentTextSearching;

}

- (id) init:(FCGGMapView*) mapview {
    self = [super init];
    if (self) {
        _mapview = mapview;
        _lastimeRequest = [self getCurrentTimeStamp];
        self.listHistory = [[NSMutableArray alloc] init];
        self.filter = [[GMSAutocompleteFilter alloc] init];
        self.filter.country = @"VN";
        [self getHistoryPlace];
    }
    
    return self;
}

- (void)dealloc {
    DLog(@"");
}

- (void) onTimeoutWaiting {
    DLog(@"Request timeout .....");
    
    [self queryPlace:_currentTextSearching];
}

- (void) queryPlace: (NSString*) searchText {
    if (searchText.length == 0) {
        self.listPlace = nil;
        [self getHistoryPlace];
        return;
    }
    _currentTextSearching = searchText;
    long long currentTime = [self getCurrentTimeStamp];
    long long duration = currentTime - _lastimeRequest;
    if (duration < 1500) {

        if (_requestTimeout) {
            [_requestTimeout invalidate];
        }
         _requestTimeout = [NSTimer scheduledTimerWithTimeInterval:1.5f
                                                            target:self
                                                          selector:@selector(onTimeoutWaiting)
                                                          userInfo:nil
                                                           repeats:NO];
        return;
    }
    if (_requestTimeout) {
        [_requestTimeout invalidate];
    }
    _lastimeRequest = currentTime;

    [self queryPlaceByAPIService:searchText];
    
    // if Google API SDK for mobile error
    // then call API service
//    if (_googlePlaceError) {
//        [self queryPlaceByAPIService:searchText];
//    }
//    else {
//        [self queryPlaceBySDK:searchText];
//    }
}

- (void) queryPlaceBySDK: (NSString*) searchText {
    GMSCoordinateBounds* bounds = [[GMSCoordinateBounds alloc] initWithRegion:_mapview.projection.visibleRegion];
    GMSPlacesClient* client = [GMSPlacesClient sharedClient];

    __weak GoogleViewModel * const weakSelf = self;
    [client autocompleteQuery:searchText
                       bounds:bounds
                       filter:self.filter
                     callback:^(NSArray<GMSAutocompletePrediction *> * _Nullable results, NSError * _Nullable error) {
                         if (error) {
                             weakSelf.googlePlaceError = error;
                         }
                         else {
                             weakSelf.listPlace = results;
                             if (weakSelf.listPlace.count > 0) {
                                 [weakSelf.listHistory removeAllObjects];
                             }
                             else {
                                 [weakSelf getHistoryPlace];
                             }
                         }
                     }];
}

- (void) didSelectedPlace:(NSIndexPath*) indexpath {
    if (self.listPlace.count > indexpath.row) {
        [self didSelectPlace:indexpath];
    }
    else if (self.listHistory.count > indexpath.row) {
        [self didSelectHistory:indexpath];
    }
}

- (void) didSelectPlace:(NSIndexPath*) indexpath {
    
    id data = [self.listPlace objectAtIndex:indexpath.row];
    NSString* placeId = @"";
    NSString* placeName = @"";
    if ([data isKindOfClass:[GMSAutocompletePrediction class]]) {
        placeId = ((GMSAutocompletePrediction*)data).placeID;
        placeName = ((GMSAutocompletePrediction*)data).attributedPrimaryText.string;
    }
    else if ([data isKindOfClass:[FCGGPlace class]]) {
        placeId = ((FCGGPlace*)data).place_id;
        placeName = ((FCGGPlace*)data).name;
    }

    __weak GoogleViewModel * const weakSelf = self;
    [self getPlaceDetail:placeId
                callback:^(FCPlace* place) {
                    if (placeName.length > 0) {
                        place.name = placeName;
                    }
                    weakSelf.place = place;
                }];
    
//    [self saveHistory:data];
}

- (void) didSelectHistory:(NSIndexPath*) indexpath {
    FCPlaceHistory* his = [self.listHistory objectAtIndex:indexpath.row];
    if (his.location) {
        FCPlace* place = [[FCPlace alloc] init];
        place.name = his.name;
        place.address = his.address;
        place.location = his.location;
        place.zoneId = his.zoneId;
        self.place = place;
        
//        [self saveHistory:place];
    }
    else {
        __weak GoogleViewModel * const weakSelf = self;
        [self getPlaceDetail:his.placeId callback:^(FCPlace* place) {
            if (his.name.length > 0) {
                place.name = his.name;
            }
            weakSelf.place = place;
//                        [self saveHistory:place];
        }];
    }
}

- (void) saveHistory:(id) data {
    FCPlaceHistory* his = [[FCPlaceHistory alloc] init];
    if ([data isKindOfClass:[GMSAutocompletePrediction class]]) {
        his.placeId = ((GMSAutocompletePrediction*)data).placeID;
        his.name = ((GMSAutocompletePrediction*)data).attributedPrimaryText.string;
        his.address = ((GMSAutocompletePrediction*)data).attributedSecondaryText.string;
    }
    else if ([data isKindOfClass:[FCGGPlace class]]) {
        his.placeId = ((FCGGPlace*)data).place_id;
        his.name = ((FCGGPlace*)data).name;
        his.address = ((FCGGPlace*)data).address;
    }
    else if ([data isKindOfClass:[FCPlace class]]) {
        his.name = ((FCPlace*)data).name;
        his.address = ((FCPlace*)data).address;
        his.location = ((FCPlace*)data).location;
        his.zoneId = ((FCPlace*)data).zoneId;
    }

    AppLog([FIRAuth auth].currentUser.uid)

    FIRDatabaseReference* ref = [[[FIRDatabase database].reference child:TABLE_PLACE_HIS] child:[FIRAuth auth].currentUser.uid];
    [ref keepSynced:YES];
    
    // check exist place then remove first
    {
        [ref observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            if (snapshot && [snapshot.value isKindOfClass:[NSDictionary class]]) {
                for (FIRDataSnapshot* snap in snapshot.children) {
                    @try {
                        FCPlaceHistory* place = [[FCPlaceHistory alloc] initWithDictionary:snap.value error:nil];
                        if (place.placeId.length > 0 && [place.placeId isEqualToString:his.placeId]) {
                            [snap.ref removeValue];
                        }
                        else if ([place.name isEqualToString:his.name]) {
                            [snap.ref removeValue];
                        }
                    }
                    @catch(NSException* e) {
                        
                    }
                }
            }
            
            // add new place to history
            {
                NSString* key = ref.childByAutoId.key;
                NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[his toDictionary]];
                [dict addEntriesFromDictionary:@{@"timestamp": [FIRServerValue timestamp]}];
                [[ref child:key] setValue:dict];
            }
        }];
    }
}

- (void) getHistoryPlace {
    @try {
        AppLog([FIRAuth auth].currentUser.uid)

        FIRDatabaseQuery* ref = [[[[FIRDatabase database].reference
                                   child:TABLE_PLACE_HIS]
                                  child:[FIRAuth auth].currentUser.uid]
                                 queryLimitedToLast:5];
        [ref keepSynced:TRUE];

        __weak GoogleViewModel * const weakSelf = self;
        [ref observeSingleEventOfType:FIRDataEventTypeValue andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot * _Nonnull snapshot, NSString * _Nullable prevKey) {
            [weakSelf.listHistory removeAllObjects];
            NSMutableArray* list = [[NSMutableArray alloc] init];
            for (FIRDataSnapshot* s in snapshot.children) {
                NSError* err;
                FCPlaceHistory* his = [[FCPlaceHistory alloc] initWithDictionary:s.value error:&err];
                if (his) {
                    [list insertObject:his atIndex:0];
                }
            }

            weakSelf.listHistory = list;

            // clear place list
            if (weakSelf.listHistory.count > 0) {
                weakSelf.listPlace = nil;
            }
        }
        withCancelBlock:^(NSError * _Nonnull error) {

        }];
    }
    @catch (NSException* e) {
        AppError(e)
    }
}

#pragma mark - API Google service
- (void) queryPlaceByAPIService: (NSString*) textsearch {
    __weak GoogleViewModel * const weakSelf = self;
    [[GoogleMapsHelper shareInstance] apiSearchPlace:textsearch
                                              inMaps:_mapview
                                             handler:^(NSMutableArray * list) {
                                                 // callback
                                                 weakSelf.listPlace = list;
                                                 if (weakSelf.listPlace.count > 0) {
                                                     [weakSelf.listHistory removeAllObjects];
                                                 }
                                                 else {
                                                     [weakSelf getHistoryPlace];
                                                 }
                                             }];
}

- (void) getPlaceDetail: (NSString*) placeId
               callback: (void (^)(FCPlace * fcPlace)) block {
    [[GoogleMapsHelper shareInstance] apiGetPlaceDetail:placeId
                                               callback:^(FCPlace *fcPlace) {
                                                   if (block) {
                                                       block(fcPlace);
                                                   }
                                               }];
}

@end
