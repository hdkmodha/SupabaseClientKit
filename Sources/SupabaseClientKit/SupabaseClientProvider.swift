//
//  SupabaseClientProvider.swift
//  SupabaseClientKit
//
//  Created by Hardik Modha on 26/08/26.
//

import Foundation
import Supabase

public protocol SupabaseClientProvider: Sendable {
    
    var devProjectURL: String { get }
    var prodProjectURL: String { get }
    var devToken: String { get }
    var prodToken: String { get }
    var development: SupabaseClient { get }
    var production: SupabaseClient { get }
}


extension SupabaseClientProvider {
    
    var development: SupabaseClient {
        return SupabaseClient(supabaseURL: URL(string: self.devProjectURL)!, supabaseKey: devToken)
    }
    
    var production: SupabaseClient {
        return SupabaseClient(supabaseURL: URL(string: self.prodProjectURL)!, supabaseKey: prodToken)
    }
}
