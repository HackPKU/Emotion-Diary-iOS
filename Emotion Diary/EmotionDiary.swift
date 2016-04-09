//
//  EmotionDiary.swift
//  Emotion Diary
//
//  Created by 范志康 on 16/4/9.
//  Copyright © 2016年 范志康. All rights reserved.
//

import UIKit

class EmotionDiary: NSObject, NSCoding {
    
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
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .FullStyle
        formatter.dateStyle = .FullStyle
        let path = IMAGE_PATH + "\(formatter.stringFromDate(date).hash)"
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
        if var emotionDiaries = userDefaults.objectForKey(EmotionDiary.EmotionDiariesSaveKey) as? [EmotionDiary] {
            emotionDiaries.append(self)
            userDefaults.removeObjectForKey(EmotionDiary.EmotionDiariesSaveKey)
            let data = NSKeyedArchiver.archivedDataWithRootObject(emotionDiaries)
            userDefaults.setObject(data, forKey: EmotionDiary.EmotionDiariesSaveKey)
        }
        else {
            let data = NSKeyedArchiver.archivedDataWithRootObject([self])
            userDefaults.setObject(data, forKey: EmotionDiary.EmotionDiariesSaveKey)
        }
    
    }
    
    class func getDiaryOfDay(date: NSDate) -> [EmotionDiary] {
        
        let thisDay = date.timeIntervalSince1970 / (24 * 3600)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let data = userDefaults.objectForKey(EmotionDiary.EmotionDiariesSaveKey) as! NSData
        let emotionDiaries = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [EmotionDiary] ?? []
        let thatDayDiary = emotionDiaries.filter { (diary) -> Bool in
            let thatDay = diary.date.timeIntervalSince1970 / (24 * 3600)
            return (thatDay == thisDay)
        }
        return thatDayDiary
        
    }

}
