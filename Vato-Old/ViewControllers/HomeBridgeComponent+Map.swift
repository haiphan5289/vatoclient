//  File name   : HomeBridgeComponent+Map.swift
//
//  Author      : Vato
//  Created date: 9/13/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import Firebase
import RxSwift

class HomeBridgeComponent: Component<EmptyDependency> {

    var firebaseDatabase: DatabaseReference {
        return mDependency?.firebaseDatabase ?? shared { Database.database().reference() }
    }

    var mutableAuthenticated: MutableAuthenticatedStream {
        return mDependency?.mutableAuthenticated ?? shared { AuthenticatedStreamImpl() }
    }
    
    var mutableProfile: MutableProfileStream {
        guard let p = mDependency?.mutableProfile else {
            return shared { ProfileStreamImpl() }
        }
        return p
    }

    var mutablePromotionNows: MutablePromotionNowStream {
        return mDependency?.mutablePromotionNows ?? shared { PromotionNowStreamImpl() }
    }

    weak var mDependency: VatoDependencyMainServiceProtocol?
    init(dependency: VatoDependencyMainServiceProtocol?) {
        self.mDependency = dependency
        super.init(dependency: EmptyComponent())
    }
}

/// The dependencies needed from the parent scope of HomeBridge to provide for the Map scope.
// todo: Update HomeBridgeDependency protocol to inherit this protocol.
protocol HomeBridgeDependencyMap: Dependency {
    // todo: Declare dependencies needed from the parent scope of HomeBridge to provide dependencies
    // for the Map scope.
}

extension HomeBridgeComponent: MapDependency {
    var authenticated: AuthenticatedStream {
        return mutableAuthenticated
    }
    
    var profile: ProfileStream {
        return mutableProfile
    }

    var mutableDisplayPromotionNow: MutableDisplayPromotionNowStream {
        return mutablePromotionNows
    }
}


// MARK: - Firebase Auth Token
extension HomeBridgeComponent {
}
