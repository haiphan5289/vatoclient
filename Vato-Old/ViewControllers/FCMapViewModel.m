
//
//  FCMapViewModel.m
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCMapViewModel.h"
#import "FCOnlineStatus.h"
#import "GoogleMapsHelper.h"
#import "FCBookViewModel.h"

#define kMinZoom 7
#define kMaxZoom 25

@interface FCMapViewModel () <GMSMapViewDelegate>

@property (strong, nonatomic) NSMutableArray* listAllMarker;
@property (strong, nonatomic) NSMutableArray* listAllDriver;
@property (assign, nonatomic) NSInteger service; // current service selected

@property (strong, nonatomic) void (^startMarkerClicked)(void);
@property (strong, nonatomic) void (^endMarkerClicked)(void);
@end

@implementation FCMapViewModel {
    CLLocation* _originLocation;
    NSString* _currentRealPolyine;
}

- (id) init:(FCGGMapView*)map {
   
    self = [super init];
    if (self) {
        self.mapView = map;
        self.listAllMarker = [[NSMutableArray alloc] init];
        self.listAllDriver = [[NSMutableArray alloc] init];
        
        [self.mapView setMinZoom:kMinZoom
                         maxZoom:kMaxZoom];
        
        [RACObserve(self, markerEnd) subscribeNext:^(GMSMarker* x) {
            [self checkDrawPolyline];
        }];
        
        // infowindow clicked
        __weak typeof(self) weakSelf = self;
        [self.mapView setInfoWindowCallback:^(GMSMarker *marker) {
            if (marker == self.markerMainDriver) {
                if (weakSelf.startMarkerClicked)
                    weakSelf.startMarkerClicked ();
            }
            else if (marker == self.markerEnd) {
                if (weakSelf.endMarkerClicked)
                    weakSelf.endMarkerClicked ();
            }
        }];
        
        // camera changed callback
        [self.mapView setCameraChangedCallback:^(GMSCameraPosition * position) {
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // Add code here to do background processing
                // scale marker
                float zoom = [weakSelf.mapView zoom];
                float scale = zoom / kMaxZoom;
//                DLog(@"Map Zoom: %f", zoom)
                
                FCMCarType* cartype = weakSelf.homeViewModel.bookViewModel.serviceSelected;
                NSString* str = [NSString stringWithFormat:@"m-car-%lu-15", (long)cartype.id];
                UIImage* originImg = [UIImage imageNamed:str];
                CGSize originSize = originImg.size;
                UIImage* img = [[UIImage imageNamed:str] scaledToSize:CGSizeMake(originSize.width*scale*0.75, originSize.height*scale*0.75)];
                
                
                dispatch_async( dispatch_get_main_queue(), ^{
                    for (GMSMarker* m in weakSelf.listAllMarker) {
                        m.icon = img;
                    }
                });
            });
        }];
    }
    
    return self;
}

- (void) clearMaps {
    for (GMSMarker* marker in self.listAllMarker) {
        marker.map = nil;
    }
    [self.listAllMarker removeAllObjects];
    [self.listAllMarker removeAllObjects];
}

- (void) setHomeViewModel:(FCHomeViewModel *)homeViewModel {
    _homeViewModel = homeViewModel;
    
    // add driver to map
    [RACObserve(homeViewModel, listDriverOnline) subscribeNext:^(NSMutableArray* list) {
        self.service = homeViewModel.bookViewModel.serviceSelected.id;
        
        [self clearMaps];
        
        if (list.count > 0) {
            self.listAllDriver = list;
            
            for (FCDriverSearch* driver in list) {
                [self addDriverMarker:driver];
            }
            
            // listener driver change realtime
            [self addDriverChangedListener: list];
        }
    }];
    
    // get start info
    [RACObserve(homeViewModel.bookViewModel, start) subscribeNext:^(FCPlace* x) {
        if (x) {
            _originLocation = [[CLLocation alloc] initWithLatitude:x.location.lat
                                                         longitude:x.location.lon];
        }
    }];
}

#pragma mark - Start, end marker

- (void) addMarker: (CLLocationCoordinate2D) position
              icon: (UIImage*) icon {
    GMSMarker* marker = [[GMSMarker alloc] init];
    marker.icon = icon;
    marker.position = position;
    [self.mapView addMarker: marker];
    self.markerStart = marker;
}

- (GMSMarker*) addStartMarker: (FCPlace*) place {
    if (self.markerMainDriver) {
        self.markerMainDriver.map = nil;
        self.markerMainDriver = nil;
    }
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(place.location.lat, place.location.lon);
    
    FCMapMarker* iconView = [self createMarkerView];
    iconView.data = place;
    
    GMSMarker* marker = [[GMSMarker alloc] init];
    marker.iconView = iconView;
    marker.position = location;
    [self.mapView updateStartMarker:marker];
    self.markerMainDriver = marker;
    
    return marker;
}

