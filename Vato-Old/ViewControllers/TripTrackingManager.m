#import "TripTrackingManager.h"
#import <FirebaseStorage/FirebaseStorage.h>

@interface TripTrackingManager()
@property (strong, nonatomic) FCBooking *book;
@property (strong, nonatomic) FIRDocumentReference *documentRef;
@property (strong, nonatomic) RACDisposable *disposeListen;
@property (strong, nonatomic) RACSubject *mErrorSignal;
@property (strong, nonatomic) RACSubject *mBookingSignal;
@property (strong, nonatomic) RACSubject *mCommandSignal;
@property (strong, nonatomic) RACSubject *mBookInfoSignal;
@property (strong, nonatomic) RACSubject *mBookExtraSignal;
@property (strong, nonatomic) RACSubject *mBookEstimateSignal;
@end

@implementation TripTrackingManager

#pragma mark - Class's constructors
- (instancetype)init:(NSString *)tripId {
    NSAssert(tripId.length != 0 , @"Not have tripId");
    if (self = [super init]) {
        self.mErrorSignal = [RACSubject new];
        self.mBookingSignal = [RACSubject new];
        self.mCommandSignal = [RACSubject new];
        self.mBookInfoSignal = [RACSubject new];
        self.mBookExtraSignal = [RACSubject new];
        self.mBookEstimateSignal = [RACSubject new];
        self.documentRef = [[FIRFirestore firestore] documentWithPath:[NSString stringWithFormat:@"Trip/%@", tripId]];
        [self setupListen];
    }
    return self;
}

- (void) setupListen {
    @weakify(self);
    self.disposeListen = [[self listenChange] subscribeNext:^(NSDictionary *x) {
        @strongify(self);
        NSError *e;
        FCBooking *newChange = [[FCBooking alloc] initWithDictionary:x error:&e];
        if (e) {
            NSLog(@"%@", [e localizedDescription]);
        }
        self.book = newChange;
    } error:^(NSError *error) {
        @strongify(self);
        [self.mErrorSignal sendNext:error];
    }];
}

- (void)dealloc
{
    if (self.disposeListen) {
        [_disposeListen dispose];
    }
    [_mBookingSignal sendCompleted];
    [_mCommandSignal sendCompleted];
    [_mBookInfoSignal sendCompleted];
    [_mBookExtraSignal sendCompleted];
    [_mBookEstimateSignal sendCompleted];
    
}

- (RACSignal *)listenChange {
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        id<FIRListenerRegistration> handler = [self.documentRef addSnapshotListener:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (snapshot == nil) {
                NSError *e = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{ NSLocalizedDescriptionKey: @"Delete"}];
                [subscriber sendError:e];
                return;
            };
            
            if (error) {
                [subscriber sendError:error];
                return;
            }
            if ([snapshot data] == nil) {
                return;
            }
            [subscriber sendNext:[snapshot data]];
            
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [handler remove];
        }];
    }];
}

- (void)setBook:(FCBooking *)book {
    _book = book;
    if (!book) { return; }
    [_mBookingSignal sendNext:_book];
    [_mCommandSignal sendNext:[_book.command lastObject]];
    [_mBookInfoSignal sendNext:_book.info];
    [_mBookExtraSignal sendNext:_book.extra];
    [_mBookEstimateSignal sendNext:_book.estimate];
}


#pragma mark - Publish
- (RACSignal *)bookEstimateSignal {
    return [[_mBookEstimateSignal distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)bookExtraSignal {
    return [[_mBookExtraSignal distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)commandSignal {
    return [[[[_mCommandSignal doNext:^(FCBookCommand *command) {
        NSLog(@"Commands %ld", (long)command.status);
    }] distinctUntilChanged] distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)bookInfoSignal {
    return  [[_mBookInfoSignal distinctUntilChanged] deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)bookingSignal {
    return [_mBookingSignal deliverOn:[RACScheduler mainThreadScheduler]];
}

- (RACSignal *)errorSignal {
    return [_mErrorSignal deliverOn:[RACScheduler mainThreadScheduler]];
}

#pragma mark - Set data
- (void)setDataToDatabase:(NSString *)path json:(NSDictionary *)json update:(BOOL)update {
    NSArray<NSString *> *components = [path componentsSeparatedByString:@"/"];
    NSDictionary *result;
    if (path.length == 0) {
        result = json;
    } else {
        result = [NSDictionary new];
        for (NSInteger idx = components.count - 1; idx >= 0; idx--) {
            NSString *key = components[idx];
            if ([[result allValues] count] == 0) {
                result = @{key: json};
            } else {
                result = @{key: result};
            }
        }
    }
    NSLog(@"!!!!! json update : %@", result);
    [self.documentRef setData:result merge:update];
}

#pragma mark - load trip
+ (RACSignal *)loadTrip:(NSString *)tripId {
    FIRDocumentReference *tripRef = [[FIRFirestore firestore] documentWithPath:[NSString stringWithFormat:@"Trip/%@", tripId]];
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [tripRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
            if (error) {
                [subscriber sendError:error];
                return;
            }
            
            NSError *err;
            NSDictionary *json = [snapshot data] ?: @{};
            FCBooking* booking = [[FCBooking alloc] initWithDictionary:json error:&err];
            if (err) {
                [subscriber sendError:err];
                return;
            }
            [subscriber sendNext:booking];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}


- (void)setMutipleDataToDatabase:(NSDictionary *)jsons
                          update:(BOOL)update {
    
    [self.documentRef setData:jsons merge:update];
}

@end

