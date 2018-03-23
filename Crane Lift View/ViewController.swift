//
//  ViewController.swift
//  Crane Lift View
//
//  Created by Yutong Dong on 27/2/18.
//  Copyright © 2018 Yutong Dong. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {

    @IBOutlet weak var SceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        SceneView.session.run(configuration)
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }

    @IBAction func AddCube(_ sender: Any) {
//        let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
//
//        let cc = getCameraCoordinates(sceneview: SceneView)
//        cubeNode.position = SCNVector3(cc.x, cc.y, cc.z)
//
//        SceneView.scene.rootNode.addChildNode(cubeNode)
//
//        let result = SceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
//
//        // Build a SCNVector3 with the result
//        let position = SCNVector3(
//            result.worldTransform.columns.3.x,
//            result.worldTransform.columns.3.y,
//            result.worldTransform.columns.3.z
//        )
//        cubeNode.position = SCNVector3(position.x, position.y, position.z)
//        SceneView.scene.rootNode.addChildNode(cubeNode)
    }
    struct myCameraCoordinates {
        var x = Float()
        var y = Float()
        var z = Float()
    }
    func getCameraTransform(for sceneView: ARSCNView) -> MDLTransform {
        let transform = sceneView.session.currentFrame?.camera.transform
        return MDLTransform(matrix: transform!)
    }
    func  getCameraCoordinates(sceneview: ARSCNView) -> myCameraCoordinates {
        let cameraTransform = SceneView.session.currentFrame?.camera.transform
        //print (cameraTransform)
        let cameraCoordinates = MDLTransform(matrix: cameraTransform!)

        var cc = myCameraCoordinates()
        cc.x = cameraCoordinates.translation.x
        cc.y = cameraCoordinates.translation.y
        cc.z = cameraCoordinates.translation.z
        
        return cc
    }

    // Intercept touch and place object
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard touch.tapCount == 1 else { return }
        let location = touches.first!.location(in: SceneView)
        
        // Remove object
        var hitTestOptions = [SCNHitTestOption: Any]()
        hitTestOptions[SCNHitTestOption.boundingBoxOnly] = true
        let hitResults: [SCNHitTestResult]  =
            SceneView.hitTest(location, options: hitTestOptions)
        
        if let hit = hitResults.first {
            hit.node.removeFromParentNode()
            return
        }
        
        // Add object
        //let transform = getCameraTransform(for: SceneView)
        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let cube = SCNNode(geometry: boxGeometry)

        let hitResultsFeaturePoints: [ARHitTestResult] =
            SceneView.hitTest(location, types: .featurePoint)
        if let hit = hitResultsFeaturePoints.first {
            // Get a transformation matrix with the euler angle of the camera
            let rotate = simd_float4x4(SCNMatrix4MakeRotation(SceneView.session.currentFrame!.camera.eulerAngles.y, 0, 1, 0))
            
            // Combine both transformation matrices
            let finalTransform = simd_mul(hit.worldTransform, rotate)
            let position = SCNVector3(
                finalTransform.columns.3.x,
                finalTransform.columns.3.y,
                finalTransform.columns.3.z
            )
            cube.position = position
            SceneView.scene.rootNode.addChildNode(cube)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

