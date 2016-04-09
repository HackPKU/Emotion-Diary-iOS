//
//  FaceConnector.swift
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

import UIKit
import Alamofire

class FaceConnector: NSObject {
    
    let detectionURL = "https://v1-api.visioncloudapi.com/face/detection"
    let createPersonURL = "https://v1-api.visioncloudapi.com/person/create"
    let api_id = "8787dcbe92344652902ab319bbbb8e80"
    let api_secret = "c11e8b064d3f481681d250439e517a8e"
    let landmarks106 = "1"
    let attributes = "1"
    
    func scanAndAnalyzeFace(image: UIImage, andBlock block:(result: FaceConnectorRequestResult, message: String, data: Int) -> Void) {
        
    }
    
    func postImage(image: UIImage, block: (result: FaceConnectorRequestResult, message: String, faceID: String?) -> Void) {
        
        let imgPath = NSString(string: NSTemporaryDirectory()).stringByAppendingPathComponent("0.jpeg")
        let data = UIImageJPEGRepresentation(image, 0.5)!
        data.writeToFile(imgPath, atomically: true)
        Alamofire.upload(.POST, detectionURL, multipartFormData: { (multipartFormData) in
            //multipartFormData.appendBodyPart(fileURL: NSURL(string: imgPath)!, name: "file")
            multipartFormData.appendBodyPart(data: data, name: "file", fileName: "image.jpg", mimeType: "image/jpeg")
            multipartFormData.appendBodyPart(data: self.api_id.dataUsingEncoding(NSUTF8StringEncoding)!, name: "api_id")
            multipartFormData.appendBodyPart(data: self.api_secret.dataUsingEncoding(NSUTF8StringEncoding)!, name: "api_secret")
            multipartFormData.appendBodyPart(data: self.landmarks106.dataUsingEncoding(NSUTF8StringEncoding)!, name: "landmarks106")
            multipartFormData.appendBodyPart(data: self.attributes.dataUsingEncoding(NSUTF8StringEncoding)!, name: "attributes")
            }) { (encodingResult) in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        switch response.result {
                        case .Failure( _):
                            block(result: .Error, message: "服务器错误或网络错误", faceID: nil)
                        case .Success(let value):
                            let json = JSON(value)
                            let faceID = json["faces"][0]["face_id"].stringValue
                            block(result: .Success, message: "OK", faceID: faceID)
                        }

                    }
                case .Failure(let encodingError):
                    print(encodingError)
                    block(result: .Error, message: "无法编码", faceID: nil)
                }
        }
    }

    func createPersonWithName(name: String, faceIDs: [String], andBlock block: (result: FaceConnectorRequestResult, message: String, personID: String?) -> Void) {
        
        var parameters = ["api_id": api_id,
                          "api_secret": api_secret,
                          "name": name]
        var faces = faceIDs[0]
        for index in 1.stride(to: faceIDs.count, by: 1) {
            faces += ","
            faces += faceIDs[index]
        }
        parameters["face_id"] = faces
        
        Alamofire.request(.POST, createPersonURL, parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .Failure( _):
                block(result: .Error, message: "服务器错误或网络错误", personID: nil)
            case .Success(let value):
                let json = JSON(value)
                let personID = json["person_ID"].stringValue
                block(result: .Success, message: "OK", personID: personID)
            }
        }
        
    }
    
}

@objc enum FaceConnectorRequestResult: Int, CustomStringConvertible {
    
    case Success
    case Error
    
    var description: String {
        switch self {
        case .Success:
            return "Success"
        case .Error:
            return "Error"
        }
    }
}
