//
//  PHAssetWrapper.swift
//  
//
//  Created by Christian Elies on 27.01.20.
//

import Photos

/// Box type for storing a reference to
/// a `PHAsset` instance
///
public final class PHAssetWrapper {
    public var value: PHAsset?

    init(value: PHAsset) {
        self.value = value
    }
    
    public func getAsset() -> PHAsset? {
        return value
    }
}
