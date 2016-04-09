//
//  Emotion_DiaryTests.swift
//  Emotion DiaryTests
//
//  Created by 陈乐天 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

import XCTest

class Emotion_DiaryTests: XCTestCase {
    
    var connector = FaceConnector()
    
    func testPostImage() {
        connector.postImage(UIImage(named: "llc")!) { (result, message) in
            XCTAssert(result == FaceConnectorRequestResult.Success)
            CFRunLoopStop(CFRunLoopGetCurrent())
        }
        CFRunLoopRun()
    }
    
}
