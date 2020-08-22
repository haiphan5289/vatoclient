//
//  FCMapInfoWindow.h
//  FaceCar
//
//  Created by facecar on 12/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FCMarkerStyle) {
    FCMarkerStyleDefault = 0,
    FCMarkerStyleCustom = 10,
    FCMarkerStyleStartInBook = 20,
    FCMarkerStyleEndInBook = 21,
    FCMarkerStyleStartInTrip = 30,
    FCMarkerStyleEndInTrip = 31,
    FCMarkerStyleStartOnlyIcon = 40,
};

@class FCPlace;
@interface FCMapMarker : UIView


@property (weak, nonatomic) IBOutlet UIView *durationView;

@property (weak, nonatomic) IBOutlet UIView *styleStartIntripView;
@property (weak, nonatomic) IBOutlet UIView *styleEndIntripView;
@property (weak, nonatomic) IBOutlet UIView *styleStartInbookView;
@property (weak, nonatomic) IBOutlet UIView *styleEndInbookView;
@property (weak, nonatomic) IBOutlet UIView *styleCustomView;
@property (weak, nonatomic) IBOutlet UIView *styleDefaultView;
@property (weak, nonatomic) IBOutlet UIView *styleStartOnlyIconView;


// style intrip
@property (weak, nonatomic) IBOutlet UILabel *lblStartIntrip;
@property (weak, nonatomic) IBOutlet UILabel *lblEndIntrip;

// style inbook
@property (weak, nonatomic) IBOutlet UILabel *lblEndInbook;
@property (weak, nonatomic) IBOutlet UILabel *lblStartInbook;

// style cusom
@property (weak, nonatomic) IBOutlet UILabel *lblCustom;
@property (weak, nonatomic) IBOutlet UIImageView *iconMarkerCustom;
@property (weak, nonatomic) IBOutlet UIImageView *iconMarkerDefaule;


@property (strong, nonatomic) FCPlace* data;

- (void) setMarkerStyle: (FCMarkerStyle) style;

@end
