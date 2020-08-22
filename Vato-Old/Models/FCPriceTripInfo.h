//
//  FCPriceTripInfo.h
//  FaceCar
//
//  Created by facecar on 4/2/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
@import GoogleMaps;

@interface FCPriceTripInfo : FCModel

@property(strong, nonatomic) FCPlace* placeStart;
@property(strong, nonatomic) FCPlace* placeEnd;
@property(assign, nonatomic) NSInteger distanceValue;
@property(assign, nonatomic) NSInteger durationValue;

@end
