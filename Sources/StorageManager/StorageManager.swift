//
//  StorageManager.swift
//  SupabaseClientKit
//
//  Created by Hardik Modha on 20/07/26.
//

import Supabase


final class StorageManager {
    
    let supabaseClient: SupabaseClientKit
    
    public init(supabaseClient: SupabaseClientKit) {
        self.supabaseClient = supabaseClient
    }
    
    private var client: SupabaseClient {
        self.supabaseClient.client
    }
    
    public func uploadPhoto(withData imageData: Data, bucketName: String, projectURL: String) -> async throws -> String  {
        
        let uuid = UUID()
        let path = "\(uuid.uuidString).jpg"
        
        self.client
            .storage
            .from(bucketName)
            .update(
                path: path,
                data: imageData,
                options: FileOptions(
                    contentType: "image/jpeg",
                    upsert: true
                )
            )
            .path
        
        return path
    }
    
}
