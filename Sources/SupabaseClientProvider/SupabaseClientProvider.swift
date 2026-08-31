//
//  SupabaseClientProvider.swift
//  SupabaseClientKit
//
//  Created by Hardik Modha on 26/08/26.
//

import Foundation
import Supabase

public protocol SupabaseClientProvider: Sendable {
     var development: SupabaseClient { get }
     var production: SupabaseClient { get }
}
