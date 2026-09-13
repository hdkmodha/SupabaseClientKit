//
//  SupabaseClientKit.swift
//  SupabaseClientKit
//
//  Created by Hardik Modha on 24/06/26.
//

import Foundation
import Supabase

public final class SupabaseClientKit: Sendable {
    
    private let clientProvider: SupabaseClientProvider
    
    public init(clientProvider: SupabaseClientProvider) {
        self.clientProvider = clientProvider
    }
        
    public var client: SupabaseClient {
        #if DEBUG
        self.clientProvider.development
        #else
        self.clientProvider.production
        #endif
    }
    
    
    public var projectURL: String {
        #if DEBUG
        self.clientProvider.devProjectURL
        #else
        self.clientProvider.prodProjectURL
        #endif
    }
}





