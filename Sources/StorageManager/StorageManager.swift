//
//  StorageManager.swift
//  SupabaseClientKit
//
//  Created by Hardik Modha on 20/07/26.
//

import Foundation
import SupabaseClientKit
import Supabase


public final class StorageManager: Sendable {
    
    let supabaseClient: SupabaseClientKit
    
    public init(supabaseClient: SupabaseClientKit) {
        self.supabaseClient = supabaseClient
    }
    
    private var client: SupabaseClient {
        self.supabaseClient.client
    }
    
    public func uploadPhoto(forId id: UUID, imageData: Data, bucketName: String) async throws -> String {
        let path = "\(id)/avatar.jpg"
        return try await self.uploadImage(forPath: path, data: imageData, bucketName: bucketName)
    }
    
    
    public func uploadPhotos(forId id: UUID, imagesData: [Data], bucketName: String) async throws -> [String] {
        return try await withThrowingTaskGroup(of: String.self) { group in
            for (index, data) in imagesData.enumerated() {
                group.addTask { 
                    let path = try await self.uploadImages(withId: id, data: data, bucketName: bucketName, index: index)
                    return path
                }
            }
            
            var results: [String] = [String]()
            
            for try await result in group {
                results.append(result)
            }
            
            return results
        }
    }
    
    private func uploadImages(withId id: UUID, data: Data, bucketName: String, index: Int) async throws -> String {
        let path = "\(id)/\(index).jpg"
        return try await uploadImage(forPath: path, data: data, bucketName: bucketName)
    }
    
    private func uploadImage(forPath path: String, data: Data, bucketName: String) async throws -> String {
        let fullPath = try await self
            .client
            .storage
            .from(bucketName)
            .update(path, data: data)
            .path
        
        print("Full path: \(fullPath)")
        
        let publicURL = "\(self.supabaseClient.projectURL)/storage/v1/object/public/\(bucketName)/\(path)"
        
        return publicURL
        
    }
}