- (GMSMarker*) addEndMarker: (FCPlace*) endPlace {
    if (self.markerEnd) {
        self.markerEnd.map = nil;
        self.markerEnd = nil;
    }
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(endPlace.location.lat, endPlace.location.lon);
    
    FCMapMarker* iconView = [self createMarkerView];
    iconView.data = endPlace;
    
    GMSMarker* markerEnd = [[GMSMarker alloc] init];
    markerEnd.iconView = iconView;
    markerEnd.position = location;
    [self.mapView updateEndMarker:markerEnd];
    self.markerEnd = markerEnd;
    
    return markerEnd;
}

- (void) setStartMarkerClickedCallback: (void (^)(void)) clickBlock {
    _startMarkerClicked = clickBlock;
}

- (void) setEndMarkerClickedCallback: (void (^)(void)) clickBlock {
    _endMarkerClicked = clickBlock;
}

- (FCMapMarker*) createMarkerView {
    FCMapMarker* view = [[FCMapMarker alloc] init];
    return view;
}

#pragma mark - Marker Amimation

- (void) startMarkerUpdate: (CLLocation*) location
                 forMarker: (GMSMarker*) marker {
    if (marker) {
        CLLocationCoordinate2D cor = location.coordinate;
        
        CLLocation* des = [[CLLocation alloc] initWithLatitude:cor.latitude longitude:cor.longitude];
        CLLocation* from = [[CLLocation alloc] initWithLatitude:marker.position.latitude longitude:marker.position.longitude];
        double bearing = [from bearingToLocation:des];
        
        [self animationMarker:marker
                     position:location.coordinate
                        angle:bearing];
        
        self.markerMainDriver = marker;
    }
}

- (void) animationMarker: (GMSMarker*) marker
                position: (CLLocationCoordinate2D) newCoordinate
                   angle: (double) calBearing {
    double newAngle = calBearing;
    if (calBearing < 0) {
        newAngle = 360.0f + calBearing;
    }
    
    double detalAngle = fabs(newAngle - marker.rotation);
    double duration = 5.0;
    if (calBearing != 0 && detalAngle > 70) {
        duration = 1.0;
    }

    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:duration] forKey:kCATransactionAnimationDuration];
    [CATransaction setCompletionBlock:^{
        
    }];
    [self.mapView addMarker:marker];
    if (duration != 1.0) {
        marker.position = newCoordinate;
    }
    
    if (calBearing != 0) {
        marker.rotation = calBearing;
    }
    [CATransaction commit];
}


#pragma mark - Driver Marker
- (void) addDriverChangedListener: (NSMutableArray*) forDrivers {
    [[FirebaseHelper shareInstance] registerDriverRealtime:forDrivers
                                                   handler:^(FIRDataSnapshot * snapshot, BOOL isOnline) {
                                                       [self updateMarkerOnMaps:snapshot
                                                                      isRemoved:!isOnline];
                                                   }];
}

- (void) removeDriverChangedListener {
    [[FirebaseHelper shareInstance] removeDriverChangedListener];
    [[FirebaseHelper shareInstance] removeDriverDeadListener];
}

- (void) addDriverMarker : (FCDriverSearch*) driver {
    
    GMSMarker* marker = [self getDriverMarker:driver.firebaseId];
    
    if (marker == nil) {
        marker = [[GMSMarker alloc] init];
        
        float zoom = [self.mapView zoom];
        float scale = zoom / kMaxZoom;
        
        NSString* str = [NSString stringWithFormat:@"m-car-%lu-15", self.service];
        UIImage* originImg = [UIImage imageNamed:str];
        CGSize originSize = originImg.size;
        UIImage* img = [[UIImage imageNamed:str] scaledToSize:CGSizeMake(originSize.width*scale*0.75, originSize.height*scale*0.75)];
        marker.icon = img;
        
        marker.userData = driver;
        marker.flat = true;
        marker.groundAnchor = CGPointMake(0.5f, 0.5f);
        [self.mapView addMarker:marker];
        
        
        [self.listAllMarker addObject:marker];
    }
    marker.rotation = arc4random() % 360;
    marker.position = CLLocationCoordinate2DMake(driver.location.lat, driver.location.lon);
}

- (GMSMarker*) getDriverMarker: (NSString*) driverId {
    if (self.listAllMarker) {
        for (GMSMarker* m in self.listAllMarker) {
            if ([[(FCDriverSearch*)m.userData firebaseId] isEqualToString:driverId]) {
                return m;
            }
        }
    }
    
    return nil;
}

