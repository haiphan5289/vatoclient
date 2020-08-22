//
//  FCGGMapView.h
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kBtnLocationSize 40
#define kBtnLocationOffsetRight 20
#define kBtnLocationOffsetBotttom 40

@interface FCGGMapView : UIView <GMSMapViewDelegate, UIGestureRecognizerDelegate>

@property (assign, nonatomic) CGPoint btnLocationPosition;
@property (nonatomic, readonly) BOOL isManualMoved;
@property (assign, nonatomic) BOOL myLocationEnabled;
@property (readonly, nonatomic) GMSProjection *projection;

//@property (readonly, nonatomic) GMSMapView *mapView;

- (void) reset;
- (void) setMinZoom:(float)minZoom maxZoom:(float)maxZoom;
- (void) animateWithCameraUpdate:(GMSCameraUpdate *)update;
- (void) setPadding: (UIEdgeInsets)padding;
- (void) moveCameraToCurrentLocation;
- (void) animationCameraTo: (CLLocation*) location;
- (void) animationCameraTo: (CLLocation*) location zoom: (CGFloat) zoom;
- (void) moveCameraTo: (CLLocation*) location;
- (void) moveCameraTo: (CLLocation*) location
                 zoom: (CGFloat) zoomlvl;

- (void) addLocationButton: (FCButton*) button;
- (void) clearPolyline;

- (void)setGeocodingCallback:(void (^)(FCPlace*))callback;
- (void)setInfoWindowCallback:(void (^)(GMSMarker*))callback;
- (void)setCameraChangedCallback:(void (^)(GMSCameraPosition*))callback;
- (void) updatePolyline: (GMSPolyline* ) polyline;
- (float)zoom;
- (void) removePolyline;
- (void) updateStartMarker:(GMSMarker* ) marker;
- (void) updateEndMarker:(GMSMarker* ) marker;
- (void) addMarker:(GMSMarker* ) marker;
- (GMSPolyline *) polyline;
- (GMSCoordinateBounds *) polylineBounds;
- (void) updatePolylineBounds:(GMSCoordinateBounds *) polylineBounds;
@end
