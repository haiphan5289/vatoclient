//
//  FCUCar.h
//  FC
//
//  Created by facecar on 6/4/18.
//  Copyright © 2018 Vu Dang. All rights reserved.
//

#import "FCModel.h"

@interface FCUCar : FCModel
@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger createdBy;
@property (nonatomic, assign) NSInteger updatedBy;
@property (nonatomic, assign) NSInteger createdAt;
@property (nonatomic, assign) NSInteger updatedAt;
@property (nonatomic, assign) NSInteger identifier;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger rank;
@property (nonatomic, assign) NSInteger ownerId;
@property (nonatomic, copy)   NSString *plate;
@property (nonatomic, copy)   NSString *color;
@property (nonatomic, copy)   NSString *brand;
@property (nonatomic, copy)   NSString *marketName;
@property (nonatomic, copy)   NSString *registrationCertificateId;
@property (nonatomic, copy)   NSString *inspectionCertificateId;
@property (nonatomic, copy)   NSString *operatingCertificateId;
@property (nonatomic, copy)   NSString *imageUrl;

@property (nonatomic, assign) NSInteger service;
@property (nonatomic, copy)   NSString *serviceName;
@property (nonatomic, copy)   NSString* colorCode;
@end
