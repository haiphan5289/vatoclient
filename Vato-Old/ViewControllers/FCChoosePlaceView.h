//
//  FCChoosePlaceView.h
//  FaceCar
//
//  Created by facecar on 12/7/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCHomeViewModel.h"

typedef NS_ENUM(NSUInteger, FCPlaceSearchType) {
    FCPlaceSearchTypeFull = 0, // default  verify both start and end place (default load end first)
    FCPlaceSearchTypeFullWithStartFirst = 10, // verify start both and end place (load start first)
    FCPlaceSearchTypeStart = 1, // only start place
    FCPlaceSearchTypeEnd = 2, // only end place
    FCPlaceSearchTypeEdit = 20, // only end place

    FCPlaceSearchTypeEditStart = (FCPlaceSearchTypeEdit | FCPlaceSearchTypeStart), // only end place
    FCPlaceSearchTypeEditEnd = (FCPlaceSearchTypeEdit | FCPlaceSearchTypeEnd) // only end place
};

@interface FCChoosePlaceView : FCView
@property (weak, nonatomic) FCHomeViewModel* homeViewModel;
@property (assign, nonatomic) BOOL isDone;
@property (assign, nonatomic) FCPlaceSearchType searchType; // full || start || end verify
@property (strong, nonatomic) FCPlace* tempPlaceStart;
@property (strong, nonatomic) FCPlace* tempPlaceEnd;
@property (strong, nonatomic) FCPlace* tempPlace;


@end
