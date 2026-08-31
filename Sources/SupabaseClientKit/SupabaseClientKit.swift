//
//  SupabaseClientKit.swift
//  SupabaseClientKit
//
//  Created by Hardik Modha on 24/06/26.
//

import Foundation
import SupabaseClientProvider
import Supabase

public final class SupabaseClientKit: Sendable {
    
    private let clientProvider: SupabaseClientProvider
    
    public init(clientProvider: SupabaseClientProvider) {
        self.clientProvider = clientProvider
    }
        
    var client: SupabaseClient {
        #if DEBUG
        self.clientProvider.development
        #else
        self.clientProvider.production
        #endif
    }
    
}





