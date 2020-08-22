//
//  FCGGMapView.m
//  FaceCar
//
//  Created by facecar on 12/5/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import "FCGGMapView.h"
#import "GoogleMapsHelper.h"
#import "FCMapMarker.h"
#import <GoogleMaps/GoogleMaps.h>
#define CLCOORDINATES_EQUAL( coord1, coord2 ) (coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude)

@interface FCGGMapView () <CAAnimationDelegate>
@property(strong, nonatomic) CAShapeLayer* polylineAnimLayer;
@property (strong, nonatomic) GMSMapView *mapView;
@property(nonatomic) BOOL isReset;

@property (strong, nonatomic) GMSMarker* startMarker;
@property (strong, nonatomic) GMSMarker* endMarker;
@property (strong, nonatomic) GMSPolyline* polyline;
@property (strong, nonatomic) GMSCoordinateBounds* polylineBounds;
@property (readonly, nonatomic) GMSCameraPosition *camera;

@end


@implementation FCGGMapView {
    void (^_geocodingCallback)(FCPlace* place);
    void (^_infoWindowCallback)(GMSMarker* marker);
    void (^_cameraChangedCallback)(GMSCameraPosition* pos);
    FCButton* _locationBtn;
    CGFloat _zoom;
    NSTimer* _timerAllowGeocoding;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    _zoom = MAP_ZOOM;
    [self initGoogleMap];
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (BOOL)myLocationEnabled {
    return _mapView.myLocationEnabled;
}

- (void)setMyLocationEnabled:(BOOL)myLocationEnabled {
    _mapView.myLocationEnabled = myLocationEnabled;
}

- (GMSProjection *)projection {
    return _mapView.projection;
}

- (GMSCameraPosition *)camera {
    return _mapView.camera;
}

- (void)animateWithCameraUpdate:(GMSCameraUpdate *)update {
    [_mapView animateWithCameraUpdate:update];
}

- (void) setPadding: (UIEdgeInsets)padding {
    _mapView.padding = padding;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.frame = self.bounds;
    });
}

- (void)setMinZoom:(float)minZoom maxZoom:(float)maxZoom {
    [self.mapView setMinZoom:minZoom maxZoom:maxZoom];
}

- (void) initGoogleMap {
    self.mapView = [[GMSMapView alloc] initWithFrame:self.bounds];
    [self addSubview:_mapView];
    
    NSURL *nightURL = [[NSBundle mainBundle] URLForResource:@"custom-map"
                                              withExtension:@"json"];
    GMSMapStyle* mapStyle = [GMSMapStyle styleWithContentsOfFileURL:nightURL error:NULL];
    self.mapView.mapStyle = mapStyle;
    self.mapView.settings.rotateGestures = NO;
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
}

- (void) setGeocodingCallback:(void (^)(FCPlace *))callback {
    _geocodingCallback = callback;
}

- (void)setInfoWindowCallback:(void (^)(GMSMarker*))callback {
    _infoWindowCallback = callback;
}

- (void) setCameraChangedCallback:(void (^)(GMSCameraPosition *))callback {
    _cameraChangedCallback = callback;
}

- (void) addLocationButton: (FCButton*) button {
    _locationBtn = button;
    [_locationBtn addTarget:self
                     action:@selector(locationClicked:)
   forControlEvents:UIControlEventTouchUpInside];
}

- (void) updateLogoGoogle: (CGFloat) y {
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(y, 0.0, y, 0.0);
    self.mapView.padding = mapInsets;
}

- (void)locationClicked:(id)sender {
    CLLocation* curr = [GoogleMapsHelper shareInstance].currentLocation;
    if (curr)
        [self animationCameraTo:curr];
    
}

- (void)reset {
    _isManualMoved = NO;
    self.isReset = YES;
}

- (void) moveCameraToCurrentLocation {
    CLLocation* curr = [GoogleMapsHelper shareInstance].currentLocation;
    if (curr)
        [self moveCameraTo:curr];
}

- (void) animationCameraTo: (CLLocation*) location {
    if (self.polyline) {
        [self animationCameraToBoundPolyline];
    }
    else {
        [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithTarget:location.coordinate
                                                                     zoom:_zoom]];
    }
}

- (void) animationCameraTo: (CLLocation*) location zoom: (CGFloat) zoom {
    if (self.polyline) {
        [self animationCameraToBoundPolyline];
    }
    else {
        [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithTarget:location.coordinate
                                                                     zoom:zoom]];
    }
}

- (void) moveCameraTo: (CLLocation*) location {
    if (self.polyline) {
        [self animationCameraToBoundPolyline];
    }
    else {
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                     zoom:_zoom];
    }
}

- (void) moveCameraTo: (CLLocation*) location
                 zoom: (CGFloat) zoomlvl {
    _zoom = zoomlvl;
    [self moveCameraTo:location];
}

- (void) animationCameraToBoundPolyline {
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:self.polyline.path];
    NSInteger w = [UIScreen mainScreen].bounds.size.width / 4;
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds
                                              withEdgeInsets:UIEdgeInsetsMake(w, w, w, w)]];
    
    _polylineBounds = bounds;
}

