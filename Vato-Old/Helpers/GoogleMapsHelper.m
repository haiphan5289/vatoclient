//
//  GoogleMapsHelper.m
//  FaceCar
//
//  Created by Vu Dang on 5/31/16.
//  Copyright © 2016 Vu Dang. All rights reserved.
//

#import "GoogleMapsHelper.h"
#import "FirebaseHelper.h"
#import "AppDelegate.h"
#import "APIHelper.h"
#import "FCGGPlace.h"


NSString * const locationUpdatedNotification = @"locationUpdated";


@interface GoogleMapsHelper() <CLLocationManagerDelegate, GMSMapViewDelegate>
@end

@implementation GoogleMapsHelper {
    NSInteger _indexKey;
}


static GoogleMapsHelper* instance = nil;
+ (GoogleMapsHelper*) shareInstance {
    if (instance == nil) {
        instance = [[GoogleMapsHelper alloc] init];
    }
    return instance;
}

- (id) init {
    self = [super init];
    if (self) {
        [GMSServices provideAPIKey:GOOGLE_MAPS_KEY];
        [GMSPlacesClient provideAPIKey:GOOGLE_MAPS_KEY];        
        _currentLocation = nil;
        [VatoLocationManager shared].locationChanged = ^(CLLocation * _Nullable new, NSError * _Nullable e) {
            self.locationError = e;
            self.currentLocation = new;
        };
    }
    
    return self;
}

- (void)startUpdateLocation
{
    [[VatoLocationManager shared] startUpdatingLocation];
}

- (void)stopUpdateLocation
{
    [[VatoLocationManager shared] stopUpdatingLocation];
}

- (void)setCurrentLocation:(CLLocation * _Nullable)currentLocation {
    if (currentLocation) {
        NSLog(@"Set abc: %lf %lf",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude );
        [[NSNotificationCenter defaultCenter] postNotificationName:locationUpdatedNotification
                                                            object:currentLocation];
    }
    
    _currentLocation = currentLocation;
    
}

- (void)getAddressOfLocation:(CLLocationCoordinate2D)location withCompletionBlock:(GMSReverseGeocodeCallback)block
{
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:location completionHandler:block];
}

#pragma mark - Geocoding
+ (void) getFCPlaceByLocation: (CLLocation*) lo
                        block: (void (^)(FCPlace*)) block {
    // start location info
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:lo.coordinate completionHandler:^(GMSReverseGeocodeResponse * response, NSError * error) {
        
        GMSAddress* address = response.firstResult;
//        NSString* cityStr = address.administrativeArea;
//        if (cityStr.length == 0) {
//            for (GMSAddress* add in response.results) {
//                if (add.locality.length > 0) {
//                    cityStr = add.locality;
//                    break;
//                }
//            }
//        }
    
        // cache
        FCPlace* place = [[FCPlace alloc] init];
        [place setLocation:[[FCLocation alloc] initWithLat:lo.coordinate.latitude lon:lo.coordinate.longitude]];
        NSString* addr = [address.lines componentsJoinedByString:@", "];
        [place setAddress:addr];
        [place setName:address.thoroughfare];
        if (place.name.length == 0 && place.address.length > 0) {
            place.name = place.address;
        }
        if (place.address == 0 && place.name.length > 0) {
            place.address = place.name;
        }
        
        [[FirebaseHelper shareInstance] getZoneByLocation:lo.coordinate
                                                  handler:^(FCZone * zone) {
                                                        place.zoneId = zone.id;
                                                        block (place);
                                                  }];
       
    }];
}

+ (void) getFCPlaceByGGPlace: (GMSPlace*) p
                       block: (void (^)(FCPlace*)) block {
    
    [GoogleMapsHelper getFCPlaceByLocation:[[CLLocation alloc] initWithLatitude:p.coordinate.latitude longitude:p.coordinate.longitude] block:^(FCPlace * place) {
        place.name = p.name;
        place.address = p.formattedAddress;
        if (place.name.length == 0 && place.address.length > 0) {
            place.name = place.address;
        }
        if (place.address == 0 && place.name.length > 0) {
            place.address = place.name;
        }
        block(place);
    }];
}

