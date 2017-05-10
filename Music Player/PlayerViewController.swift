
import UIKit
import AVFoundation
import MediaPlayer


extension UIImageView {
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}





class PlayerViewController: UIViewController,AVAudioPlayerDelegate {
    
   
    let selectedBackground = 1
    
    
    var audioPlayer:AVAudioPlayer! = nil
    var currentAudio: NSData = NSData()
    var currentAudioPath: NSData!
    var audioList:NSArray!
    var currentAudioIndex = 0
    var timer:Timer!
    var audioLength = 0.0
    var toggle = true
   
    var totalLengthOfAudio = ""
    var finalImage:UIImage!
   
    var shuffleState = false
    var repeatState = false
    var shuffleArray = [Int]()
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet var songNo : UILabel!
    @IBOutlet var lineView : UIView!
    @IBOutlet weak var albumArtworkImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
   
  
    @IBOutlet var songNameLabelPlaceHolder : UILabel!
    @IBOutlet var progressTimerLabel : UILabel!
    @IBOutlet var playerProgressSlider : UISlider!
    @IBOutlet var totalLengthOfAudioLabel : UILabel!
    @IBOutlet var previousButton : UIButton!
    @IBOutlet var playButton : UIButton!
    @IBOutlet var nextButton : UIButton!
    @IBOutlet var listButton : UIButton!
    @IBOutlet var tableView : UITableView!
    @IBOutlet var blurImageView : UIImageView!
    @IBOutlet var enhancer : UIView!
    @IBOutlet var tableViewContainer : UIView!
    
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
   
