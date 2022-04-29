//
//  ViewController.swift
//  ElementQuiz
//
//  Created by Alexa Papandreou on 4/9/22.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
   
    var currentElementIndex = 0
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    var elementList : [String] = []
    
    enum Mode{
        case flashCard
        case quiz
    }
    var mode : Mode = .flashCard {
        didSet {
            switch mode {
            case .flashCard: setupFlashCards()
            case .quiz: setupQuiz()
            }
            updateUI()
        }
    }
    
    enum State {
        case question
        case answer
        case score
    }
    var state: State = .question
    
    var answerIsCorrect = false
    var correctAnswerCount = 0
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mode = .flashCard
    }
    
    func updateFlashCardUI(elementName: String){
        showAnswerButton.isHidden = false
        nextButton.isEnabled = true
        nextButton.setTitle("Next Element", for: .normal)
        textField.isHidden = true
        textField.resignFirstResponder()
        if state == .answer {
            answerLabel.text = elementName
        } else {
            answerLabel.text = "?"
        }
        
        modeSelector.selectedSegmentIndex = 0
    }
    
    func updateQuizUI(elementName : String) {
        showAnswerButton.isHidden = true
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        switch state {
        case .question: nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
        
        textField.isHidden = false
        switch state {
        case .question :
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        case .answer :
            textField.isEnabled = false
            textField.resignFirstResponder()
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        
        switch state {
        case .question : answerLabel.text = ""
        case .answer :
            if answerIsCorrect {
                answerLabel.text = "Correct!"
            } else {
                answerLabel.text = "❌\nCorrect Answer: " + elementName
            }
        case .score :
            answerLabel.text = ""
            print("Your score is", correctAnswerCount, "out of", elementList.count, ".")
        }
        
        if state == .score {
            displayScoreAlert()
        }
        
        modeSelector.selectedSegmentIndex = 1
    }
    
    func updateUI(){
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        
        switch mode{
        case .flashCard: updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    
    
    @IBAction func showAnswer(_ sender: Any) {
        state = .answer
        updateUI()
    }
    
    @IBAction func next(_ sender: Any) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count {
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        state = .question
        updateUI()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let textFieldContents = textField.text!
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        
        state = .answer
        updateUI()
        
        
        return true
    }
    
    
    @IBAction func switchModes(_ sender: Any) {
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }

    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count).", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: scoreAlertDismissed(_:))
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func scoreAlertDismissed(_ action: UIAlertAction){
        mode = .flashCard
    }
    
    func setupFlashCards(){
        elementList = fixedElementList
        state = .question
        currentElementIndex = 0
    }
    
    func setupQuiz(){
        elementList = fixedElementList.shuffled()
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
    }


}

