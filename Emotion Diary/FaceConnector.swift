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
    let verificationURL = "https://v1-api.visioncloudapi.com/face/verification"
    let faceDetailInfoURL = "https://v1-api.visioncloudapi.com/info/face"
    let addFaceURL = "https://v1-api.visioncloudapi.com/person/add_face"
    
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
                        switch response.result {
                        case .Failure( _):
                            block(result: .Error, message: "服务器错误或网络错误", faceID: nil)
                        case .Success(let value):
                            let json = JSON(value)
                            let faceID = json["faces"][0]["face_id"].stringValue
                            block(result: .Success, message: "OK", faceID: faceID)
                        }

                    }
                case .Failure(_):
                    block(result: .Error, message: "无法编码", faceID: nil)
                }
        }
    }

    func createPersonWithName(name: String, faceIDs: [String], andBlock block: (result: FaceConnectorRequestResult, message: String) -> Void) {
        
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
                block(result: .Error, message: "服务器错误或网络错误")
            case .Success(let value):
                let json = JSON(value)
                self.personID = json["person_id"].stringValue
                block(result: .Success, message: "OK")
            }
        }
        
    }
    
    func verificateFaceID(faceID: String, andBlock block: (result: FaceConnectorRequestResult, message: String, isOwner: Bool) -> Void) {
        
        var parameters = ["api_id": api_id,
                          "api_secret": api_secret,
                          "face_id": faceID]
        if let ID = personID {
            parameters["person_id"] = ID
        }
        else {
            block(result: .Error, message: "还没有personID", isOwner: false)
        }
        
        Alamofire.request(.POST, verificationURL, parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .Failure( _):
                block(result: .Error, message: "服务器错误或网络错误", isOwner: false)
            case .Success(let value):
                let json = JSON(value)
                let same_person = json["same_person"].boolValue
                if same_person {
                    block(result: .Success, message: "OK", isOwner: true)
                    self.addFace(faceID)
                }
                else {
                    block(result: .Success, message: "OK", isOwner: false)
                }
            }
        }
        
    }
    
    func getDetailInfoOfFace(faceID: String, block: (result: FaceConnectorRequestResult, message: String, info: [String: Int]?
        ) -> Void) {
        
        let parameters = ["api_id": api_id,
                          "api_secret": api_secret,
                          "face_id": faceID]
        Alamofire.request(.GET, faceDetailInfoURL, parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .Failure( _):
                block(result: .Error, message: "服务器错误或网络错误", info: nil)
            case .Success(let value):
                let json = JSON(value)
                let smile = json["attributes"]["smile"].intValue
                let attractive = json["attributes"]["attractive"].intValue
                let info = ["smile": smile, "attractive": attractive]
                // TODO: to add other info here
                block(result: .Success, message: "OK", info: info)
                
            }

        }
        
    }
    
    private func addFace(faceID: String) {
        
        let parameters = ["api_id": api_id,
                          "api_secret": api_secret,
                          "face_id": faceID,
                          "person_id": personID!]
        
        Alamofire.request(.POST, addFaceURL, parameters: parameters).responseJSON { (response) in
            switch response.result {
            case .Failure( _):
                print("给人添加新脸失败")
            case .Success(let value):
                let json = JSON(value)
                let faceCount = json["face_count"].intValue
                let addedCount = json["added_count"].intValue
                print("现在已有脸数\(faceCount)，新增脸数\(addedCount)")
            }
        }
        
    }
    
}

extension FaceConnector {
    
    var personID: String? {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let personID = userDefaults.objectForKey("personID") as? String
            return personID
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.removeObjectForKey("personID")
            userDefaults.setObject(newValue!, forKey: "personID")
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
