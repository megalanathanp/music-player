

import UIKit

let sharedInstance = ModelManager()

class ModelManager: NSObject {
    
    var database: FMDatabase? = nil

    class func getInstance() -> ModelManager
    {
        if(sharedInstance.database == nil)
        {
            sharedInstance.database = FMDatabase(path: Util.getPath(fileName: "songsDB.sqlite"))
        }
        return sharedInstance
    }
    
    func addStudentData() {
        sharedInstance.database!.open()
        
        if let bundlePath = Bundle.main.path(forResource: "Saarattu Vandiyila", ofType: "mp3"){
            
            let url = URL(fileURLWithPath: bundlePath)
            var data = Data()
            var imageData = Data()
            data = try! Data(contentsOf: url)
            
            if let img = UIImage(named: "Kaatru Veliyidai.jpg"){
            imageData = UIImagePNGRepresentation(img)!
            }
            
            sharedInstance.database!.executeUpdate("INSERT INTO songsinfo (title, imageData, songData) VALUES (?, ?, ?)", withArgumentsIn: ["Kaatru Veliyidai", imageData, data])
            

        }
        
        
        if let bundlePath = Bundle.main.path(forResource: "Bro", ofType: "mp3"){
            
            let url = URL(fileURLWithPath: bundlePath)
            var data = Data()
            var imageData = Data()
            data = try! Data(contentsOf: url)
            
            if let img = UIImage(named: "Server Sundaram.jpg"){
                imageData = UIImagePNGRepresentation(img)!
            }
            
            sharedInstance.database!.executeUpdate("INSERT INTO songsinfo (title, imageData, songData) VALUES (?, ?, ?)", withArgumentsIn: ["Server Sundaram", imageData, data])
            
            
        }
        
        
        if let bundlePath = Bundle.main.path(forResource: "Adi Vaadi Thimiraa", ofType: "mp3"){
            
            let url = URL(fileURLWithPath: bundlePath)
            var data = Data()
            var imageData = Data()
            data = try! Data(contentsOf: url)
            
            if let img = UIImage(named: "MagalirMattum.jpg"){
                imageData = UIImagePNGRepresentation(img)!
            }
            
            sharedInstance.database!.executeUpdate("INSERT INTO songsinfo (title, imageData, songData) VALUES (?, ?, ?)", withArgumentsIn: ["Magalir Mattum", imageData, data])
            
            
        }
        

        
        sharedInstance.database!.close()
        
    }
   
    func getAllStudentData() -> NSMutableArray {
        sharedInstance.database!.open()
        let resultSet: FMResultSet! = sharedInstance.database!.executeQuery("SELECT * FROM songsinfo", withArgumentsIn: nil)
        let resultSonginfo : NSMutableArray = NSMutableArray()
        if (resultSet != nil) {
            while resultSet.next() {
                let studentInfo : songsInfo = songsInfo()
                
                studentInfo.title = resultSet.string(forColumn: "title")
                studentInfo.imageData = UIImage(data: resultSet.data(forColumn: "imageData"))!
                studentInfo.songData = NSData(data: resultSet.data(forColumn: "songData"))
                 resultSonginfo.add(studentInfo)
                
            }
        }
        sharedInstance.database!.close()
        return resultSonginfo
    }
}
