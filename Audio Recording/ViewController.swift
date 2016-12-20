//
//  ViewController.swift
//  Audio Recording
//
//  Created by A Dark Matter Creation Linder on 12/19/16.
//  Copyright © 2016 A Dark Matter Creation. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioRecorderDelegate {

    var playList: [String] = []
    var selectedListItem = 0
    var storedFileName = ""
    var recordedFileName: URL? = nil
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var recordingSession: AVAudioSession!
    var isPaused = false
    var pauseTime = 0.00

    let alert = UIAlertView()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var recordButtonOutlet: UIBarButtonItem!

    @IBAction func playButton(_ sender: Any) {
            
            let path = getDocumentsDirectory().appendingPathComponent("StoredFileName\(selectedListItem)")
            
            do {
                
                let sound = try AVAudioPlayer(contentsOf: path)
                audioPlayer = sound
                audioPlayer.play()
                
            } catch {
                
                print("couldnt load")
                
            }
        
    }
    
    @IBAction func pauseButton(_ sender: Any) {
        
        if audioPlayer != nil {


                isPaused = true
                
                audioPlayer.pause()
                
                pauseTime = audioPlayer.currentTime
                
                print(isPaused)
        
        }
    
    }
    
    @IBAction func recordButton(_ sender: Any) {
        
        print("recording")
        
        if audioPlayer != nil{
            
            audioPlayer.stop()
            
        }
        
        if audioRecorder == nil {
            
            recordedFileName = getDocumentsDirectory().appendingPathComponent("StoredFileName\(playList.count)")
            
            let settings = [
                
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                
            ]
            
            do {
                
                audioRecorder = try AVAudioRecorder(url: recordedFileName!, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                
            } catch {
                
                didFinishRecording(success: false)
                
            }
            
        } else {
            
                didFinishRecording(success: true)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                        self.alert.title = "Press record to start "
                        self.alert.addButton(withTitle: "OK")
                        self.alert.show()
                        
                    } else {
                        // failed to record!
                        
                        
                    }
                }
                
            }
            
        } catch {
            
            
            // failed to record!
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if audioPlayer != nil {
            
            audioPlayer.stop()
            
        }
        
        if audioRecorder != nil {
            
            didFinishRecording(success: true)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

        var numberOfRows = playList.count
        
        if numberOfRows == 0 {
            
            numberOfRows = 1
            
        }
        
        return numberOfRows
    }
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        
        if playList.isEmpty {
            
            cell.textLabel?.text = "Please Press Record To Add File"
            
        }else{
            
            cell.textLabel?.text = String(playList[indexPath.row])
            
        }
        
        return cell
        
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            playList.remove(at: indexPath.row)

            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedListItem = indexPath.row
        print(selectedListItem)
        
    }
    
    func getDocumentsDirectory() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        if audioRecorder != nil {
            
            didFinishRecording(success: false)
            
        }
        
    }
    
    func didFinishRecording(success: Bool) {

        if success {
            
            print("recorded")
            audioRecorder.stop()
            audioRecorder = nil
            playList.append("StoredFileName\(playList.count)")
            tableView.reloadData()
            
        } else {
        
            print("Error with recording")
            
        }
        
    }

}