    func showMediaInfo(){
        let artistName = readArtistNameFromSqlite(currentAudioIndex)
        let songName = readSongNameFromSqlite(currentAudioIndex)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyArtist : artistName,  MPMediaItemPropertyTitle : songName]
    }
    
    
 
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        backgroundImageView.image = UIImage(named: "background1")
        
        prepareAudio()
        updateLabels()
        assingSliderUI()
        setRepeatAndShuffle()
       


    }

    
    func setRepeatAndShuffle(){
        shuffleState = UserDefaults.standard.bool(forKey: "shuffleState")
        repeatState = UserDefaults.standard.bool(forKey: "repeatState")
        if shuffleState == true {
            shuffleButton.isSelected = true
        } else {
            shuffleButton.isSelected = false
        }
        
        if repeatState == true {
            repeatButton.isSelected = true
        }else{
            repeatButton.isSelected = false
        }
    
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        blurView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer.stop()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        albumArtworkImageView.setRounded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
   
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        if flag == true {
            
            if shuffleState == false && repeatState == false {
                
                playButton.setImage( UIImage(named: "play"), for: UIControlState())
                return
            
            } else if shuffleState == false && repeatState == true {
            
                prepareAudio()
                playAudio()
            
            } else if shuffleState == true && repeatState == false {
            
               shuffleArray.append(currentAudioIndex)
                if shuffleArray.count >= audioList.count {
                playButton.setImage( UIImage(named: "play"), for: UIControlState())
                return
                
                }
                
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    randomIndex =  Int(arc4random_uniform(UInt32(audioList.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    }else{
                        newIndex = true
                    }
                }
                currentAudioIndex = randomIndex
                prepareAudio()
                playAudio()
            
            } else if shuffleState == true && repeatState == true {
               
                shuffleArray.append(currentAudioIndex)
                if shuffleArray.count >= audioList.count {
                    shuffleArray.removeAll()
                }
                
                
                var randomIndex = 0
                var newIndex = false
                while newIndex == false {
                    randomIndex =  Int(arc4random_uniform(UInt32(audioList.count)))
                    if shuffleArray.contains(randomIndex) {
                        newIndex = false
                    }else{
                        newIndex = true
                    }
                }
                currentAudioIndex = randomIndex
                prepareAudio()
                playAudio()
                
            
            }
            
        }
    }
    
    
    
    func setCurrentAudioPath(){
        currentAudio = readSongNameFromSqlite(currentAudioIndex)
        currentAudioPath = currentAudio
        print("\(currentAudioPath)")
    }
    
    
    
    // Prepare audio for playing
    func prepareAudio(){
        setCurrentAudioPath()
        do {
            //keep alive audio at background
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch _ {
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        audioPlayer = try? AVAudioPlayer(data: currentAudioPath as Data)
        audioPlayer.delegate = self
        audioLength = audioPlayer.duration
        playerProgressSlider.maximumValue = CFloat(audioPlayer.duration)
        playerProgressSlider.minimumValue = 0.0
        playerProgressSlider.value = 0.0
        audioPlayer.prepareToPlay()
        showTotalSongLength()
        updateLabels()
        progressTimerLabel.text = "00:00"
        
        
    }
    
    //MARK:- Player Controls Methods
    func  playAudio(){
        audioPlayer.play()
        startTimer()
        updateLabels()
       
        showMediaInfo()
    }
    
    func playNextAudio(){
        
        if shuffleState == true {
            
            shuffleArray.append(currentAudioIndex)
            if shuffleArray.count >= audioList.count {
                shuffleArray.removeAll()
            }
            
            
            var randomIndex = 0
            var newIndex = false
            while newIndex == false {
                randomIndex =  Int(arc4random_uniform(UInt32(audioList.count)))
                if shuffleArray.contains(randomIndex) {
                    newIndex = false
                }else{
                    newIndex = true
                }
            }
            currentAudioIndex = randomIndex
           
            
            
        }
        else{
            
            currentAudioIndex += 1
            if currentAudioIndex>audioList.count-1{
                currentAudioIndex -= 1
                
                return
            }

            
        }
        
        
        
        
        
        
        
               if audioPlayer.isPlaying{
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
        }
        
    }
    
    
    func playPreviousAudio(){
        
        if shuffleState == true {
           
            shuffleArray.append(currentAudioIndex)
            if shuffleArray.count >= audioList.count {
                shuffleArray.removeAll()
            }
            
            
            var randomIndex = 0
            var newIndex = false
            while newIndex == false {
                randomIndex =  Int(arc4random_uniform(UInt32(audioList.count)))
                if shuffleArray.contains(randomIndex) {
                    newIndex = false
                }else{
                    newIndex = true
                }
            }
            currentAudioIndex = randomIndex
            
            
            
        }else{
            
            currentAudioIndex -= 1
            if currentAudioIndex<0{
                currentAudioIndex += 1
                return
            }
        }
        
       
        if audioPlayer.isPlaying{
            prepareAudio()
            playAudio()
        }else{
            prepareAudio()
        }
        
    }
    
    
    func stopAudiplayer(){
        audioPlayer.stop();
        
    }
    
    func pauseAudioPlayer(){
        audioPlayer.pause()
        
    }
    
    
    //MARK:-
    
    func startTimer(){
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(PlayerViewController.update(_:)), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    
    func stopTimer(){
        timer.invalidate()
        
    }
    
    
    func update(_ timer: Timer){
        if !audioPlayer.isPlaying{
            return
        }
        let time = calculateTimeFromNSTimeInterval(audioPlayer.currentTime)
        progressTimerLabel.text  = "\(time.minute):\(time.second)"
        playerProgressSlider.value = CFloat(audioPlayer.currentTime)
        UserDefaults.standard.set(playerProgressSlider.value , forKey: "playerProgressSliderValue")

        
    }
    
    
    //This returns song length
    func calculateTimeFromNSTimeInterval(_ duration:TimeInterval) ->(minute:String, second:String){
       // let hour_   = abs(Int(duration)/3600)
        let minute_ = abs(Int((duration/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(duration.truncatingRemainder(dividingBy: 60)))
        
       // var hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }
    

    
    func showTotalSongLength(){
        calculateSongLength()
        totalLengthOfAudioLabel.text = totalLengthOfAudio
    }
    
    
    func calculateSongLength(){
        let time = calculateTimeFromNSTimeInterval(audioLength)
        totalLengthOfAudio = "\(time.minute):\(time.second)"
    }
    
    
   
    func readFromSqlite(){

        audioList = NSMutableArray()
        audioList = ModelManager.getInstance().getAllStudentData()

    }
    
    func readArtistNameFromSqlite(_ indexNumber: Int) -> String {
        readFromSqlite()
        let songproperties:songsInfo = audioList.object(at: indexNumber) as! songsInfo
        let artistName = songproperties.title
        return artistName
    }
    
   
    
    func readSongNameFromSqlite(_ indexNumber: Int) -> NSData {
        readFromSqlite()
        
        let songproperties:songsInfo = audioList.object(at: indexNumber) as! songsInfo
        let songData = songproperties.songData
        return songData
    }
    
    func readArtworkNameFromSqlite(_ indexNumber: Int) -> UIImage {
        readFromSqlite()
        
        let songproperties:songsInfo = audioList.object(at: indexNumber) as! songsInfo
        let artworkImage = songproperties.imageData
        return artworkImage
    }

    
    func updateLabels(){
        updateArtistNameLabel()
        updateAlbumArtwork()

        
    }
    
    
    func updateArtistNameLabel(){
        let artistName = readArtistNameFromSqlite(currentAudioIndex)
        artistNameLabel.text = artistName
    }
   
    
    func updateAlbumArtwork(){
        let artworkImage = readArtworkNameFromSqlite(currentAudioIndex)
        albumArtworkImageView.image = artworkImage
    }
    
    
    func assingSliderUI () {
        let minImage = UIImage(named: "slider-track-fill")
        let maxImage = UIImage(named: "slider-track")
        let thumb = UIImage(named: "thumb")

        playerProgressSlider.setMinimumTrackImage(minImage, for: UIControlState())
        playerProgressSlider.setMaximumTrackImage(maxImage, for: UIControlState())
        playerProgressSlider.setThumbImage(thumb, for: UIControlState())

    
    }
    
    
    
    @IBAction func play(_ sender : AnyObject) {
        
        if shuffleState == true {
            shuffleArray.removeAll()
        }
        let play = UIImage(named: "play")
        let pause = UIImage(named: "pause")
        if audioPlayer.isPlaying{
            pauseAudioPlayer()
            audioPlayer.isPlaying ? "\(playButton.setImage( pause, for: UIControlState()))" : "\(playButton.setImage(play , for: UIControlState()))"
            
        }else{
            playAudio()
            audioPlayer.isPlaying ? "\(playButton.setImage( pause, for: UIControlState()))" : "\(playButton.setImage(play , for: UIControlState()))"
        }
    }
    
    
    
    @IBAction func next(_ sender : AnyObject) {
        playNextAudio()
    }
    
    
    @IBAction func previous(_ sender : AnyObject) {
        playPreviousAudio()
    }
    
    
    
    
    @IBAction func changeAudioLocationSlider(_ sender : UISlider) {
        audioPlayer.currentTime = TimeInterval(sender.value)
        
    }
    
    
  
    
    
    @IBAction func shuffleButtonTapped(_ sender: UIButton) {
        shuffleArray.removeAll()
        if sender.isSelected == true {
        sender.isSelected = false
        shuffleState = false
        UserDefaults.standard.set(false, forKey: "shuffleState")
        } else {
        sender.isSelected = true
        shuffleState = true
        UserDefaults.standard.set(true, forKey: "shuffleState")
        }
        
        
        
    }
    
    
    @IBAction func repeatButtonTapped(_ sender: UIButton) {
        if sender.isSelected == true {
            sender.isSelected = false
            repeatState = false
            UserDefaults.standard.set(false, forKey: "repeatState")
        } else {
            sender.isSelected = true
            repeatState = true
            UserDefaults.standard.set(true, forKey: "repeatState")
        }

        
    }
    
    
    
    
    @IBAction func presentListTableView(_ sender : AnyObject) {
       let vc = storyboard?.instantiateViewController(withIdentifier: "songs") as? songListViewController
        present(vc!, animated: true, completion: nil)
    }
    
    
    
    
    
    
}
