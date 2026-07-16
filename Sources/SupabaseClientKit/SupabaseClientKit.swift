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
    
    public func signIn(email: String, password: String) async throws -> UUID {
        let response = try await self.client.auth.signIn(email: email, password: password)
        return response.user.id
    }
    
    public func signUp(withEmail email: String, password: String) async throws -> UUID {
        let response = try await client.auth.signUp(email: email, password: password)
        let userId = response.user.id
        return userId
    }
    
    public func signIn(withPhone phoneNumber: String, password: String) async throws -> UUID {
        let response = try await self.client.auth.signIn(phone: phoneNumber, password: password)
        let userId = response.user.id
        return userId
    }
    
    public func signUp(withPhone phoneNumber: String, password: String) async throws -> UUID {
        let response = try await client.auth.signUp(phone: phoneNumber, password: password)
        let userId = response.user.id
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
    
    public func upsert<T: Encodable>(intoTable tableName: String, value: T) async throws {
        try await self.client
            .from(tableName)
            .upsert(value)
            .execute()
    }
    
    public func fetch<T: Decodable>(fromTable tableName: String) async throws -> T {
        return try await self.client
            .from(tableName)
            .select()
            .execute()
            .value
    }
    
    public func fetch<T: Decodable>(fromTable tableName: String, withMatching columnName: String, andId id: String) async throws -> T {
        return try await self.client
            .from(tableName)
            .select()
            .equals(columnName, value: id)
            .execute()
            .value
    }
    
    public func fetchOne<T: Decodable>(fromTable tableName: String, macthingWith column: String, withId id: PostgrestFilterValue) async throws -> T {
        return try await self.client
            .from(tableName)
            .select()
            .eq(column, value: id)
            .single()
            .execute()
            .value
    }
    
    public func update<T: Encodable>(fromTable tableName: String, macthingWith column: String, andWithId id: PostgrestFilterValue, item: T) async throws {
        try await client
            .from(tableName)
            .update(item)
            .eq(column, value: id)
            .execute()
        
    }
    
    public func delete(fromTable tableName: String, macthingWith column: String, andValue value: PostgrestFilterValue) async throws {
         try await self.client
            .from(tableName)
            .delete()
            .eq(column, value: value)
            .execute()
    }
    
    public var currentUser: User  {
        get async throws {
            try await self.client.auth.session.user
        }
    }
}


