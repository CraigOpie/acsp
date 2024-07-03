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

    struct Answer: Decodable {
        let correct: [String]
        let incorrect: [String]
    }

    init(question: String, answers: Answer, allOptions: [String]) {
        self.question = question
        self.answers = answers
        self.allOptions = allOptions
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.question = try container.decode(String.self, forKey: .question)

        let answersContainer = try container.nestedContainer(keyedBy: AnswerKeys.self, forKey: .answers)

        let correctAnswers: [String]
        if let singleCorrect = try? answersContainer.decode(String.self, forKey: .correct) {
            correctAnswers = [singleCorrect]
        } else {
            correctAnswers = try answersContainer.decode([String].self, forKey: .correct)
        }

        let incorrectAnswers = try answersContainer.decode([String].self, forKey: .incorrect)
        self.answers = Answer(correct: correctAnswers, incorrect: incorrectAnswers)

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
