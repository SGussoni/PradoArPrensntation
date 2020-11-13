//
//  EmptyViewController.swift
//  ARKITPresentacion
//
//  Created by sgussoni on 04/11/2020.
//

import UIKit
import SceneKit
import ARKit


class EmptyViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var pictures = [String: Pictures]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        configureLighting()
        addDragon()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        // Create a session configuration
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
        
    
    
    func addDragon(x: Float = 0, y: Float = 0, z: Float = -0.5) {
        guard let paperPlaneScene = SCNScene(named: "paperPlane.scn"), let paperPlaneNode = paperPlaneScene.rootNode.childNode(withName: "paperPlane", recursively: true) else { return }
        paperPlaneNode.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(paperPlaneNode)
        
        
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if  let imageAnchor = anchor as? ARImageAnchor {
            guard let name = imageAnchor.referenceImage.name else { return nil }
            guard let pictures = pictures[name] else { return nil }
            
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor.clear
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            
            let node = SCNNode()
            node.addChildNode(planeNode)
            
            let spacing: Float = 0.005
            
            let titleNode = textNode(pictures.name, font: UIFont.boldSystemFont(ofSize: 70), maxWidth: 100)
            titleNode.pivotOnTopLeft()
            
            titleNode.position.x += Float(plane.width / 2) + spacing
            titleNode.position.y += Float(plane.height / 2)
            
            planeNode.addChildNode(titleNode)
            
            
            
            let bioNode = textNode(pictures.bio, font: UIFont.systemFont(ofSize: 40), maxWidth: 100)
            bioNode.pivotOnTopLeft()
            
            bioNode.position.x += Float(plane.width / 2) + spacing
            bioNode.position.y = titleNode.position.y - titleNode.height - spacing
            planeNode.addChildNode(bioNode)
            
            
            return node
        }else         if  let objectAnchor = anchor as? ARObjectAnchor {
            guard let name = objectAnchor.name else { return nil }
            guard let pictures = pictures[name] else { return nil }
            
            let plane = SCNPlane(width: CGFloat(objectAnchor.referenceObject.extent.x * 0.8), height: CGFloat(objectAnchor.referenceObject.extent.y * 0.5))
            plane.firstMaterial?.diffuse.contents = UIColor.clear
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.y = -.pi
            planeNode.eulerAngles.x = -.pi / 3

            let node = SCNNode()
            node.addChildNode(planeNode)
            
//            let spacing: Float = 0.005
            
            let titleNode = textNode(pictures.name, font: UIFont.boldSystemFont(ofSize: 1), maxWidth: 10)
            titleNode.pivotOnTopCenter()
            
            titleNode.position.x += -0.09
            //Float(plane.width )
            titleNode.position.y += 0 //Float(plane.height)
            
            planeNode.addChildNode(titleNode)
            
            
                        
            return node
            
        }
        
        return nil 
    }
    
    func textNode(_ str: String, font: UIFont, maxWidth: Int? = nil) -> SCNNode {
        let text = SCNText(string: str, extrusionDepth: 0)
        
        text.flatness = 0.1
        text.font = font
        //        text.firstMaterial?.diffuse.contents = UIColor.blue
        
        if let maxWidth = maxWidth {
            text.containerFrame = CGRect(origin: .zero, size: CGSize(width: maxWidth, height: 500))
            text.isWrapped = true
        }
        
        let textNode = SCNNode(geometry: text)
        textNode.scale = SCNVector3(0.02, 0.02, 0.02)
        
        return textNode
    }
}

