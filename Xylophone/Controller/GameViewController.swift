//
//  ViewController.swift
//  Xylophone
//
//  Created by Andrew on 24/12/20.
//

import UIKit
import AVFoundation
import CoreData

class GameViewController: UIViewController {

    @IBOutlet weak var cButton: UIButton!
    @IBOutlet weak var dButton: UIButton!
    @IBOutlet weak var eButton: UIButton!
    @IBOutlet weak var fButton: UIButton!
    @IBOutlet weak var gButton: UIButton!
    @IBOutlet weak var aButton: UIButton!
    @IBOutlet weak var bButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var player: AVAudioPlayer?
    let sounds = ["C", "D", "E", "F", "G", "A", "B"]
    var expectedSounds = [String]()
    var currentIndex = 0
    var buttons = [UIButton]()
    var soundToButton = [String:UIButton]()
    var leastKeysPlayed = 1
    var mostKeysPlayed = 2
    var score: Int64 = 0
    var gameMode: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons = [cButton, dButton, eButton, fButton, gButton, aButton, bButton]
        soundToButton = [
            "C": cButton,
            "D": dButton,
            "E": eButton,
            "F": fButton,
            "G": gButton,
            "A": aButton,
            "B": bButton
        ]
        newSetOfKeys()
        // Do any additional setup after loading the view.
    }

    @IBAction func keyPressed(_ sender: UIButton) {
        let sound = sounds[sender.tag]
        playSound(soundName: sound)
        buttonOpaqueOnClickEffect(button: sender, newOpacity: 0.5)
        if sound == expectedSounds[currentIndex] {
            currentIndex += 1
            score += 1
            scoreLabel.text = "Score: \(score)"
        } else {
            createHighScore()
            self.performSegue(withIdentifier: "goToGameOver", sender: self)
        }
        if currentIndex >= expectedSounds.count {
            newSetOfKeys()
        }
    }
    
    func createHighScore(){
        let highScore = HighScore(context: context)
        highScore.name = "Andrew"
        highScore.score = score
        highScore.date = Date()
        try! self.context.save()
    }
    
    func buttonOpaqueOnClickEffect(button: UIButton, newOpacity: CGFloat){
        let oringinalAlpha = button.alpha
        button.alpha = newOpacity
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
              button.alpha = oringinalAlpha
          }
    }
    
    func newSetOfKeys(){
        currentIndex = 0
        setKeysClickable(to: false)
        expectedSounds = generateKeys()
        playKeys(expectedSounds)
        leastKeysPlayed += 1
        mostKeysPlayed += 1
    }
    
    func generateKeys() -> [String] {
        var items = [String]()
        let numKeys = Int.random(in: leastKeysPlayed...mostKeysPlayed)
        for _ in 0...numKeys{
            items.append(sounds.randomElement()!)
        }
        return items
    }
    
    func playKeys(_ keys: [String]){
        var delay: Double = 1.0
        for key in keys{
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.playSound(soundName: key)
                if self.gameMode == GameMode.MEMORY.rawValue {
                    self.buttonOpaqueOnClickEffect(button: self.soundToButton[key]! ,newOpacity: 0.0)
                }
            }
            delay += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.setKeysClickable(to: true)
        }
    }
    
    func setKeysClickable(to isEnabled: Bool){
        for button in buttons {
            button.isEnabled = isEnabled
        }
    }
    
    func playSound(soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)

                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
                guard let player = player else { return }

                player.play()

            } catch let error {
                print(error.localizedDescription)
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToGameOver"{
            let destinationVC = segue.destination as! GameOverViewController
            destinationVC.score = score
        }
    }

}
