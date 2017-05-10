
import UIKit

class songListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

   
    @IBOutlet weak var songTableView: UITableView!
     var audioList:NSArray!
     var currentAudioIndex = 0
   
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !(UserDefaults.standard.object(forKey: "insert") != nil)
        {
             ModelManager.getInstance().addStudentData()
            UserDefaults.standard.set(true, forKey: "insert")
            
        }
        
        getStudentData()
    }

    func getStudentData()
    {
       
        audioList = NSMutableArray()
        audioList = ModelManager.getInstance().getAllStudentData()
        songTableView.reloadData()
    }
    
    
    
    // Table View Part of the code. Displays Song name and Artist Name
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
       
        let song:songsInfo = audioList.object(at: indexPath.row) as! songsInfo
       
        
        let cell = songTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! songTableViewCell
        
        cell.titleLabel?.text = song.title
        cell.artWork.image = song.imageData
        
        
               
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    
    
    
    func tableView(_ tableView: UITableView,willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath){
        tableView.backgroundColor = UIColor.clear
        
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.backgroundColor = UIColor.clear
        cell.backgroundView = backgroundView
        cell.backgroundColor = UIColor.clear
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
        let vc = storyboard?.instantiateViewController(withIdentifier: "player") as? PlayerViewController
        
        vc?.currentAudioIndex = indexPath.row
        
        present(vc!, animated: true, completion: nil)
        
       
    }
    
  
        

}