#pragma mark - Button Location
- (void) showButton {
    if (_locationBtn && _locationBtn.hidden) {
        _locationBtn.hidden = NO;
        _locationBtn.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
        [UIView animateWithDuration:0.2f
                         animations:^{
                             _locationBtn.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void) hideButton {
    if (_locationBtn) {
        _locationBtn.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [UIView animateWithDuration:0.2f
                         animations:^{
                             _locationBtn.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
                         }
                         completion:^(BOOL finished) {
                             _locationBtn.hidden = YES;
                         }];
    }
}

#pragma mark - Map Delegate

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if (_infoWindowCallback) {
        _infoWindowCallback(marker);
    }
    return YES;
}
- (UIView*) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    return nil;
}

- (void) mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    if (_timerAllowGeocoding) {
        [_timerAllowGeocoding invalidate];
    }

    if (!_isReset) {
        _isManualMoved = YES;
        if (_cameraChangedCallback) {
            _cameraChangedCallback(self.mapView.camera);
        }
    }
}

- (void) mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {

}

- (void) mapView:(GMSMapView*)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    if (_geocodingCallback && _isManualMoved) {
        _timerAllowGeocoding = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                target:self
                                                              selector:@selector(startGetGeocoding:)
                                                              userInfo:position
                                                               repeats:NO];
    }
    
    // show /hide button location
    if ([self mapTargetNearByMyLocation:position]) {
        [self hideButton];
    }
    else {
        [self showButton];
    }
    self.isReset = NO;
}

- (void) startGetGeocoding : (NSTimer*) timer {
    GMSCameraPosition* position = (GMSCameraPosition*)timer.userInfo;
    _geocodingCallback(nil); // for reset first
    [GoogleMapsHelper getFCPlaceByLocation:[[CLLocation alloc] initWithLatitude:position.target.latitude longitude:position.target.longitude] block:^(FCPlace * place) {
        if (_geocodingCallback)
            _geocodingCallback(place);
    }];
}

- (BOOL) mapTargetNearByMyLocation: (GMSCameraPosition*) position {
    
    if (self.polyline) {
        CLLocationCoordinate2D north = _polylineBounds.northEast;
        CLLocationCoordinate2D sourth = _polylineBounds.southWest;
        
        BOOL res = [self.mapView.projection containsCoordinate:north] &&
                   [self.mapView.projection containsCoordinate:sourth];
        
        return res;
    }
    
    CLLocation* pos = [[CLLocation alloc] initWithLatitude:position.target.latitude
                                                 longitude:position.target.longitude];
    CLLocation* curr = [GoogleMapsHelper shareInstance].currentLocation;
    CGFloat dis = [pos distanceFromLocation:curr];
    
    return dis > 0 && dis < 10.0f; // < 10m
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    if (_timerAllowGeocoding) {
        [_timerAllowGeocoding invalidate];
    }
}

- (void)dealloc {
    
}

#pragma mark - Polyline animation
- (void) startPolylineAnimation {
    if (self.polylineAnimLayer) {
        [self.polylineAnimLayer removeFromSuperlayer];
        self.polylineAnimLayer = nil;
    }

    self.polylineAnimLayer = [self layerFromGMSMutablePath:self.polyline.path];
    [self.layer addSublayer:self.polylineAnimLayer];
    [self animatePath:self.polylineAnimLayer];
}

- (CAShapeLayer*)layerFromGMSMutablePath:(GMSPath*) path {
    UIBezierPath *breizerPath = [UIBezierPath bezierPath];
    
    CLLocationCoordinate2D firstCoordinate = [path coordinateAtIndex:0];
    [breizerPath moveToPoint:[self.mapView.projection pointForCoordinate:firstCoordinate]];
    
    for(int i=1; i<path.count; i++){
        CLLocationCoordinate2D coordinate = [path coordinateAtIndex:i];
        [breizerPath addLineToPoint:[self.mapView.projection pointForCoordinate:coordinate]];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [[breizerPath bezierPathByReversingPath] CGPath];
    shapeLayer.strokeColor = [[UIColor orangeColor] CGColor];
    shapeLayer.lineWidth = 2.5;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.cornerRadius = 5;
    
    return shapeLayer;
}

- (void)animatePath:(CAShapeLayer *)layer {
    self.polyline.map = nil;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2.5f;
    pathAnimation.delegate = self;
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    [layer addAnimation:pathAnimation forKey:@"strokeEnd"];
}

- (void) clearPolyline {
    self.polyline.map = nil;
}

- (void)animationDidStart:(CAAnimation *)anim {
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self startPolylineAnimation];
}

- (void) updatePolyline: (GMSPolyline* ) polyline {
    polyline.map = self.mapView;
    self.polyline = polyline;
}


- (float)zoom {
    return self.mapView.camera.zoom;
}

- (void) removePolyline {
    self.polyline.map = nil;
    self.polyline = nil;
}

- (void) updateStartMarker:(GMSMarker* ) marker {
    marker.map = self.mapView;
    self.startMarker = marker;
}

- (void) updateEndMarker:(GMSMarker* ) marker {
    marker.map = self.mapView;
    self.endMarker = marker;
}

- (void) addMarker:(GMSMarker* ) marker {
    marker.map = self.mapView;
}

- (void) updatePolylineBounds:(GMSCoordinateBounds *) polylineBounds {
    self.polylineBounds = polylineBounds;
}
@end
