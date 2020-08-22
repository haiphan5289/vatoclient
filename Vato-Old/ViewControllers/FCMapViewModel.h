//
//  FCMapViewModel.h
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCHomeViewModel.h"
#import "FCMapMarker.h"
#import "FCBookingService.h"

@interface FCMapViewModel : NSObject

@property (strong, nonatomic) FCRouter* router;
@property (weak, nonatomic) FCHomeViewModel* homeViewModel;
@property (weak, nonatomic) FCGGMapView* mapView;
@property (strong, nonatomic) GMSMarker* markerStart;
@property (strong, nonatomic) GMSMarker* markerMainDriver;
@property (strong, nonatomic) GMSMarker* markerEnd;
@property (weak, nonatomic) FCBookingService* bookingService;

- (id) init: (FCGGMapView*) map;

- (void) addDriverChangedListener: (NSMutableArray*) forDrivers;
- (void) removeDriverChangedListener;

- (GMSMarker*) addStartMarker: (FCPlace*) place;
- (GMSMarker*) addEndMarker: (FCPlace*) place;
- (void) addMarker: (CLLocationCoordinate2D) position
              icon: (UIImage*) icon;

- (void) setStartMarkerClickedCallback: (void (^)(void)) clickBlock;
- (void) setEndMarkerClickedCallback: (void (^)(void)) clickBlock;

- (void) startMarkerUpdate: (CLLocation*) location
                    forMarker: (GMSMarker*) marker;

- (void) checkDrawPolyline;
- (void) updateRealPolyline: (id) locations
                    forTrip: (FCBookInfo*) book;
- (void) drawPath: (NSString*) decode;
- (void) zommMapToBound: (GMSCoordinateBounds*) bounds;

@end
