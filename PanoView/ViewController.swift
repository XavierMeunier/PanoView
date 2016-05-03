//
//  ViewController.swift
//  PanoView
//
//  Created by idz on 5/1/16.
//  Copyright © 2016 iOS Developer Zone. 
//  License: MIT https://raw.githubusercontent.com/iosdevzone/PanoView/master/LICENSE
//

import UIKit
import SceneKit
import CoreMotion

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()
    let cameraNode = SCNNode()
    
    
    @IBOutlet weak var sceneView: SCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Load assets
        guard let imagePath = NSBundle.mainBundle().pathForResource("Hellbrunn25", ofType: "jpg") else {
            fatalError("Failed to find path for panaromic file.")
        }
        guard let image = UIImage(contentsOfFile:imagePath) else {
            fatalError("Failed to load panoramic image")
        }
        
        // Set the scene
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.allowsCameraControl = true
        
        //Create node, containing a sphere, using the panoramic image as a texture
        let sphere = SCNSphere(radius: 20.0)
        sphere.firstMaterial!.doubleSided = true
        sphere.firstMaterial!.diffuse.contents = image
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Make(0,0,0)
        scene.rootNode.addChildNode(sphereNode)
        
        // Lights, ...
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor(white: 0.67, alpha: 1.0)
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Camera, ...
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(cameraNode)
        
        // Action (Sorry! I could not help myself)
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue()) {
                [weak self](data: CMDeviceMotion?, error: NSError?) in
                
                guard let data = data else {
                    NSLog("Error in deviceMotionUpdate \(error)")
                    return
                }
                guard let strongSelf = self else {
                    NSLog("Captured weak self was nil in deviceMotionUpdate")
                    return
                }
                
                let attitude: CMAttitude = data.attitude
                
                strongSelf.cameraNode.eulerAngles = SCNVector3Make(Float(attitude.roll - M_PI/2.0), Float(attitude.yaw), Float(attitude.pitch))
            }
            
        }
        else {
            fatalError("Device motion is not available")
        }


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

