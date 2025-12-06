//
//  ImageCacheService.swift
//  VoiceSketch
//

import Foundation
import UIKit

/// High-performance image caching service
actor ImageCacheService {
    private let logger = AppLogger(category: "ImageCache")
    private let memoryCache = NSCache<NSURL, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    init() {
        // Set up cache directory
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("artwork_cache", isDirectory: true)
        
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        
        // Configure memory cache
        memoryCache.countLimit = 50  // 50 images
        memoryCache.totalCostLimit = 100 * 1024 * 1024  // 100MB
        
        logger.info("Cache initialized at: \(cacheDirectory.path)")
    }
    
    /// Get image from cache
    func image(for url: URL) async -> UIImage? {
        // 1. Check memory cache
        if let cached = memoryCache.object(forKey: url as NSURL) {
            logger.debug("Memory cache hit: \(url.lastPathComponent)")
            return cached
        }
        
        // 2. Check disk cache
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            // Store in memory for next access
            memoryCache.setObject(image, forKey: url as NSURL, cost: data.count)
            logger.debug("Disk cache hit: \(url.lastPathComponent)")
            return image
        }
        
        logger.debug("Cache miss: \(url.lastPathComponent)")
        return nil
    }
    
    /// Save image data to cache
    func save(_ data: Data) async throws -> URL {
        let filename = UUID().uuidString + ".png"
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        try data.write(to: fileURL, options: .atomic)
        
        // Also cache in memory
        if let image = UIImage(data: data) {
            memoryCache.setObject(image, forKey: fileURL as NSURL, cost: data.count)
        }
        
        logger.info("Saved image: \(filename)")
        return fileURL
    }
    
    /// Generate and cache thumbnail
    func generateThumbnail(for url: URL, size: CGSize = CGSize(width: 300, height: 300)) async -> Data? {
        guard let image = await image(for: url) else {
            return nil
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let thumbnail = renderer.image { context in
            // Calculate aspect-fit rect
            let aspectRatio = image.size.width / image.size.height
            let targetRatio = size.width / size.height
            
            var drawRect = CGRect(origin: .zero, size: size)
            
            if aspectRatio > targetRatio {
                // Image is wider
                let scaledHeight = size.width / aspectRatio
                drawRect.origin.y = (size.height - scaledHeight) / 2
                drawRect.size.height = scaledHeight
            } else {
                // Image is taller
                let scaledWidth = size.height * aspectRatio
                drawRect.origin.x = (size.width - scaledWidth) / 2
                drawRect.size.width = scaledWidth
            }
            
            image.draw(in: drawRect)
        }
        
        return thumbnail.pngData()
    }
    
    /// Clear memory cache
    func clearMemoryCache() {
        memoryCache.removeAllObjects()
        logger.info("Memory cache cleared")
    }
    
    /// Clear all caches
    func clearAll() throws {
        memoryCache.removeAllObjects()
        
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        for url in contents {
            try fileManager.removeItem(at: url)
        }
        
        logger.info("All caches cleared")
    }
    
    /// Get cache size
    func cacheSize() async -> Int64 {
        guard let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) else {
            return 0
        }
        
        var totalSize: Int64 = 0
        for url in contents {
            if let resourceValues = try? url.resourceValues(forKeys: [.fileSizeKey]),
               let fileSize = resourceValues.fileSize {
                totalSize += Int64(fileSize)
            }
        }
        
        return totalSize
    }
}
