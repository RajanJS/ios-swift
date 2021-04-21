//
//  ViewController.swift
//  MatchEmScene
//
//  Created by Rajan Maharjan on 27/03/2021.
//

import UIKit

class GameSceneViewController: UIViewController {
    
    // MARK: - ==== Config Properties ====
    //================================================
    // Min and max width and height for the rectangles
    private let rectSizeMin:CGFloat =  50.0
    private let rectSizeMax:CGFloat = 150.0
    
    // Random transparency on or off
    private var randomAlpha = true
    
    // Rectangle creation interval
    private var newRectPairInterval: TimeInterval = 1.5
    
    // Game duration
    private var gameDuration: TimeInterval = 12
    
    // How long for the rectangle to fade away
    private var fadeDuration: TimeInterval = 0.8
    
    
    // MARK: - ==== Internal Properties ====
    
    @IBOutlet weak var gameInfoLabel: UILabel!
    
    @IBOutlet weak var gameStatusLabel: UILabel!
    
    // Keep track of all rectangle pairs
    var rectanglePairsDic: [UIButton: UIButton] = [:]
    var firstTouch: UIButton?
    var secondTouch: UIButton?
    
    // Rectangle creation, so the timer can be stopped
    private var newRectPairTimer: Timer?
    
    // Game timer
    private var gameTimer: Timer?
    
    // Counters, property observers used
    private var rectanglePairsCreated: Int = 0 {
        didSet { gameInfoLabel?.text = gameInfo } }
    private var rectanglePairsTouched: Int = 0 {
        didSet { gameInfoLabel?.text = gameInfo } }
    
    // A game is in progress
    private var gameInProgress = false
    
    private var gameInfo: String {
        let labelText = String(format: "| Time: %2.1f  |  Pairs: %2d  |  Matches%2d |",
                               gameTimeRemaining, rectanglePairsCreated, rectanglePairsTouched)
        return labelText
    }
    
    private var gameStatus: String {
        let labelText = String(format: "Game Over!!!")
        return labelText
    }
    
    // Init the time remaining
    private lazy var  gameTimeRemaining = gameDuration {
        didSet {
            gameInfoLabel?.text = gameInfo
        }
    }
    
    // MARK: - ==== View Controller Methods ====
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //================================================
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //================================================
    override func viewWillAppear(_ animated: Bool) {
        // Don't forget the call to super in these methods
        super.viewWillAppear(animated)
        
        // Create a single rectangle
        startGameRunning()
    }
    
    //================================================
    @objc private func handleTouch(sender: UIButton) {
        
        if !gameInProgress{
            return
        }
        
        // Add emoji text to the rectangle
        sender.setTitle("🐶", for: .normal)
        
        if((firstTouch) != nil){
            // ==== Handle Second touch ======
            sender.setTitle("🐶", for: .normal)
            secondTouch = sender
        }else{
            // ==== Handle First touch ======
            firstTouch = sender
        }
        
        if((firstTouch != nil) && (secondTouch != nil)){
            // ====== Matches:=======
            if(
                (rectanglePairsDic[firstTouch!] === secondTouch) || (rectanglePairsDic[secondTouch!] === firstTouch)
            ){
                rectanglePairsTouched = rectanglePairsTouched + 1
                // Remove the rectangle
                removeRectangle(rectangle: firstTouch!)
                removeRectangle(rectangle: secondTouch!)
                
                // Reset the touch states
                firstTouch = nil
                secondTouch = nil
            }else{
                // ====== Doesn't Match:=======

                // Remove all the hightlight
                sender.setTitle("", for: .normal)
                firstTouch?.setTitle("", for: .normal)
                secondTouch?.setTitle("", for: .normal)

                // Reset the touch states
                firstTouch = nil
                secondTouch = nil
            }
        }
    }
}

