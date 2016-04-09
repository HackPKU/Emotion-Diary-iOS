//
//  FaceConnector.swift
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

import UIKit

class FaceConnector: NSObject {
    func scanAndAnalyzeFace(image: UIImage, andBlock block:(result: FaceConnectorRequestResult, message: String, data: Int) -> Void) {
        
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
