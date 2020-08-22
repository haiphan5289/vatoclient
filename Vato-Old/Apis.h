//
//  Apis.h
//  FaceCar
//
//  Created by facecar on 6/3/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#ifndef Apis_h
#define Apis_h

#import "APIHelper.h"
#import "APICall.h"


// HOST
#define HOST_MAP_API @"https://maps.googleapis.com"

#if DEV
    #define HOSTV2 @"https://apiv2-dev.vato.vn/"
    #define HOSTV3 @"https://api-dev.vato.vn/api"
#else
    #define HOSTV2 @"https://apiv2.vivu.io"
    #define HOSTV3 @"https://api.vato.vn/api"
#endif

// APIs
#define API_GET_REFERAL_CODE   [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/promotion/getreferralcode"]
#define API_VERIFY_REFERAL_CODE  [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/promotion/applycode"]
#define API_GET_GIFTS  [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/cus/events"]
#define API_GET_GIFT_DETAIL  [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/cus/event"]
#define API_VERIFY_OFFICE_ACCOUNT  [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/sale/events"]
#define API_REGISTER_LEVEL_2 [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/user/verify/level-2"]
#define API_TRANSFER_MONEY_TO_ZALOPAY [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/zalo/cashout"]
#define API_UPDATE_PAYMENT_CHANNEL [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/user/update-cashout-chanel"]
#define API_GET_BPLUS_ORDER [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/bankplus/depositorder"]
#define API_GET_ZALO_ORDER [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/zalo/depositorder"]
#define API_CHANGE_PHONE_NUMBER [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/user/change-username"]
#define API_SYNC_DATA [NSString stringWithFormat: @"%@%@", HOSTV2 , @"/user/sync"]

// API v3
#define API_CHECK_ACCOUNT [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/check_account"]
#define API_CHECK_PHONE [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/check_phone"]
#define API_CREATE_ACCOUNT [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/create_account"]
#define API_UPDATE_ACCOUNT [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/update_account"]
#define API_SEARCH_DRIVER  [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/search"]
#define API_SEARCH_DRIVER_FOR_BOOKING  [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/search_driver"]
#define API_GET_BALANCE  [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/balance/get"]
#define API_GET_USER_INFO [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/check_info"]
#define API_TRANSFER_MONEY_TO_VATO [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/transfer_cash"]
#define API_GET_INVOICE  [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/transactions"]
#define API_GET_LIST_NOTIFY [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/notification/list_for_user"]
#define API_GET_TRIP_DAY [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/trip/list_client"]
#define API_CHECK_TRANF_CASH [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/check_transfer_cash"]
#define API_CREATE_PIN [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/set_pin"]
#define API_CHANGE_PIN [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/change_pin"]
#define API_RESET_PIN [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/reset_pin"]
#define API_ADD_FAV [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/add_to_favorite"]
#define API_REMOVE_FAV [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/remove_from_favorite"]
#define API_ADD_TO_BLACK_LIST [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/add_driver_to_blacklist"]
#define API_REMOVE_FROM_BLACK_LIST [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/remove_driver_from_blacklist"]
#define API_GET_TRANS_DETAIL [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/get_transaction"]
#define API_ADD_RATING [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/add_rating"]
#define API_LOGOUT [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/authenticate/logout"]
#define API_GET_TOPUP_CONFIG [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/user/get_user_topup_info"]
#define API_GET_GET_TRIP_DETAIL [NSString stringWithFormat: @"%@%@", HOSTV3 , @"/trip/trip_detail"]

// API maps
#define GOOGLE_API_DIRECTION [NSString stringWithFormat: @"%@%@", HOST_MAP_API ,@"/maps/api/directions/json"]
#define GOOGLE_API_PLACE [NSString stringWithFormat: @"%@%@", HOST_MAP_API ,@"/maps/api/place/autocomplete/json"]
#define GOOGLE_API_FIND_PLACE [NSString stringWithFormat: @"%@%@", HOST_MAP_API ,@"/maps/api/place/textsearch/json"]
#define GOOGLE_API_PLACE_DETAIL [NSString stringWithFormat: @"%@%@", HOST_MAP_API ,@"/maps/api/place/details/json"]

#endif /* Apis_h */
