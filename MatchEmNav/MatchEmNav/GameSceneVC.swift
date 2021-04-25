//
//  ViewController.swift
//  MatchEmNav
//
//  Created by Rajan Maharjan on 25/04/2021.
//

import UIKit

class GameSceneVC: UIViewController {
    enum GameState {
        case gameRunning
        case gamePaused
        case noGame
    }
    
    var gameManager = GameManager()
    
    // MARK: - ==== Config Properties ====
    //================================================
    // Min and max width and height for the rectangles
    private let rectSizeMin:CGFloat =  50.0
    private let rectSizeMax:CGFloat = 150.0
  
    
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
    
    // Game status
    private var gameState = GameState.noGame
    
    // Counters, property observers used
    private var rectanglePairsCreated: Int = 0 {
        didSet { gameInfoLabel?.text = gameInfo } }
    private var rectanglePairsTouched: Int = 0 {
        didSet { gameInfoLabel?.text = gameInfo } }
    
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
    private lazy var  gameTimeRemaining = gameManager.gameDuration {
        didSet {
            gameInfoLabel?.text = gameInfo
        }
    }
    
    // MARK: - ==== View Controller Methods ====
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        // self.navigationController?.delegate = self
        // Create a single rectangle
        // resumeGameRunning()
    }
    
    //================================================
    override func viewWillAppear(_ animated: Bool) {
        // Don't forget the call to super in these methods
        super.viewWillAppear(animated)
        view.backgroundColor = gameManager.isSwitchBackgroundOn ? .cyan : .white
        // Do nothing if there isn't a game in progress
        if gameState == .noGame {
            return
        }
        
       
        resumeGameRunning()
    }
    
    //================================================
    override func viewWillDisappear(_ animated: Bool) {
        // Don't forget the call to super in these methods
        super.viewWillDisappear(animated)
        
        // Do nothing if there isn't a game in progress
        if gameState == .noGame {
            return
        }
        
        // Pause
        pauseGameRunning()
    }
    
    // MARK: - ==== Navigation ====
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ConfigVC
        dest.gameManager = self.gameManager
    }
    
    //================================================
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //================================================
    @objc private func handleTouch(sender: UIButton) {
        
        if gameState == .gamePaused || gameState == .noGame {
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
                rectanglePairsTouched += 1
                // calculateHighestScore(score: rectanglePairsTouched)

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
    
    @IBAction func pauseOrResumeOrNewGame(_ sender: UITapGestureRecognizer) {
        // Only start a new game if no game is going on
        if gameState == .noGame {
            // Start a new game
            startNewGame()
            
            // Done here
            return
        }
        
        // If here there is a game in progress
        if gameState == .gameRunning {
            pauseGameRunning()
        }
        else {
            resumeGameRunning()
        }
    }
    
}

// MARK: - ==== Rectangle Methods ====
extension GameSceneVC {
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
        let rColor = Utility.getRandomColor(randomAlpha: gameManager.randomAlpha);
        
        let recKey = createRectangle(randSize: rSize, randLoc: rLKey, randColor: rColor);
        let recValue = createRectangle(randSize: rSize, randLoc: rLValue, randColor:rColor );
        
        rectanglePairsCreated += 1
        
        rectanglePairsDic[recKey] = recValue;
        
        // Decrement the game time remaining
        gameTimeRemaining -= gameManager.newRectPairInterval
    }
    
    //================================================
    func removeRectangle(rectangle: UIButton) {
        // Rectangle fade animation
        let pa = UIViewPropertyAnimator(duration: gameManager.fadeDuration,
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
        for (keyRec, valueRec) in rectanglePairsDic {
            keyRec.removeFromSuperview()
            valueRec.removeFromSuperview()
        }
        
        // Clear the rectangles array
        rectanglePairsDic.removeAll()
    }
    
}

// MARK: - ==== Timer Functions ====
extension GameSceneVC {
    
    //================================================
    private func resumeGameRunning()
    {
        
        // Indicate that the game is now running
        gameState = .gameRunning
        
        // Set the label
        gameInfoLabel.text = gameInfo
        gameStatusLabel?.text = ""
        
        
        // Timer to produce the pairs
        newRectPairTimer = Timer.scheduledTimer(withTimeInterval: gameManager.newRectPairInterval,
                                                repeats: true)
            { _ in self.createRectanglePairs() }
        
        // Timer to end the game, resume with the remaining time
        gameTimer = Timer.scheduledTimer(withTimeInterval: gameTimeRemaining,
                                         repeats: false)
            { _ in self.gameOver() }
        
    }
    
    //================================================
    private func pauseGameRunning() {
        
        // Indicate that the game is paused
        gameState = .gamePaused
        
        // Set the label
        gameInfoLabel.text = gameInfo
        // gameStatusLabel?.text = gameStatus
        gameStatusLabel?.text = "Game Paused"
        gameStatusLabel.textColor = .gray
        
        // Stop the timers
        newRectPairTimer?.invalidate()
        gameTimer?.invalidate()
        
        // Remove the reference to the timer objects
        newRectPairTimer = nil
        gameTimer    = nil
    }
    
    //================================================
    func gameOver() {
        // Stop the action
        pauseGameRunning()
        
        calculateHighestScore(score: rectanglePairsTouched)
        
        // No game in progress
        gameState = .noGame
        gameStatusLabel?.text = "Game Over!!!"
        gameStatusLabel.textColor = .red
        
        // Indicate via the label the game is over
        gameInfoLabel.textColor = .red
        gameInfoLabel.backgroundColor = .black
        
    }
    
    //================================================
    func startNewGame() {
        // Clear the rectangles
        removeSavedRectangles()
        
        // Reset the time remaining to the full game time
        gameTimeRemaining = gameManager.gameDuration
        
        // Reset the game stat vars
        rectanglePairsCreated = 0
        rectanglePairsTouched = 0
        
        // Adjust the label background
        gameInfoLabel.backgroundColor = .clear
        gameInfoLabel.textColor = .black
        gameStatusLabel?.text = ""
        
        // Get the action going
        resumeGameRunning()
    }
    
    //================================================
    func calculateHighestScore(score: Int){
        if(score >= 1){
            if(score > gameManager.firstHighestScore){
                gameManager.thirdHighestScore = gameManager.secondHighestScore
                gameManager.firstHighestScore = score
            }else if(score > gameManager.secondHighestScore){
                if(score != gameManager.firstHighestScore ){
                    gameManager.thirdHighestScore = gameManager.secondHighestScore
                    gameManager.secondHighestScore = score
                }
            }else{
                if(score != gameManager.secondHighestScore ){
                    gameManager.thirdHighestScore = score
                }
            }
        }
    }
}


//extension GameSceneVC: UINavigationControllerDelegate {
//
//    func navigationController(_ navigationController: UINavigationController, shouldSelect viewController: UIViewController) -> Bool {
//        if viewController.isKind(of: ConfigVC.self as AnyClass) {
//            let viewController  = navigationController.viewControllers[1] as! ConfigVC
//            viewController.gameManager = self.gameManager
//        }
//
//        return true
//    }
//}
