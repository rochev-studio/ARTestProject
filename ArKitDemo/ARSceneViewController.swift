//
//  ARSceneViewController.swift
//  ArKitDemo
//
//  Created by Александр Волков on 15.04.2021.
//

import UIKit
import ARKit
import MapKit


class ARSceneViewController: UIViewController, ARSCNViewDelegate,  CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var locationFetchCounter: Int!
    var pointsCount = 0 {
        didSet {
            self.pointsCountLabel.text = "\(pointsCount)"
        }
    }
    

    @IBOutlet weak var sceneView: ARSCNView!
//    let configuration = ARConfiguration.isSupported ? ARWorldTrackingConfiguration() : AROrientationTrackingConfiguration()
    let configuration = ARWorldTrackingConfiguration()
    
    
    @IBOutlet weak var pointsCountLabel: UILabel!
    
    func getLocation() {
        locationFetchCounter = 0
        locationManager.startUpdatingLocation()
    }
    
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if locationFetchCounter > 0 { return }
        
        locationFetchCounter = 1
        
        locationManager.stopUpdatingLocation()
        currentLocation = CLLocation(latitude: 55.751244, longitude: 37.618423)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locationFetchCounter > 0 { return }
        
        locationFetchCounter = 1
        
        locationManager.stopUpdatingLocation()
        currentLocation = locations.last!
        

    }
   
    func openInMap() {
        let placeMark = MKPlacemark(coordinate: self.currentLocation.coordinate)
        let mapItem = MKMapItem(placemark: placeMark)
        mapItem.openInMaps(launchOptions: nil)

    }
    
    func savePoint() {
//        Database.database().reference().child("points").child("\(self.pointsCount)").child("latitude").setValue("\(self.currentLocation.coordinate.latitude)")
//        Database.database().reference().child("points").child("\(self.pointsCount)").child("longitude").setValue("\(self.currentLocation.coordinate.longitude)")
//        pointsCount += 1
//        Database.database().reference().child("pointsCount").setValue(pointsCount)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.sceneView.autoenablesDefaultLighting = true // включаем деволтны источник света
        self.addTapGestureToSceneView()
        
//        Database.database().reference().observe(.value, with: { (snapshot) in
//            guard let value = snapshot.value, snapshot.exists() else {
//                return
//            }
////            pointsCount = value(forKey: "pointsCount") as! Int
//            print(value)
//        })
        //sceneView.scene.physicsWorld.contactDelegate = self
        //        addBox()
        // Show statistics such as fps and timing information
        //        sceneView.showsStatistics = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Create a session configuration
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin] // включаем линии осей и точки определния поверхностей
        // Run the view's session
        
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        self.getLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - ARSCNViewDelegate methods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        
        // если якорь это плоскость
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))// создаем плоскоть размерами с определившиуся поверехность
            
            let planeNode = SCNNode()
            
            planeNode.position = SCNVector3(0, 0, 0)
            
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0) // узел трансформируется  по этому закону
            
            let gridMaterrial = SCNMaterial()
            
            
            gridMaterrial.diffuse.contents = UIColor.green
            plane.materials = [gridMaterrial]
            
            planeNode.geometry = plane
            
            node.addChildNode(planeNode)
            
            node.addChildNode(house(on: plane))
            
            
        } else {
            return
        }
        
        
        
    }
    
    
    
    func house(on plane: SCNPlane) -> SCNNode {
        
        let boxNode = SCNNode(geometry: SCNBox(width: plane.width/3, height: plane.width/3, length: plane.width/3, chamferRadius: 0))
        let roofNode = SCNNode(geometry:SCNPyramid(width: plane.width/3, height: plane.width/6, length: plane.width/3))
        let doorNode = SCNNode(geometry: SCNPlane(width: plane.width/12, height: plane.width/6))
        
        boxNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        roofNode.geometry?.firstMaterial?.specular.contents = UIColor.white
        roofNode.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        doorNode.geometry?.firstMaterial?.specular.contents = UIColor.black
        doorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
        
        boxNode.position = SCNVector3(0, plane.width/6 ,0)
        
        roofNode.position = SCNVector3(0, plane.width/6, 0)
        boxNode.addChildNode(roofNode)
        
        doorNode.position = SCNVector3(0, -plane.width/12, plane.width/6 + 0.01)
        boxNode.addChildNode(doorNode)
        
        return boxNode

    }
    
    // MARK: - Actions
