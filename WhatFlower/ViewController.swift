//
//  ViewController.swift
//  WhatFlower
//
//  Created by admin on 01.10.2022.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage



class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    let imagePicker = UIImagePickerController()
    let wikipediaURL = "https://en.wikipedia.org/w/api.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //label.text = "FlowerDescription"
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
           
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to ciImage")
            }
            
            detect(image: ciImage)
            
            
            
        }
        imagePicker.dismiss(animated: true)
    }
    
    
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true)
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: MobileNet().model) else {
            fatalError("Cant upload model coreml")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let classification = request.results as? [VNClassificationObservation] else {
                fatalError("Dont fetch request")
            }
            
                  
            if let firstResult = classification.first {
               
                
                self.navigationItem.title = String(firstResult.identifier.capitalized+" \(firstResult.confidence)")
                self.navigationController?.navigationBar.backgroundColor = .gray
                
                self.requestInfo(flowerName: firstResult.identifier)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Eroor during performing handler")
        }
        
        
    }
    
    func requestInfo(flowerName: String) {
        
        let parameters : [String:String] = [
        
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
        
        ]
        
        
        
        
        Alamofire.request(wikipediaURL, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Got wikipedia info.")
                print(response)
                
                let flowerJSON : JSON = JSON(response.result.value!)
                
                let pageID = flowerJSON["query"]["pageids"][0].stringValue
                
                let flowerDescription = flowerJSON["query"]["pages"][pageID]["extract"].stringValue
                //print(flowerDescription)
                let flowerImageURL = flowerJSON["query"]["pages"][pageID]["thumbnail"]["source"].stringValue
                
                self.imageView.sd_setImage(with: URL(string: flowerImageURL))
                
                self.label.text = flowerDescription
                
            }
        }
    }
    
}

