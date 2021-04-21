//
//  ConfigVC.swift
//  MatchEmTab
//
//  Created by Rajan Maharjan on 20/04/2021.
//

import UIKit

class ConfigVC: UIViewController {
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var speedValue: UILabel!
    
    @IBOutlet weak var switchBackground: UILabel!
    @IBOutlet weak var switchRandomTrans: UILabel!
    
    @IBOutlet weak var fadeDurationSlider: UISlider!
    @IBOutlet weak var fadeDurationSliderValue: UILabel!
    
    
    @IBOutlet weak var firstHighestScoreValue: UILabel!
    
    @IBOutlet weak var secondHighestScoreValue: UILabel!
    
    @IBOutlet weak var thirdHighestScoreValue: UILabel!
        
    var sliderValueLabelMessage: String {
        return String(format: "%.2f", speedSlider.value)
    }
    
    var sliderValueFadeLabelMessage: String {
        return String(format: "%.2f", fadeDurationSlider.value)
    }
    
    // Reference to the game scene view controller
    var gameSceneVC: GameSceneViewController?
    
    // Slider min and max
    let sliderMin: Float = 0.0
    let sliderMax: Float = 1.0
    
    //================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up a reference to the game scene
        gameSceneVC = self.tabBarController!.viewControllers![0] as? GameSceneViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up the slider
        let sliderValue = sliderGivenDelay(delay: gameSceneVC!.newRectPairInterval)
        speedSlider.value = sliderValue
        let sliderValueFade = sliderGivenFadeDelay(delay: gameSceneVC!.fadeDuration)
        fadeDurationSlider.value = sliderValueFade
        
        firstHighestScoreValue.text = String(format: "%d", gameSceneVC?.gameManager.firstHighestScore as! CVarArg)
        secondHighestScoreValue.text = String(format: "%d", gameSceneVC?.gameManager.secondHighestScore as! CVarArg)
        thirdHighestScoreValue.text = String(format: "%d", gameSceneVC?.gameManager.thirdHighestScore as! CVarArg)
        
    }
    
    //================================================
    @IBAction func changeSpeed(_ sender: UISlider) {
        // Get the slider's value
        let sliderValue = sender.value
        
        // Get the corresponding delay
        let delay = delayGivenSlider(sliderValue: sliderValue)
        
        // UPDATE THE SPEED IN THE GameSceneVC object
        gameSceneVC?.newRectPairInterval = delay
        
        // Update the slider's value label
        speedValue.text = sliderValueLabelMessage
    }
    
    @IBAction func switchBackground(_ sender: UISwitch) {
        if (sender.isOn == true){
            switchBackground.text = "On"
            gameSceneVC?.view.backgroundColor = .cyan
        }
        else{
            switchBackground.text = "Off"
            gameSceneVC?.view.backgroundColor = .white
        }
    }
    
    @IBAction func switchRandomTrans(_ sender: UISwitch) {
        if (sender.isOn == true){
            switchRandomTrans.text = "On"
            gameSceneVC?.randomAlpha = true
        }
        else{
            switchRandomTrans.text = "Off"
            gameSceneVC?.randomAlpha = false
        }
    }
    
    @IBAction func fadeDurationSlider(_ sender: UISlider) {
        // Get the slider's value
        let sliderValue = sender.value
        // Get the corresponding delay
        let delay = delayGivenFadeSlider(sliderValue: sliderValue)
        
        // UPDATE THE SPEED IN THE GameSceneVC object
        gameSceneVC?.fadeDuration = delay
        
        // Update the slider's value label
        fadeDurationSliderValue.text = sliderValueFadeLabelMessage
    }
    
    //================================================
    func sliderGivenDelay(delay: TimeInterval) -> Float {
        // Get values from the game scene
        let nrMin = Float(gameSceneVC!.newRectIntervalMin)
        let nrMax = Float(gameSceneVC!.newRectIntervalMax)
        
        // The slope
        let m = (nrMax - nrMin) / (sliderMin - sliderMax )
        
        // Cast ...
        let nrInt = Float(delay)
        
        // Function computation
        let sliderValue  = (nrInt - nrMax) / m
        
        // Return the correspoinding slider value
        return sliderValue
    }
    
    //================================================
    func sliderGivenFadeDelay(delay: TimeInterval) -> Float {
        // Get values from the game scene
        let nrMin = Float(gameSceneVC!.newfadeDurMin)
        let nrMax = Float(gameSceneVC!.newfadeDurMax)
        
        // The slope
        let m = (nrMax - nrMin) / (sliderMin - sliderMax )
        
        // Cast ...
        let nrInt = Float(delay)
        
        // Function computation
        let sliderValue  = (nrInt - nrMax) / m
        
        // Return the correspoinding slider value
        return sliderValue
    }
    
    //================================================
    func delayGivenSlider(sliderValue: Float) -> TimeInterval {
        // Get values from the game scene
        let nrMin = Float(gameSceneVC!.newRectIntervalMin)
        let nrMax = Float(gameSceneVC!.newRectIntervalMax)
        
        // The slope
        let m = (nrMax - nrMin) / (sliderMin - sliderMax )
        
        // Function computation - the inverse of delayToSlider
        let nrInt = m * sliderValue + nrMax
        
        // print("\(#function) - \(nrInt)")
        
        // Return the correspoinding delay
        return TimeInterval(nrInt)
    }
    
    //================================================
    func delayGivenFadeSlider(sliderValue: Float) -> TimeInterval {
        // Get values from the game scene
        let nrMin = Float(gameSceneVC!.newfadeDurMin)
        let nrMax = Float(gameSceneVC!.newfadeDurMax)
        
        // The slope
        let m = (nrMax - nrMin) / (sliderMin - sliderMax )
        
        // Function computation - the inverse of delayToSlider
        let nrInt = m * sliderValue + nrMax
        
        // print("\(#function) - \(nrInt)")
        
        // Return the correspoinding delay
        return TimeInterval(nrInt)
    }
    
}