//    @IBAction func add(_ sender: Any) {
//
//        let node = SCNNode()
////        let cylinderNode = SCNNode(geometry: SCNCylinder(radius: 0.05, height: 0.2))
//        let boxNode = SCNNode(geometry: SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0))
//        let doorNode = SCNNode(geometry: SCNPlane(width: 0.05, height: 0.1))
////        node.geometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.03) // если радиус = половине ширины и это куб, то получится сфера
////        node.geometry = SCNCapsule(capRadius: 0.05, height: 0.2)
////        node.geometry = SCNCone(topRadius: 0.05, bottomRadius: 0.1, height: 0.2) // конус(если радиусы равны - цилиндр)
////        node.geometry = SCNCylinder(radius: 0.05, height: 0.2)
////        node.geometry = SCNSphere(radius: 0.1)
////        node.geometry = SCNTube(innerRadius: 0.05, outerRadius: 0.1, height: 0.2)
////        node.geometry = SCNTorus(ringRadius: 0.2, pipeRadius: 0.03)
////       node.geometry = SCNPlane(width: 0.3, height: 0.2)
//        node.geometry  = SCNPyramid(width: 0.2, height: 0.1, length: 0.2)
////        let path = UIBezierPath()
////        path.move(to: CGPoint(x: 0, y:0))
////        path.addLine(to: CGPoint(x: 0, y: 0.2))
////        path.addLine(to: CGPoint(x: 0.2, y: 0.3))
////        path.addLine(to: CGPoint(x: 0.4, y: 0.2))
////        path.addLine(to: CGPoint(x: 0.4, y: 0))
////
////        let shape = SCNShape(path: path, extrusionDepth: 0.05)
////        node.geometry = shape
//        node.geometry?.firstMaterial?.specular.contents = UIColor.white
//        node.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
//        boxNode.geometry?.firstMaterial?.specular.contents = UIColor.white
//        boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
//        doorNode.geometry?.firstMaterial?.specular.contents = UIColor.black
//        doorNode.geometry?.firstMaterial?.diffuse.contents = UIColor.brown
////        let x = randomNumbers(firstNum: -0.3, secondNum: 0.3)
////        let y = randomNumbers(firstNum: -0.3, secondNum: 0.3)
////        let z = randomNumbers(firstNum: -0.3, secondNum: 0.3)
////        node.position = SCNVector3(x,y,z) // случайная позиция в заданном диапазоне
//        boxNode.position = SCNVector3(0,0,-0.5)
//        node.position = SCNVector3(0, 0.1, 0)
//        doorNode.position = SCNVector3(0, -0.05, 0.11)
//        self.sceneView.scene.rootNode.addChildNode(boxNode)
////        self.sceneView.scene.rootNode.addChildNode(cylinderNode) // так он расположен относительно рут ноуд
//
//        boxNode.addChildNode(node) // так он расположениотносительно node
//        boxNode.addChildNode(doorNode)
//
//    }
    
    
    @IBAction func reset(_ sender: Any) {
        self.restartSession()
    }
    
    func restartSession() {// сессия на паузу, удаляем все чайлд узлы и их потомки, запкскаем новую сессию в той позиции где мы находимс яскейчас
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    
//    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {// возвращает случайное число в заданном диапазоне
//        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs( firstNum - secondNum) + min(firstNum, secondNum)
//
//
//    }
    
    
    
    
    
    //===================================
    
    
    // MARK: - add objects
//    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
//        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
//
//
//        let boxNode = SCNNode()
//        boxNode.geometry = box
//        boxNode.position = SCNVector3(0, 0, -0.2)
//
//        //let scene = SCNScene()
//        sceneView.scene.rootNode.addChildNode(boxNode)
//        //sceneView.scene = scene
//    }
    // MARK: - add gesture
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARSceneViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            return
        }
        
        let alert = UIAlertController(title: "Вы нашли объект!", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Показать на карте", style: .default, handler: { (action) in
            
            self.openInMap()
        }))
        
        alert.addAction(UIAlertAction(title: "Сохранить объект", style: .default, handler: { (action) in
            self.savePoint()
            node.removeFromParentNode()

        }))
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }

}
//MARK: -
extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
