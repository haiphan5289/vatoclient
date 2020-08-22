//
//  APIHelper.h
//  FC
//
//  Created by facecar on 7/25/17.
//  Copyright © 2017 Vu Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FCResponse.h"

#define METHOD_POST @"POST"
#define METHOD_GET @"GET"

@interface APIHelper : NSObject

+ (APIHelper*) shareInstance;

- (void) cancelCurrentRequest;

- (void) get: (NSString*) url
      params: (id) params
    complete: (void (^)(FCResponse* response, NSError *error)) block;

- (void) post: (NSString*) url
         body:(id) params
     complete: (void (^)(FCResponse* response, NSError *error)) block;

- (void) call: (NSString*) url
       method: (NSString*) method
       params: (id) params
        token: (NSString*) token
headerTokenKey: (NSString*) key
      handler: (void (^)(NSError* error, id response)) block;

- (void) apiSearchDriverOnline: (NSString*) url
                         param: (id) parmas
                         token: (NSString*) token
                       handler: (void (^)(FCResponse *response)) block;

@end
