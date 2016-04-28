//
//  EmotionDiarySwift.swift
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

import UIKit

class EmotionDiarySwift: NSObject, NSCoding {
    
    var smile: Int
    var attractive: Int
    var imageURL: String
    var date: NSDate
    var content: String
    
    let manager = NSFileManager.defaultManager()
    let IMAGE_PATH = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] + "/Image/"
    
    static let EmotionDiariesSaveKey = "EmotionDiaries"
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    init(smile: Int, attractive: Int, image: UIImage, content: String) {
        self.smile = smile
        self.attractive = attractive
        self.date = NSDate()
        self.content = content
        
        let path = IMAGE_PATH + Utilities.MD5(date.description)
        if !manager.fileExistsAtPath(IMAGE_PATH) {
            do {
                try manager.createDirectoryAtPath(IMAGE_PATH, withIntermediateDirectories: false, attributes: nil)
            }
            catch {
                print("创建目录失败")
            }
        }
        manager.createFileAtPath(path, contents: UIImageJPEGRepresentation(image, 0.5), attributes: nil)
        imageURL = path
    }
    
    required init?(coder aDecoder: NSCoder) {
        smile = aDecoder.decodeObjectForKey("smile") as! Int
        attractive = aDecoder.decodeObjectForKey("attractive") as! Int
        imageURL = aDecoder.decodeObjectForKey("imageURL") as! String
        date = aDecoder.decodeObjectForKey("date") as! NSDate
        content = aDecoder.decodeObjectForKey("content") as! String
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(smile, forKey: "smile")
        aCoder.encodeObject(attractive, forKey: "attractive")
        aCoder.encodeObject(imageURL, forKey: "imageURL")
        aCoder.encodeObject(date, forKey: "date")
        aCoder.encodeObject(content, forKey: "content")
    }
    
    func save() {
        if let emotionDiaries = getEmotionDiariesFromStore() {
            var diaries = emotionDiaries
            diaries.append(self)
            userDefaults.removeObjectForKey(EmotionDiarySwift.EmotionDiariesSaveKey)
            let data = NSKeyedArchiver.archivedDataWithRootObject(diaries)
            userDefaults.setObject(data, forKey: EmotionDiarySwift.EmotionDiariesSaveKey)
            userDefaults.synchronize()
        }
        else {
            let data = NSKeyedArchiver.archivedDataWithRootObject([self])
            userDefaults.setObject(data, forKey: EmotionDiarySwift.EmotionDiariesSaveKey)
            userDefaults.synchronize()
        }
        EmotionDiaryHelper.sharedInstance.refreshEmotionDiariesFromStore()
    }
    
    private func getEmotionDiariesFromStore() -> [EmotionDiarySwift]? {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let data = userDefaults.objectForKey(EmotionDiarySwift.EmotionDiariesSaveKey) as? NSData {
            let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSArray
            var emotionDiaries = [EmotionDiarySwift]()
            for item in array {
                let diary = item as! EmotionDiarySwift
                emotionDiaries.append(diary)
            }
            return emotionDiaries.sort({ (before, after) -> Bool in
                (before.date.timeIntervalSince1970 - after.date.timeIntervalSince1970 > 0)
            })
        }
        else {
            return nil
        }
    }
    
}

private let sharedEmotionDiaryHelper = EmotionDiaryHelper()

class EmotionDiaryHelper: NSObject {
    
    class var sharedInstance: EmotionDiaryHelper {
        return sharedEmotionDiaryHelper
    }
    
    private var storedData: [EmotionDiarySwift]?
    
    func refreshEmotionDiariesFromStore() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let data = userDefaults.objectForKey(EmotionDiarySwift.EmotionDiariesSaveKey) as? NSData {
            let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSArray
            var emotionDiaries = [EmotionDiarySwift]()
            for item in array {
                let diary = item as! EmotionDiarySwift
                emotionDiaries.append(diary)
            }
            storedData = emotionDiaries.sort({ (before, after) -> Bool in
                (before.date.timeIntervalSince1970 - after.date.timeIntervalSince1970 > 0)
            })
        }

    }
    
    private func getEmotionDiariesFromStore() -> [EmotionDiarySwift]? {
        if let data = storedData {
            return data
        }
        else {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if let data = userDefaults.objectForKey(EmotionDiarySwift.EmotionDiariesSaveKey) as? NSData {
                let array = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSArray
                var emotionDiaries = [EmotionDiarySwift]()
                for item in array {
                    let diary = item as! EmotionDiarySwift
                    emotionDiaries.append(diary)
                }
                let diaries = emotionDiaries.sort({ (before, after) -> Bool in
                    (before.date.timeIntervalSince1970 - after.date.timeIntervalSince1970 > 0)
                })
                storedData = diaries
                return diaries
            }
            else {
                return nil
            }
        }
    }
    
    func getDiaryOfDay(date: NSDate) -> [EmotionDiarySwift] {
        
        let thisDay = Int(date.timeIntervalSince1970 / (24 * 3600))
        if let emotionDiaries = getEmotionDiariesFromStore() {
            let thatDayDiary = emotionDiaries.filter { (diary) -> Bool in
                let thatDay = Int(diary.date.timeIntervalSince1970 / (24 * 3600))
                return (thatDay == thisDay)
            }
            return thatDayDiary
        }
        else {
            return []
        }
    }
    
    func getSomeDayAgoSmileness(someday: Int) -> [Double] {
        
        let nowDay = Int(NSDate().timeIntervalSince1970 / (24 * 3600))
        if let emotionDiaries = getEmotionDiariesFromStore() {
            var seedArray = [Int]()
            for index in 0.stride(to: someday, by: 1) {
                seedArray.append(index)
            }
            return seedArray.reverse().map { (dayBack) -> Double in
                var count = 0
                let totalSmile = emotionDiaries.filter({ (diary) -> Bool in
                    let thatDay = Int(diary.date.timeIntervalSince1970) / (24 * 3600)
                    return (nowDay - thatDay == dayBack)
                }).reduce(0, combine: { (smileness, diary) -> Int in
                    count += 1
                    return diary.smile + smileness
                })
                if count > 0 {
                    return Double(totalSmile) / Double(count)
                }
                else {
                    return 0
                }
            }
        }
        else {
            return []
        }
        
    }

    
}
