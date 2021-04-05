//
//  ViewController.swift
//  GardenAR
//
//  Created by Julian Hindriks on 11/04/2018.
//  Copyright © 2018 Juuls. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet fileprivate var sceneView: ARSCNView!
    
    fileprivate let configuration = ARWorldTrackingConfiguration()
    fileprivate var planes = [UUID: VirtualPlane]()
    fileprivate let gardenShedNodeName = "Tuinhuis"

    fileprivate var selectedNode: SCNNode?
    
    fileprivate var addedNode = false
    
    fileprivate var zDepth: Float = 0
    
    private var currentTrackingPosition: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setup()
        registerGestureRecognizers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        runSession()
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard
//            let touch = touches.first,
//            let hit = sceneView.hitTest(touch.location(in: sceneView)).first
//            else { return }
//
//        selectedNode = hit.node
//        zDepth = sceneView.projectPoint(hit.node.position).z
//
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard
//            let selectedNode = selectedNode,
//            let touch = touches.first
//            else { return }
//
//        let location = touch.location(in: sceneView)
//        let position = SCNVector3(Float(location.x),
//                                  Float(location.y),
//                                  zDepth)
//        selectedNode.position = sceneView.unprojectPoint(position)
//
//    }
    
}

extension ViewController {
    
    fileprivate func setup() {
        configuration.planeDetection = [.horizontal]
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.delegate = self
        sceneView.session.delegate = self
    }
    
    fileprivate func runSession() {
        sceneView.session.run(configuration)
    }
    
    fileprivate func virtualPlane(for touchPoint: CGPoint) -> VirtualPlane? {
        let hits = sceneView.hitTest(touchPoint, types: .existingPlaneUsingExtent)
        
        guard let firstHit = hits.first,
            let identifier = firstHit.anchor?.identifier,
            let virtualPlane = planes[identifier]
            else { return nil }
        
        return virtualPlane
    }
    
    fileprivate func addGardenShed(to plane: VirtualPlane, at touchPoint: CGPoint) {
        let hits = sceneView.hitTest(touchPoint, types: .existingPlaneUsingExtent)
        
        guard
            !addedNode,
            let firstHit = hits.first
            else { return }
        
        let node = DaeNode(named: "Tuin exact")
//        let node = SCNNode(geometry: SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0))
        
        node.name = gardenShedNodeName
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        node.position = SCNVector3(firstHit.worldTransform.columns.3.x,
                                   firstHit.worldTransform.columns.3.y,
                                   firstHit.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(node)
        addedNode = true
        
    }
    
    fileprivate func registerGestureRecognizers() {
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressGesture.minimumPressDuration = 0.5
        sceneView.addGestureRecognizer(longPressGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate))
        sceneView.addGestureRecognizer(rotationGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan))
        sceneView.addGestureRecognizer(panGesture)
        
    }
    
    @objc private func rotate(gesture: UIRotationGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        switch gesture.state {
        case .began:
            selectedNode = node(named: gardenShedNodeName, at: location)
        case .changed:
            guard let selectedNode = selectedNode else { break }
            let rotateAction = SCNAction.rotateBy(x: 0, y: gesture.rotation, z: 0, duration: 0)
            selectedNode.runAction(rotateAction)
            gesture.rotation = 0
        case .ended:
            selectedNode = nil
        default:
            break
        }

    }
    
    
    @objc private func pan(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        switch gesture.state {
        case .began:
            selectedNode = node(named: gardenShedNodeName, at: location)
            guard let node = selectedNode else { return }
            zDepth = sceneView.projectPoint(node.position).y
        case .changed:
            guard let selectedNode = selectedNode else { return }
            let translation = gesture.translation(in: sceneView)
            
            let currentPosition = currentTrackingPosition ?? CGPoint(sceneView.projectPoint(selectedNode.worldPosition))
            
            currentTrackingPosition = CGPoint(x: currentPosition.x + translation.x,
                                              y: currentPosition.y + translation.y)
            
            gesture.setTranslation(.zero, in: sceneView)
        case .ended:
            fallthrough
        default:
            currentTrackingPosition = nil
            selectedNode = nil
        }
        
    }
    
    @objc private func longPress(gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        switch gesture.state {
        case .began:
            if let virtualPlane = virtualPlane(for: location),
                virtualPlane.planeAnchor.alignment == .horizontal {
                addGardenShed(to: virtualPlane, at: location)
            }
        default:
            break
        }
        
    }
    
    private func node(named nodeName: String, at location: CGPoint) -> SCNNode? {
        if let firstHit = sceneView.hitTest(location).first {
            if firstHit.node.name == nodeName {
                return firstHit.node
            }
        }
        
        return nil
    }
    
    private func updateSelectedNodeToCurrentTrackingPosition() {
        guard
            let selectedNode = selectedNode,
            let position = currentTrackingPosition
            else { return }
        
        translate(selectedNode, basedOn: position)
    }
    
    private func translate(_ node: SCNNode, basedOn screenPosition: CGPoint) {
        
        let point = SCNVector3(screenPosition.x,
                               screenPosition.y,
                               screenPosition.y)
        let newPosition = sceneView.unprojectPoint(point)
        
        print("new pos: \(newPosition)")
        
        var transform = node.simdWorldTransform
        transform.columns.3.x = newPosition.x
        transform.columns.3.z = newPosition.z
        
        node.simdWorldPosition = transform.translation
        
    }
    
}

extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let virtualPlane = VirtualPlane(planeAnchor: planeAnchor)
        planes[planeAnchor.identifier] = virtualPlane
        node.addChildNode(virtualPlane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard
            let planeAnchor = anchor as? ARPlaneAnchor,
            let plane = planes[anchor.identifier]
            else { return }
        
        plane.updateWithPlaneAnchor(planeAnchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard
            let planeAnchor = anchor as? ARPlaneAnchor,
            let index = planes.index(forKey: planeAnchor.identifier)
            else { return }
        
        planes.remove(at: index)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateSelectedNodeToCurrentTrackingPosition()
        }
    }
    
}

extension ViewController: ARSessionDelegate {
    
}