+ (void)openMapWithStart:(CLLocationCoordinate2D) startCoordinate andEnd:(CLLocationCoordinate2D)endCoordinate {
    if (![self isCoordinateValid:startCoordinate] || ![self isCoordinateValid:endCoordinate])
    {
        return;
    }
    
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"comgooglemaps:"]])
    {
        NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
                                         startCoordinate.latitude,
                                         startCoordinate.longitude,
                                         endCoordinate.latitude,
                                         endCoordinate.longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
    }
    else
    {
        NSString* directionsURL = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f",
                                   startCoordinate.latitude,
                                   startCoordinate.longitude,
                                   endCoordinate.latitude,
                                   endCoordinate.longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: directionsURL]];
    }
}

+ (BOOL)isCoordinateValid:(CLLocationCoordinate2D)coordinate
{
    if (!CLLocationCoordinate2DIsValid(coordinate) || (coordinate.latitude == 0 && coordinate.longitude == 0))
    {
        return NO;
    }
    return YES;
}

#pragma mark - Polyline

- (NSString *)encodeStringWithCoordinates:(NSArray *)coordinates
{
    
    NSMutableString *encodedString = [NSMutableString string];
    int val = 0;
    int value = 0;
    CLLocationCoordinate2D prevCoordinate = CLLocationCoordinate2DMake(0, 0);
    
    for (CLLocation *coordinateValue in coordinates) {
        CLLocationCoordinate2D coordinate = [coordinateValue coordinate];
        
        // Encode latitude
        val = round((coordinate.latitude - prevCoordinate.latitude) * 1e5);
        val = (val < 0) ? ~(val<<1) : (val <<1);
        while (val >= 0x20) {
            int value = (0x20|(val & 31)) + 63;
            [encodedString appendFormat:@"%c", value];
            val >>= 5;
        }
        [encodedString appendFormat:@"%c", val + 63];
        
        // Encode longitude
        val = round((coordinate.longitude - prevCoordinate.longitude) * 1e5);
        val = (val < 0) ? ~(val<<1) : (val <<1);
        while (val >= 0x20) {
            value = (0x20|(val & 31)) + 63;
            [encodedString appendFormat:@"%c", value];
            val >>= 5;
        }
        [encodedString appendFormat:@"%c", val + 63];
        
        prevCoordinate = coordinate;
    }
    
    return encodedString;
}

- (NSMutableArray*) decodePolyline: (NSString*) encodeStr {
    GMSPath *path =[GMSPath pathFromEncodedPath:encodeStr];
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for (int i = 0; i < path.count; i ++) {
        CLLocationCoordinate2D cor = [path coordinateAtIndex:i];
        CLLocation* lo = [[CLLocation alloc] initWithLatitude:cor.latitude longitude:cor.longitude];
        [list addObject:lo];
    }
    
    return list;
}

#pragma mark - API Direction

- (void) getDirection:(CLLocationCoordinate2D) start
                andAt:(CLLocationCoordinate2D) end
            completed:(void (^)(FCRouter*)) completed {
    
    [[FirebaseHelper shareInstance] getGoogleMapKeys:^(NSString * key) {
        NSDictionary *parameters = @{@"key": key,
                                     @"mode": @"driving",
                                     @"origin": [NSString stringWithFormat:@"%f, %f", start.latitude, start.longitude],
                                     @"destination": [NSString stringWithFormat:@"%f, %f", end.latitude, end.longitude]};
        
        DLog(@"Params: %@", parameters);
        [[APIHelper shareInstance] call:GOOGLE_API_DIRECTION
                                 method:METHOD_GET
                                 params:parameters
                                  token:nil
                         headerTokenKey:nil
                                handler:^(NSError *error, id responseObject) {
                                   @try {
                                       if (error) {
                                           [[FirebaseHelper shareInstance] resetMapKeys];
                                       }
                                       else if ([responseObject isKindOfClass:[NSDictionary class]] && [responseObject valueForKey:@"error_message"] == nil) {
                                           FCRouter* router = [[FCRouter alloc] init:responseObject];
                                           if (router.polylineEncode.length > 0) {
                                               completed(router);
                                           }
                                       }
                                       else {
                                           [[FirebaseHelper shareInstance] resetMapKeys];
                                       }
                                   }
                                   @catch (NSException* e) {
                                       [[FirebaseHelper shareInstance] resetMapKeys];
                                   }
                               }];
    }];
}

#pragma mark - API Places

