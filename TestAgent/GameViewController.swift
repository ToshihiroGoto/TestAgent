//
//  GameViewController.swift
//  TestArgent
//
//  Created by Toshihiro Goto on 2018/05/28.
//  Copyright © 2018年 Toshihiro Goto. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import GameplayKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var agent1 = GKAgent2D()
    var agent2 = GKAgent2D()
    
    var shipNode:SCNNode!
    var ballNode:SCNNode!
    
    var previousUpdateTime: TimeInterval = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 60)
        cameraNode.eulerAngles = SCNVector3(-0.0625,0,0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 3)))
        
        //-----------------------------------
        
        shipNode = ship.childNode(withName: "shipNode", recursively: true)
        
        ballNode = SCNNode(geometry: SCNSphere(radius: 3))
        ballNode.position = SCNVector3(0,0,0)
        scene.rootNode.addChildNode(ballNode)

        agent1.position = float2(shipNode.worldPosition.x, shipNode.worldPosition.z)
        
        agent2.position = float2(0, 0)
        agent2.mass = 0.3
        agent2.maxAcceleration = 16
        agent2.maxSpeed = 30
        agent2.behavior = GKBehavior(goal: GKGoal(toSeekAgent: agent1), weight: 1)
        
        //-----------------------------------
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        scnView.delegate = self
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        var calcTime: TimeInterval = 0
        
        if previousUpdateTime != 0 {
            calcTime = time - previousUpdateTime
        }

        agent1.position = float2(shipNode.worldPosition.x, shipNode.worldPosition.z)
        agent2.update(deltaTime: calcTime)

        ballNode.position = SCNVector3(agent2.position.x, 0, agent2.position.y)
        
        print("agent1: \(agent1.position)")
        print("agent2: \(agent2.position)")
        
        previousUpdateTime = time
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
