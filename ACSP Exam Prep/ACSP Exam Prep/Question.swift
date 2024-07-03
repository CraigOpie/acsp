//
//  Question.swift
//  ACSP Exam Prep
//
//  Created by Craig on 8/14/23.
//

import Foundation

struct Question: Identifiable, Decodable {
    var id: UUID = UUID()
    let question: String
    let answers: Answer
    var allOptions: [String]
    var consecutiveCorrectAnswers: Int = 0

    struct Answer: Decodable {
        let correct: [String]
        let incorrect: [String]

        init(correct: [String], incorrect: [String]) {
            self.correct = correct
            self.incorrect = incorrect
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            if let correctArray = try? container.decode([String].self, forKey: .correct) {
                self.correct = correctArray
            } else if let correctString = try? container.decode(String.self, forKey: .correct) {
                self.correct = [correctString]
            } else {
                self.correct = []
            }
            
            self.incorrect = try container.decode([String].self, forKey: .incorrect)
        }

        private enum CodingKeys: String, CodingKey {
            case correct, incorrect
        }
    }

    init(question: String, answers: Answer, allOptions: [String]) {
        self.question = question
        self.answers = answers
        self.allOptions = allOptions
        self.consecutiveCorrectAnswers = 0
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.question = try container.decode(String.self, forKey: .question)
        self.answers = try container.decode(Answer.self, forKey: .answers)

        var options = answers.incorrect
        let correctIndex = Int.random(in: 0...answers.incorrect.count)
        options.insert(contentsOf: answers.correct, at: correctIndex)
        self.allOptions = options
        self.consecutiveCorrectAnswers = 0
    }

    func isCorrectAnswer(_ answer: [String]) -> Bool {
        return Set(answer) == Set(answers.correct)
    }

    private enum CodingKeys: String, CodingKey {
        case question, answers
    }
}
