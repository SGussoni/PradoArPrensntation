//
//  PicturesViewController.swift
//  ARKITPresentacion
//
//  Created by sgussoni on 04/11/2020.
//

import UIKit
import SceneKit
import ARKit


class PicturesViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var pictures = [String: Pictures]()
    
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
        
            loadFromXcAsset()
            //loadImageFromURL()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func  loadData() {
        guard let url = Bundle.main.url(forResource: "pictures", withExtension: "json") else {
            fatalError("Unable to find JSON in bundle")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load JSON")
        }
        
        let decoder = JSONDecoder()
        
        guard let loadedPictures = try? decoder.decode([String: Pictures].self, from: data) else {
            fatalError("Unable to parse JSON.")
        }
        
        
        
        pictures = loadedPictures
    }
    
    func loadImageFromURL() {
        let configuration = ARImageTrackingConfiguration()
        
        
        guard var trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "pictures", bundle: nil) else {
            fatalError("Couldn't load tracking images")
            
        }
        
        var count = 0
        for picture in pictures {
            
            print("Picture: \(count)")
            count += 1
            
            guard let url = URL(string: picture.value.source) else {
                return
            }
            
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            
            let myImage = UIImage(data: data)
            
            let width = CGFloat(picture.value.width) ?? 0
            
            
            let referenceImage = ARReferenceImage((myImage?.cgImage)!, orientation: .up, physicalWidth: width)
            
            trackingImages.insert(referenceImage)
            
        }
        
        configuration.trackingImages = trackingImages
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    func loadFromXcAsset(){
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "pictures", bundle: nil) else {
            fatalError("Couldn't load tracking images")
        }
        
        
        
        configuration.trackingImages = trackingImages
        
        // Run the view's session
        sceneView.session.run(configuration)
        
    }
    
    
    
    

    
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        guard let name = imageAnchor.referenceImage.name else { return nil }
        guard let pictures = pictures[name] else { return nil }
        
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.clear

        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        let node = SCNNode()
        node.addChildNode(planeNode)
        
        let spacing: Float = 0.005
        
        let titleNode = textNode(pictures.name, font: UIFont.boldSystemFont(ofSize: 7), maxWidth: 75)
        titleNode.pivotOnTopLeft()

        titleNode.position.x += Float(plane.width / 2) + spacing
        titleNode.position.y += Float(plane.height / 2)

        planeNode.addChildNode(titleNode)

        
        
        let bioNode = textNode(pictures.bio, font: UIFont.systemFont(ofSize: 4), maxWidth: 75)
        bioNode.pivotOnTopLeft()
        
        bioNode.position.x += Float(plane.width / 2) + spacing
        bioNode.position.y = titleNode.position.y - titleNode.height - spacing
        planeNode.addChildNode(bioNode)
        
        
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
        textNode.scale = SCNVector3(0.002, 0.002, 0.002)
        
        return textNode
    }
}

extension SCNNode {
    var height: Float {
        return (boundingBox.max.y - boundingBox.min.y) * scale.y
    }
    
    func pivotOnTopLeft() {
        let (min, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation(min.x, max.y, 0)
    }
    
    func pivotOnTopCenter() {
        let (_, max) = boundingBox
        pivot = SCNMatrix4MakeTranslation(0, max.y, 0)
    }
}

extension CGFloat {
    init?(_ str: String) {
        guard let float = Float(str) else { return nil }
        self = CGFloat(float)
    }
}
