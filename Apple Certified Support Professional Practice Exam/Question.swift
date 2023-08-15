//
//  Questions.swift
//  Apple Certified Support Professional Practice Exam
//
//  Created by Craig on 8/10/23.
//

import Foundation

struct Question: Identifiable, Decodable {
    private(set) var id: UUID = UUID()
    let question: String
    let answers: Answer
    var allOptions: [String]
    
    struct Answer: Decodable {
        let correct: [String]
        let incorrect: [String]
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode the question as usual
        self.question = try container.decode(String.self, forKey: .question)
        
        // Access the answers container
        let answersContainer = try container.nestedContainer(keyedBy: AnswerKeys.self, forKey: .answers)
        
        // Try to decode 'correct' as a single string. If that fails, decode it as an array.
        let correctAnswers: [String]
        if let singleCorrect = try? answersContainer.decode(String.self, forKey: .correct) {
            correctAnswers = [singleCorrect]
        } else {
            correctAnswers = try answersContainer.decode([String].self, forKey: .correct)
        }
        
        let incorrectAnswers = try answersContainer.decode([String].self, forKey: .incorrect)
        self.answers = Answer(correct: correctAnswers, incorrect: incorrectAnswers)
        
        // Create allOptions array and randomize it during initialization
        var options = answers.incorrect
        let correctIndex = Int.random(in: 0...answers.incorrect.count)
        options.insert(contentsOf: answers.correct, at: correctIndex)
        self.allOptions = options
    }
    
    func isCorrectAnswer(_ answer: [String]) -> Bool {
        return Set(answer) == Set(answers.correct)
    }

    private enum CodingKeys: String, CodingKey {
        case question, answers
    }

    private enum AnswerKeys: String, CodingKey {
        case correct, incorrect
    }
}