- (void) updateMarkerOnMaps: (FIRDataSnapshot*) snapshot
                  isRemoved: (BOOL) isremove {
    
    NSString* driverId = snapshot.key;
    FCOnlineStatus* driver = [[FCOnlineStatus alloc] initWithDictionary:snapshot.value
                                                            error:nil];
    if (!driver) {
        return;
    }
    
    if (isremove) {
        GMSMarker* driverMarker = [self getDriverMarker:driverId];
        if (driverMarker)
            driverMarker.map = nil;
        
        return;
    }
    
    if (self.listAllDriver) {
        for (FCDriverSearch* d in self.listAllDriver) {
            if ([d.firebaseId isEqualToString:driverId]) {
                GMSMarker* driverMarker = [self getDriverMarker:d.firebaseId];
                if (driver.status == DRIVER_READY) {
                    FCLocation* oldLo = d.location;
                    d.location = driver.location;
                    
                    // custom animation
                    CLLocation* des = [[CLLocation alloc] initWithLatitude:d.location.lat longitude:d.location.lon];
                    CLLocation* from = [[CLLocation alloc] initWithLatitude:oldLo.lat longitude:oldLo.lon];
                    
                    double bearing = [from bearingToLocation:des];
                    [self animationMarker:driverMarker
                                 position:CLLocationCoordinate2DMake(d.location.lat, d.location.lon)
                                    angle:bearing];
                }
                else {
                    driverMarker.map = nil;
                }
                
                return;
            }
        }
    }
}

#pragma mark - Real polyline
- (void) updateRealPolyline: (id) locations
                    forTrip: (FCBookInfo *)book {
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _currentRealPolyine = [self getRealPolyline:book.tripId];
        
        // polyline
        NSMutableArray* listLocation = [[GoogleMapsHelper shareInstance] decodePolyline:_currentRealPolyine];
        if (!listLocation) {
            listLocation = [[NSMutableArray alloc] init];
        }
        if ([locations isKindOfClass:[CLLocation class]]) {
            [listLocation addObject:locations];
        }
        else if ([locations isKindOfClass:[NSMutableArray class]]) {
            [listLocation addObjectsFromArray:locations];
        }
        
        _currentRealPolyine = [[GoogleMapsHelper shareInstance] encodeStringWithCoordinates:listLocation];
        [self saveRealPolyline:_currentRealPolyine
                        forKey:book.tripId];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self drawPath:_currentRealPolyine];
        });
    });
}

- (void) saveRealPolyline: (NSString*) polyline
                   forKey: (NSString*) key
{
    [[NSUserDefaults standardUserDefaults] setObject: polyline
                                              forKey: key];
}

- (NSString*) getRealPolyline: (NSString*) key {
    if (_currentRealPolyine.length > 0) {
        return _currentRealPolyine;
    }
    
    _currentRealPolyine = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return _currentRealPolyine;
}

#pragma mark - Polyline

- (void) checkDrawPolyline {
    if (self.markerMainDriver && self.markerEnd) {
        if (![self.mapView polyline]) {
            [self drawPolyline:[[CLLocation alloc] initWithLatitude:_markerMainDriver.position.latitude
                                                          longitude:_markerMainDriver.position.longitude]
                           end:[[CLLocation alloc] initWithLatitude:_markerEnd.position.latitude longitude:_markerEnd.position.longitude]];
        }
    }
    else {
        [self removePolyline];
    }
}

- (void) drawPolyline: (CLLocation*) start
                  end: (CLLocation*) end {
    
    CLLocationCoordinate2D startPos = start.coordinate;
    if (self.markerStart) {
        startPos = self.markerStart.position;
    }
    
    NSString *polyline = [self.bookingService getPolyline];
    if (polyline.length > 0) {
        [self drawPath:polyline];
        return;
    }
    
    [[GoogleMapsHelper shareInstance] getDirection:startPos
                                             andAt:end.coordinate
                                         completed:^(FCRouter * router) {
                                             [self drawPath:router.polylineEncode];
                                             self.router = router;
                                         }];
}

- (void) removePolyline {
    self.router = nil;
    [self.mapView removePolyline];
}

- (void) drawPath: (NSString*) decode {
//    [self removePolyline];
    
    GMSPath* path = [GMSPath pathFromEncodedPath:decode];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.strokeColor = [UIColor orangeColor];
    polyline.strokeWidth = 2.5f;
    
    [self.mapView updatePolyline:polyline];

    // zoom bound camera
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
    [self zommMapToBound:bounds];
}

- (void) zommMapToBound: (GMSCoordinateBounds*) bounds {
    [self.mapView updatePolylineBounds:bounds];
    
//    NSInteger w = [UIScreen mainScreen].bounds.size.width;
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
}
@end
