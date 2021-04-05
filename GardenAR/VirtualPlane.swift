//
//  VirtualPlane.swift
//  GardenAR
//
//  Created by Julian Hindriks on 12/04/2018.
//  Copyright © 2018 Juuls. All rights reserved.
//

import ARKit

class VirtualPlane: SCNNode {
    
    let planeAnchor: ARPlaneAnchor
    fileprivate let planeGeometry: SCNPlane
    
    init(planeAnchor: ARPlaneAnchor) {
        self.planeAnchor = planeAnchor
        self.planeGeometry = SCNPlane(width: CGFloat(planeAnchor.extent.x),
                                      height: CGFloat(planeAnchor.extent.z))
        
        let color: UIColor?
        switch planeAnchor.alignment {
        case .horizontal:
            color = UIColor.white.withAlphaComponent(0.5)
        case .vertical:
            color = UIColor.blue.withAlphaComponent(0.5)
        }

        self.planeGeometry.firstMaterial?.diffuse.contents = color
        
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3(planeAnchor.center.x,
                                        0,
                                        planeAnchor.center.y)
        planeNode.eulerAngles.x = -.pi / 2
        
        super.init()
        
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        
        updateMaterialDimensions()
        self.addChildNode(planeNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func updateMaterialDimensions() {
        let width = Float(planeGeometry.width)
        let height = Float(planeGeometry.height)
        planeGeometry.firstMaterial?.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1)
    }
    
    func updateWithPlaneAnchor(_ planeAnchor: ARPlaneAnchor) {
        planeGeometry.width = CGFloat(planeAnchor.extent.x)
        planeGeometry.height = CGFloat(planeAnchor.extent.z)
        position = SCNVector3(planeAnchor.center.x,
                              0,
                              planeAnchor.center.y)
        updateMaterialDimensions()
    }
    
}
