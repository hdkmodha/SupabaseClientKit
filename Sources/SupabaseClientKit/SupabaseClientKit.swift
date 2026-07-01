//
//  SupabaseClientKit.swift
//  SupabaseClientKit
//
//  Created by Hardik Modha on 24/06/26.
//

import Foundation
import Supabase

public protocol SupabaseClientProvider: Sendable {
     var development: SupabaseClient { get }
     var production: SupabaseClient { get }
}


public final class SupabaseManager: Sendable {
    
    let clientProvider: SupabaseClientProvider
    
    public init(clientProvider: SupabaseClientProvider) {
        self.clientProvider = clientProvider
    }
    
    private var client: SupabaseClient {
        #if DEBUG
        self.clientProvider.development
        #else
        self.clientProvider.production
        #endif
    }
    
    public func signIn(email: String, password: String) async throws -> String? {
        let response = try await self.client.auth.signIn(email: email, password: password)
        return response.user.id.uuidString
    }
    
    public func signUp(withEmail email: String, password: String) async throws -> String? {
        let response = try await client.auth.signUp(email: email, password: password)
        let userId = response.user.id.uuidString
        return userId
    }
    
    public func signIn(withPhone phoneNumber: String, password: String) async throws -> String? {
        let response = try await self.client.auth.signIn(phone: phoneNumber, password: password)
        let userId = response.user.id.uuidString
        return userId
    }
    
    public func signUp(withPhone phoneNumber: String, password: String) async throws -> String? {
        let response = try await client.auth.signUp(phone: phoneNumber, password: password)
        let userId = response.user.id.uuidString
        return userId
    }
    
    public func signInWithIdToken(withToken idToken: String, accessToken: String, provider: OpenIDConnectCredentials.Provider) async throws -> Session {
        let credenital = OpenIDConnectCredentials(
            provider: provider,
            idToken: idToken,
            accessToken: accessToken
        )
        let session = try await self.client.auth.signInWithIdToken(credentials: credenital)
        return session
    }
    
    public func signOut() async throws {
        try await self.client.auth.signOut()
    }
    
    public func insert<T: Encodable>(intoTable tableName: String, value: T) async throws {
        try await self.client
            .from(tableName)
            .insert(value)
            .execute()
    }
    
    public func fetch<T: Decodable>(fromTable tableName: String) async throws -> PostgrestResponse<T> {
        return try await self.client
            .from(tableName)
            .select()
            .execute()
    }
    
    public var currentUser: User  {
        get async throws {
            try await self.client.auth.session.user
        }
    }
}