- (void) apiSearchPlace: (NSString*) textsearch
                 inMaps: (GMSMapView*) _mapview
                handler: (void (^)(NSMutableArray*)) block {
    [[FirebaseHelper shareInstance] getGoogleMapKeys:^(NSString * key) {
        @try {
            NSString *input = [textsearch stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            NSString* host = GOOGLE_API_PLACE;
            NSString* url = [NSString stringWithFormat:@"%@?strictbounds&components=country:vn&language=vi&input=%@&key=%@&location=%f,%f&radius=%d", host, input, key, _mapview.camera.target.latitude, _mapview.camera.target.longitude, 500000]; // 500 km
            
            
            [[APIHelper shareInstance] call:url
                                     method:METHOD_GET
                                     params:nil
                                      token:nil
                             headerTokenKey:nil
                                   handler:^(NSError *error, id response) {
                                       if (error) {
                                           [[FirebaseHelper shareInstance] resetMapKeys];
                                       }
                                       else if ([response isKindOfClass:[NSDictionary class]]) {
                                           @try {
                                               NSString* status = [response objectForKey:@"status"];
                                               if ([status isEqualToString:@"OK"]) {
                                                   NSArray* data = [response objectForKey:@"predictions"];
                                                   NSMutableArray* list = [[NSMutableArray alloc] init];
                                                   for (NSDictionary* dict in data) {
                                                       NSError* err;
                                                       FCGGPlace* place = [[FCGGPlace alloc] initWithDictionary:dict
                                                                                                          error:&err];
                                                       if (place && place.name.length > 0) {
                                                           [list addObject:place];
                                                       }
                                                   }
                                                   
                                                   if (block) {
                                                       block(list);
                                                   }
                                               }
                                               else {
                                                   [[FirebaseHelper shareInstance] resetMapKeys];
                                               }
                                           }
                                           @catch (NSException* e) {
                                               DLog(@"Error: %@", e);
                                               [[FirebaseHelper shareInstance] resetMapKeys];
                                           }
                                       }
                                       else {
                                           [[FirebaseHelper shareInstance] resetMapKeys];
                                       }
                                   }];
        }
        @catch(NSException* e) {
            DLog(@"error: %@", e);
        }
    }];
}

#pragma mark - API Place Detail

- (void) apiGetPlaceDetail: (NSString*) placeid
                  callback: (void (^)(FCPlace * fcPlace)) block {
    [[FirebaseHelper shareInstance] getGoogleMapKeys:^(NSString * key) {
        @try {
            NSDictionary *parameters = @{@"key": key,
                                         @"placeid": placeid};
            
            [[APIHelper shareInstance] call:GOOGLE_API_PLACE_DETAIL
                                     method:METHOD_GET
                                     params:parameters
                                      token:nil
                             headerTokenKey:nil
                                   handler:^(NSError *error, id response) {
                                       if (error) {
                                           [[FirebaseHelper shareInstance] resetMapKeys];
                                       }
                                       else if ([response isKindOfClass:[NSDictionary class]]) {
                                           @try {
                                               NSDictionary* reslut = [response objectForKey:@"result"];
                                               FCPlace* place = [[FCPlace alloc] init];
                                               
                                               // get address
                                               if ([reslut objectForKey:@"formatted_address"]) {
                                                   NSString* address = [reslut objectForKey:@"formatted_address"];
                                                   place.address = address;
                                                   place.name = address;
                                               }
                                               
                                               // location
                                               id loDict = [[reslut objectForKey:@"geometry"] objectForKey:@"location"];
                                               if ([loDict isKindOfClass:[NSDictionary class]]) {
                                                   FCLocation* location = [[FCLocation alloc] init];
                                                   location.lat = [[loDict objectForKey:@"lat"] doubleValue];
                                                   location.lon = [[loDict objectForKey:@"lng"] doubleValue];
                                                   place.location = location;
                                                   
                                                   CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.lat, location.lon);
                                                   [[FirebaseHelper shareInstance] getZoneByLocation:coordinate
                                                                                             handler:^(FCZone * zone) {
                                                                                                 place.zoneId = zone.id;
                                                                                                 block (place);
                                                                                             }];
                                               }
                                               else {
                                                   place.zoneId = ZONE_VN;
                                                   block (place);
                                               }
                                           }
                                           @catch (NSException* e) {
                                               [[FirebaseHelper shareInstance] resetMapKeys];
                                           }
                                       }
                                       else {
                                           [[FirebaseHelper shareInstance] resetMapKeys];
                                       }
                                   }];
        }
        @catch(NSException* e) {
            DLog(@"error: %@", e);
        }
    }];
}


@end