// MARK: - ==== Rectangle Methods ====
extension GameSceneViewController {
    //================================================
    private func createRectangle(randSize: CGSize,  randLoc: CGPoint, randColor: UIColor ) ->  UIButton {
        
        let randomFrame  = CGRect(origin: randLoc, size: randSize)
        
        // Create a rectangle
        let rectangle = UIButton(frame: randomFrame)
        
        // Save the rectangle till the game is over
        // rectangles.append(rectangle)
        
        // Target/action to set up connect of button to the VC
        rectangle.addTarget(self,
                            action: #selector(self.handleTouch(sender:)),
                            for: .touchUpInside)
        
        // Do some button/rectangle setup
        rectangle.backgroundColor = randColor
        rectangle.setTitle("", for: .normal)
        rectangle.setTitleColor(.black, for: .normal)
        rectangle.titleLabel?.font = .systemFont(ofSize: 50)
        rectangle.showsTouchWhenHighlighted = true
        
        
        // Make the rectangle visible
        self.view.addSubview(rectangle)
        view.bringSubviewToFront(gameInfoLabel!)
        view.bringSubviewToFront(gameStatusLabel!)
        
        return rectangle
    }
    
    private func createRectanglePairs() {
        
        // Get random values for size and location
        let rSize     = Utility.getRandomSize(fromMin: rectSizeMin, throughMax: rectSizeMax)
        let rLKey = Utility.getRandomLocation(size: rSize, screenSize: view.bounds.size)
        let rLValue = Utility.getRandomLocation(size: rSize, screenSize: view.bounds.size)
        let rColor = Utility.getRandomColor(randomAlpha: randomAlpha);
        
        let recKey = createRectangle(randSize: rSize, randLoc: rLKey, randColor: rColor);
        let recValue = createRectangle(randSize: rSize, randLoc: rLValue, randColor:rColor );
        
        rectanglePairsCreated = rectanglePairsCreated + 1
        
        rectanglePairsDic[recKey] = recValue;
        
        // Decrement the game time remaining
        gameTimeRemaining -= newRectPairInterval
    }
    
    //================================================
    func removeRectangle(rectangle: UIButton) {
        // Rectangle fade animation
        let pa = UIViewPropertyAnimator(duration: fadeDuration,
                                        curve: .linear,
                                        animations: nil)
        pa.addAnimations {
            rectangle.alpha = 0.0
        }
        pa.startAnimation()
    }
    
    //================================================
    func removeSavedRectangles() {
        // Remove all rectangles from superview
         for (rectangle1, rectangle2) in rectanglePairsDic {
            removeRectangle(rectangle: rectangle1)
            removeRectangle(rectangle: rectangle2)
         }
        
        // Clear the rectangles array
         rectanglePairsDic.removeAll()
    }
    
}

// MARK: - ==== Timer Functions ====
extension GameSceneViewController {
    //================================================
    private func startGameRunning()
    {
        
        // Init label colors
        gameInfoLabel.textColor = .black
        gameInfoLabel.backgroundColor = .clear
        gameStatusLabel?.text = ""
        
        //
        removeSavedRectangles()
        
        // Timer to produce the rectangles
        newRectPairTimer = Timer.scheduledTimer(withTimeInterval: newRectPairInterval,
                                                repeats: true)
            { _ in self.createRectanglePairs() }
        
        // Timer to end the game
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameDuration,
                                         repeats: false)
            { _ in self.stopGameRunning() }
        
        // Update the game status to progress
        gameInProgress = true
        
    }
    
    //================================================
    private func stopGameRunning() {
        
        // Stop the timer
        if let timer = newRectPairTimer { timer.invalidate() }
        
        // Remove the reference to the timer object
        self.newRectPairTimer = nil
        
        // Update the game status to stopped
        gameInProgress = false
        
        // End of game, no time left, make sure label is updated
        gameTimeRemaining = 0.0
        gameInfoLabel?.text = gameInfo
        gameStatusLabel?.text = gameStatus
        
        // Make the label stand out
        gameInfoLabel.textColor = .red
        gameInfoLabel.backgroundColor = .black
    }
    
}
