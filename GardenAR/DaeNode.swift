//
//  GardenShedNode.swift
//  GardenAR
//
//  Created by Julian Hindriks on 12/04/2018.
//  Copyright © 2018 Juuls. All rights reserved.
//

import SceneKit

class DaeNode: SCNNode {
    
    init(named name: String) {
        super.init()
        
        if let filePath = Bundle.main.path(forResource: name, ofType: "dae") {
            // ReferenceNode path -> ReferenceNode URL
            let referenceURL = URL(fileURLWithPath: filePath)
            
            // Create reference node
            if let referenceNode = SCNReferenceNode(url: referenceURL) {
                referenceNode.load()
                addChildNode(referenceNode)
            }
        }
        
        // Scale with meters to inch factor
        scale = SCNVector3(0.0254,0.0254,0.0254)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
