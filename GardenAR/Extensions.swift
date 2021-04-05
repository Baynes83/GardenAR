//
//  Extensions.swift
//  GardenAR
//
//  Created by Julian Hindriks on 16/08/2018.
//  Copyright © 2018 Juuls. All rights reserved.
//

import ARKit

extension CGPoint {
    
    init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
    }
    
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
    
}

extension float4x4 {
    
    var translation: float3 {
        get {
            let translation = columns.3
            return float3(translation.x, translation.y, translation.z)
        }
        set {
            columns.3 = float4(newValue.x, newValue.y, newValue.z, columns.3.w)
        }
    }
    
}
