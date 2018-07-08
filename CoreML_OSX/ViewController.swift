    //
    //  ViewController.swift
    //  CoreML_OSX
    //
    //  Created by OobaHiroya on 2018/07/06.
    //  Copyright © 2018 Hiroya. All rights reserved.
    //
    
    import Cocoa
    import CoreML
    import Vision
    
    class ViewController: NSViewController {
        
        @IBOutlet weak var imageView: NSImageView!
        @IBOutlet weak var textField: NSTextField!
        
        var index = 0
        let max = 2
        
        // 機械学習の結果のスコアバッファ
        var myIdentifier: String = ""
        var myConfidence: Float = 0.0
        var myElapsed: Double = 0.0
        var myDocumentPath: String = "/Users/oobahiroya/Library/Containers/Hiroya.CoreML-OSX/Data/Documents/"
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Do any additional setup after loading the view.
//            let documentDirPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
//            print(documentDirPath)
//            myDocument = documentDirPath + "/"
            
            UpdateScene()
        }
        
        override var representedObject: Any? {
            didSet {
                // Update the view, if already loaded.
            }
        }
        
        // ボタンを押した時のアクション
        @IBAction func changeAction(_ sender: Any) {
            UpdateScene()
        }
        
        
        func UpdateScene() {
            let imageName = String(format: "%d", index)
//            if let image = NSImage(named: imageName) {
            if let image = NSImage(contentsOfFile: myDocumentPath + imageName + ".jpeg") {
                imageView.image = image
                coreMLRequest(image: image)
                textField.stringValue = "identifier = \(myIdentifier)\nconfidence = \(myConfidence)\nelapsed = \(myElapsed)"
            }
            index += 1
            if (max <= index) {
                index = 0
            }
        }
        
        
        // 画像認識する関数
        func coreMLRequest(image:NSImage) {
            // 処理時間計測
            let t = Double(time(nil))
            
            // CoreModelをインポート
            guard let model = try? VNCoreMLModel(for: ImageClassifier().model) else {//Inceptionv3 VGG16 SqueezeNet GoogLeNetPlaces
                fatalError("faild create VMCoreMLModel")
            }
            
            // convert NSImage to CIImage
            let nsImage = image
            var nsImageRect: CGRect = CGRect(x: 0, y: 0, width: nsImage.size.width, height: nsImage.size.height)
            if let cgImage = nsImage.cgImage(forProposedRect: &nsImageRect, context: nil, hints: nil) {
                let ciImage = CIImage(cgImage: cgImage)
                
                
                let request = VNCoreMLRequest(model: model) { request, error in
                    
                    guard let results = request.results as? [VNClassificationObservation] else {
                        fatalError("Error faild results")
                    }
                    let elapsed = Double(time(nil)) - t
                    if let classification = results.first {
                        print("identifier = \(classification.identifier)")
                        print("confidence = \(classification.confidence)")
                        print("elapsed = \(elapsed)")
                        
                        self.myIdentifier = classification.identifier
                        self.myConfidence = classification.confidence
                        self.myElapsed = elapsed
                        
                    } else {
                        print("error")
                    }
                }
                
                let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
                guard (try? handler.perform([request])) != nil else {
                    fatalError("faild handler.perform")
                }
            }
        }
        
    }
    
