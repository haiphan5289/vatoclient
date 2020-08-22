//
//  GoogleMapsHelper.h
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@import GoogleMaps;
@import GooglePlaces;


extern NSString *_Nonnull const locationUpdatedNotification;


@interface GoogleMapsHelper : NSObject

@property (strong, nonatomic, readonly) CLLocation * _Nullable currentLocation;
@property (strong, nonatomic) NSError* _Nullable locationError;

+ (GoogleMapsHelper*_Nonnull) shareInstance;

+ (BOOL) isCoordinateValid:(CLLocationCoordinate2D)coordinate;

- (void) startUpdateLocation;
- (void) stopUpdateLocation;
- (void) getAddressOfLocation:(CLLocationCoordinate2D)location
          withCompletionBlock:(GMSReverseGeocodeCallback _Nullable )block;

- (NSString *_Nullable)encodeStringWithCoordinates:(NSArray *_Nullable)coordinates;
- (NSMutableArray*_Nullable) decodePolyline: (NSString*_Nullable) encodeStr;

+ (void) getFCPlaceByLocation: (CLLocation*__nonnull) lo
                        block: (void (^__nullable)(FCPlace*__nullable)) block;

+ (void) getFCPlaceByGGPlace: (GMSPlace*__nonnull) p
                       block: (void (^__nullable)(FCPlace*__nullable)) block;

#pragma mark - APIs
- (void) getDirection:(CLLocationCoordinate2D) start
                andAt:(CLLocationCoordinate2D) end
            completed:(void (^_Nullable)(FCRouter*_Nullable)) completed;

- (void) apiSearchPlace: (NSString*_Nullable) textsearch
                 inMaps: (GMSMapView*_Nullable) _mapview
                handler: (void (^_Nullable)(NSMutableArray*_Nullable)) block;

- (void) apiGetPlaceDetail: (NSString*_Nullable) placeid
                  callback: (void (^_Nullable)(FCPlace *_Nullable fcPlace)) block;

@end
