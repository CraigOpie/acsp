//
//  QuizViewModel.swift
//  ACSP Exam Prep
//
//  Created by Craig Opie on 7/2/24.
//

import SwiftUI
import Foundation

class QuizViewModel: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswers: Set<String> = []
    @Published var correctAnswers = 0
    @Published var showResult = false
    @Published var mode: QuizMode?
    @Published var showMenu = true
    @Published var hasCheckedAnswer = false
    @Published var timeRemaining = 7200 // 120 minutes in seconds
    @Published var timerActive = false
    @Published var showAlert = false
    @Published var showConfetti = false
    @Published var timer: DispatchSourceTimer?
    private var uniqueQuestionsAsked: Set<UUID> = []

    var passed: Bool {
        correctAnswers >= (questions.count / 10 * 8)
    }

    var percentageCorrect: Int {
        guard !questions.isEmpty else { return 0 }
        return Int(Double(correctAnswers) / Double(questions.count) * 100)
    }

    var incorrectAnswers: Int {
        guard !questions.isEmpty else { return 0 }
        return questions.count - correctAnswers
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(uniqueQuestionsAsked.count) / Double(questions.count)
    }

    var maxWidth: CGFloat {
        #if os(iOS)
        return UIScreen.main.bounds.width * 0.85
        #else
        if let screen = NSScreen.main {
            return screen.visibleFrame.width * 0.85
        } else {
            return 1080
        }
        #endif
    }

    var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var timerColor: Color {
        if timeRemaining < 120 {
            return Color.red
        } else if timeRemaining < 600 {
            return Color.yellow
        } else {
            return Color.primary
        }
    }

    var submitButtonText: String {
        hasCheckedAnswer ? "Next Question" : "Submit"
    }

    var currentQuestion: Question {
        guard !questions.isEmpty else {
            return Question(question: "", answers: .init(correct: [], incorrect: []), allOptions: [])
        }
        return questions[currentQuestionIndex]
    }

    func initializeQuiz() {
        hasCheckedAnswer = false
        selectedAnswers = []
        uniqueQuestionsAsked.removeAll()
        loadQuestions()
        if mode == .exam {
            startTimer()
        }
    }

    func loadQuestions() {
        if let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                let loadedQuestions = try JSONDecoder().decode([Question].self, from: data)
                questions = loadedQuestions.shuffled()
                currentQuestionIndex = 0
            } catch {
                print("Error decoding questions: \(error)")
            }
        }
    }

    func startTimer() {
        timerActive = true
        timeRemaining = 7200 // Reset timer

        timer?.cancel()
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer?.schedule(deadline: .now(), repeating: 1.0)
        timer?.setEventHandler {
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timer?.cancel()
                self.markRemainingQuestionsIncorrect()
                self.showResult = true
            }
        }
        timer?.resume()
    }

    func stopTimer() {
        timerActive = false
        timer?.cancel()
        timer = nil
    }

    func markRemainingQuestionsIncorrect() {
        for _ in currentQuestionIndex..<questions.count {
            currentQuestionIndex += 1
        }
    }

    func endExam() {
        markRemainingQuestionsIncorrect()
        showResult = true
    }

    func handleExit() {
        if mode == .exam {
            showAlert = true
        } else {
            showMenu = true
        }
    }

    func startStudyMode() {
        mode = .study
        showMenu = false
        loadQuestions()
    }

    func startExamMode() {
        mode = .exam
        showMenu = false
        loadQuestions()
        startTimer()
    }

    func returnToMenu() {
        showMenu = true
        showResult = false
        stopTimer()
    }

    func retryQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        selectedAnswers = []
        hasCheckedAnswer = false
        showResult = false
        showConfetti = false
        stopTimer()
        loadQuestions()
        if mode == .exam {
            timeRemaining = 7200
            startTimer()
        }
    }

    func selectAnswer(_ option: String) {
        if !hasCheckedAnswer {
            if selectedAnswers.contains(option) {
                selectedAnswers.remove(option)
            } else {
                selectedAnswers.insert(option)
            }
        }
    }

    func buttonColor(for option: String) -> Color {
        if hasCheckedAnswer {
            if currentQuestion.answers.correct.contains(option) {
                return Color.green.opacity(0.3)
            } else if selectedAnswers.contains(option) {
                return Color.red.opacity(0.3)
            }
        }
        return selectedAnswers.contains(option) ? Color.blue : Color.gray.opacity(0.3)
    }

    func correctBorder(for option: String) -> some View {
        if hasCheckedAnswer && currentQuestion.answers.correct.contains(option) {
            return RoundedRectangle(cornerRadius: 10)
                .stroke(Color.green, lineWidth: 3)
        }
        return RoundedRectangle(cornerRadius: 0).stroke(Color.clear)
    }

    func shouldBlur(option: String) -> Bool {
        return hasCheckedAnswer && mode == .study && !currentQuestion.answers.correct.contains(option)
    }

    func checkAnswer() {
        if mode == .study {
            hasCheckedAnswer = true
            if currentQuestion.isCorrectAnswer(Array(selectedAnswers)) {
                questions[currentQuestionIndex].consecutiveCorrectAnswers += 1
                if questions[currentQuestionIndex].consecutiveCorrectAnswers >= 3 {
                    questions.remove(at: currentQuestionIndex)
                }
            } else {
                questions[currentQuestionIndex].consecutiveCorrectAnswers = 0
            }
        } else {
            if currentQuestion.isCorrectAnswer(Array(selectedAnswers)) {
                correctAnswers += 1
            }
        }
    }

    func moveToNextQuestion() {
        withAnimation {
            if !uniqueQuestionsAsked.contains(currentQuestion.id) {
                uniqueQuestionsAsked.insert(currentQuestion.id)
            }
            if currentQuestionIndex < questions.count - 1 {
                currentQuestionIndex += 1
                selectedAnswers.removeAll()
                hasCheckedAnswer = false
            } else {
                if mode == .exam {
                    showResult = true
                } else {
                    showMenu = true
                }
            }
        }
    }

    func moveToNextStudyQuestion() {
        withAnimation {
            if !uniqueQuestionsAsked.contains(currentQuestion.id) {
                uniqueQuestionsAsked.insert(currentQuestion.id)
            }
            if questions.isEmpty {
                showMenu = true
            } else {
                currentQuestionIndex = Int.random(in: 0..<questions.count)
                selectedAnswers.removeAll()
                hasCheckedAnswer = false
            }
        }
    }

    func submitAnswer() {
        if hasCheckedAnswer {
            if mode == .study {
                moveToNextStudyQuestion()
            } else {
                moveToNextQuestion()
            }
        } else {
            checkAnswer()
            if mode == .exam {
                moveToNextQuestion()
            }
        }
    }
}
