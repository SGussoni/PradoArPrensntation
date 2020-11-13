//
//  SculptureViewController.swift
//  ARKITPresentacion
//
//  Created by sgussoni on 04/11/2020.
//

import UIKit
import SceneKit
import ARKit


class SculptureViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var sculptures = [String: Pictures]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        loadData()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
        
        loadObjects()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func  loadData() {
        guard let url = Bundle.main.url(forResource: "sculptures", withExtension: "json") else {
            fatalError("Unable to find JSON in bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load JSON")
        }
        
        let decoder = JSONDecoder()
        
        guard let loadedPictures = try? decoder.decode([String: Pictures].self, from: data) else {
            fatalError("Unable to parse JSON.")
        }
        
        
        
        sculptures = loadedPictures
    }
    
    func loadImageFromURL() {
        let configuration = ARImageTrackingConfiguration()
        
        
        guard var trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "sculptures", bundle: nil) else {
            fatalError("Couldn't load tracking images")
            
        }
        
        var count = 0
        for sculpture in sculptures {
            
            print("Picture: \(count)")
            count += 1
            
            guard let url = URL(string: sculpture.value.source) else {
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            
            let myImage = UIImage(data: data)
            
            let width = CGFloat(sculpture.value.width) ?? 0
            
            
            let referenceImage = ARReferenceImage((myImage?.cgImage)!, orientation: .up, physicalWidth: width)
            
            trackingImages.insert(referenceImage)
            
        }
        
        configuration.trackingImages = trackingImages
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    func loadFromXcAsset(){
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "sculptures", bundle: nil) else {
            fatalError("Couldn't load tracking images")
        }
        
        
        
        configuration.trackingImages = trackingImages
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    func loadObjects() {
        
        let configuration = ARWorldTrackingConfiguration()
        
        guard let trackingObjects = ARReferenceObject.referenceObjects(inGroupNamed: "sculptures", bundle: Bundle.main) else {
            fatalError("Couldn't load tracking Objects")
        }
        
        configuration.detectionObjects = trackingObjects
        
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    
    
    
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        guard  let objectAnchor = anchor as? ARObjectAnchor else {
            return nil
        }
        guard let name = objectAnchor.name else { return nil }
        guard let sculpture = sculptures[name] else { return nil }
        
        let plane = SCNPlane(width: CGFloat(objectAnchor.referenceObject.extent.x * 0.8), height: CGFloat(objectAnchor.referenceObject.extent.y * 0.5))
        plane.firstMaterial?.diffuse.contents = UIColor.clear
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.y = -.pi
        planeNode.eulerAngles.x = -.pi / 3
        
        let node = SCNNode()
        node.addChildNode(planeNode)
        
        //            let spacing: Float = 0.005
        
        let titleNode = textNode(sculpture.name, font: UIFont.boldSystemFont(ofSize: 1), maxWidth: 10)
        titleNode.pivotOnTopCenter()
        
        titleNode.position.x += -0.09
        //Float(plane.width )
        titleNode.position.y += 0 //Float(plane.height)
        
        planeNode.addChildNode(titleNode)
        
        
        
        return node
        
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
