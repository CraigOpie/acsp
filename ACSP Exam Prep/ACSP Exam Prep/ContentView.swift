//
//  ContentView.swift
//  ACSP Exam Prep
//
//  Created by Craig on 8/14/23.
//

import SwiftUI
import SwiftData

enum QuizMode {
    case study, exam
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var questions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: Set<String> = []
    @State private var correctAnswers = 0
    @State private var showResult = false
    @State private var mode: QuizMode?
    @State private var showMenu = true
    @State private var hasCheckedAnswer = false
    @State private var timeRemaining = 7200 // 120 minutes in seconds
    @State private var timerActive = false
    @State private var showAlert = false
    @State private var showConfetti = false
    @Environment(\.colorScheme) var colorScheme
    @State private var timer: DispatchSourceTimer?

    var body: some View {
        if showMenu {
            menuView
        } else if showResult && mode == .exam {
            resultView
        } else {
            quizView
                .alert(isPresented: $showAlert) {
                    if mode == .exam {
                        return Alert(
                            title: Text("End Exam"),
                            message: Text("Are you sure you want to end your exam?"),
                            primaryButton: .destructive(Text("End Exam")) {
                                markRemainingQuestionsIncorrect()
                                showResult = true
                            },
                            secondaryButton: .cancel()
                        )
                    } else {
                        return Alert(title: Text("Error"), message: Text("Unexpected mode"), dismissButton: .default(Text("OK")))
                    }
                }
                .onAppear {
                    if correctAnswers >= (questions.count / 10 * 8) {
                        showConfetti = true
                    }
                }
        }
    }
    
    var menuView: some View {
        VStack(spacing: 30) {
            Text("Apple Certified Support Professional Practice Exam")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding(.top, 50)
            
            Spacer()
            
            Button(action: {
                self.mode = .study
                self.showMenu = false
                self.loadQuestions()
            }) {
                Text("Study Mode")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
            .buttonStyle(MagicButtonEffect())
            
            Button(action: {
                self.mode = .exam
                self.showMenu = false
                self.loadQuestions()
                self.startTimer()
            }) {
                Text("Exam Mode")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
            .buttonStyle(MagicButtonEffect())
            
            Spacer()
        }
        .padding()
    }
    
    var resultView: some View {
        VStack(spacing: 30) {
            Text(correctAnswers >= (questions.count / 10 * 8) ? "Pass" : "Fail")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 15) {
                Text("Performance Breakdown")
                    .font(.title2)

                Text("Percentage Correct: \(Int(Double(correctAnswers) / Double(questions.count) * 100))%")
                Text("Questions Correct: \(correctAnswers)")
                Text("Questions Incorrect: \(questions.count - correctAnswers)")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            HStack(spacing: 20) {
                Button(action: retryQuiz) {
                    Text("Retry")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(MagicButtonEffect())

                Button(action: {
                    retryQuiz()
                    showMenu = true
                    showResult = false
                }) {
                    Text("Main Menu")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(MagicButtonEffect())
            }
        }
        .padding()
        .background(
            ZStack {
                if showConfetti {
                    ConfettiView()
                        .edgesIgnoringSafeArea(.all)
                }
            }
        )
    }
    
    var quizView: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    if mode == .exam {
                        showAlert = true
                    } else {
                        showMenu = true
                    }
                }) {
                    Image(systemName: "xmark")
                        .padding(10)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .foregroundColor(.primary)
                        .clipShape(Circle())
                }
                .buttonStyle(MagicButtonEffect())
            }
            .overlay(
                mode == .exam ? AnyView(
                    Text(timeString(time: timeRemaining))
                        .font(.headline)
                        .padding(.top, 10)
                        .foregroundColor(timerColor())
                ) : AnyView(EmptyView()),
                alignment: .center
            )
            
            HStack {
                ProgressBar(progress: Double(currentQuestionIndex) / Double(questions.count))
                    .frame(maxWidth: maxWidth())
            }

            if !questions.isEmpty {
                GeometryReader { geometry in
                    ScrollView {
                        Text(questions[currentQuestionIndex].question)
                            .font(.system(size: min(geometry.size.width * 0.05, 20)))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.primary)
                            .minimumScaleFactor(0.5)
                            .lineLimit(nil)
                    }
                    .frame(height: geometry.size.height * 0.95)
                }

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(questions[currentQuestionIndex].allOptions, id: \.self) { option in
                            Button(action: {
                                if !hasCheckedAnswer {
                                    if selectedAnswers.contains(option) {
                                        selectedAnswers.remove(option)
                                    } else {
                                        selectedAnswers.insert(option)
                                    }
                                }
                            }) {
                                Text(option)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(buttonColor(for: option))
                                    .foregroundColor(.primary)
                                    .overlay(correctBorder(for: option))
                                    .cornerRadius(10)
                                    .blur(radius: shouldBlur(option: option) ? 5 : 0)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(nil)
                            }
                            .buttonStyle(MagicButtonEffect())
                        }
                    }
                }
                .scrollIndicators(.visible)


                Spacer()

                Button(action: {
                    if hasCheckedAnswer {
                        moveToNextQuestion()
                    } else {
                        checkAnswer()
                    }
                }) {
                    Text(hasCheckedAnswer ? "Next Question" : "Submit")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!selectedAnswers.isEmpty ? Color.green : Color.gray)
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                        .minimumScaleFactor(0.5)
                        .lineLimit(nil)
                }
                .buttonStyle(MagicButtonEffect())
                .disabled(selectedAnswers.isEmpty)
                .padding(.bottom, 20)
            }
        }
        .padding()
        .onAppear {
            hasCheckedAnswer = false
            selectedAnswers = []
            loadQuestions()
            if mode == .exam {
                startTimer()
            }
        }
    }
    
    func maxWidth() -> CGFloat {
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
    
    func loadQuestions() {
        if let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                let loadedQuestions = try JSONDecoder().decode([Question].self, from: data)
                questions = loadedQuestions.shuffled()
            } catch {
                print("Error decoding questions: \(error)")
            }
        }
    }

    func buttonColor(for option: String) -> Color {
        if hasCheckedAnswer {
            if questions[currentQuestionIndex].answers.correct.contains(option) {
                return Color.green.opacity(0.3)
            } else if selectedAnswers.contains(option) {
                return Color.red.opacity(0.3)
            }
        }
        return selectedAnswers.contains(option) ? Color.blue : Color.gray.opacity(0.3)
    }

    func correctBorder(for option: String) -> some View {
        if hasCheckedAnswer && questions[currentQuestionIndex].answers.correct.contains(option) {
            return RoundedRectangle(cornerRadius: 10)
                .stroke(Color.green, lineWidth: 3)
        }
        return RoundedRectangle(cornerRadius: 0).stroke(Color.clear)
    }

    func shouldBlur(option: String) -> Bool {
        return hasCheckedAnswer && mode == .study && !questions[currentQuestionIndex].answers.correct.contains(option)
    }

    func checkAnswer() {
        if mode == .study {
            hasCheckedAnswer = true
        } else {
            moveToNextQuestion()
        }
    }

    func moveToNextQuestion() {
        withAnimation {
            if questions[currentQuestionIndex].isCorrectAnswer(Array(selectedAnswers)) {
                correctAnswers += 1
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

    func startTimer() {
        timerActive = true

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
        timeRemaining = 7200
    }

    func markRemainingQuestionsIncorrect() {
        for _ in currentQuestionIndex..<questions.count {
            currentQuestionIndex += 1
        }
    }

    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func timerColor() -> Color {
        if timeRemaining < 120 {
            return Color.red
        } else if timeRemaining < 600 {
            return Color.yellow
        } else {
            return Color.primary
        }
    }
}

struct ProgressBar: View {
    var progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(height: 4).opacity(0.3).foregroundColor(Color.secondary)
                Rectangle().frame(width: CGFloat(progress) * geometry.size.width, height: 4).foregroundColor(Color.primary)
            }
        }
        .padding(.top, 10)
        .frame(height: 4)
    }
}

struct MagicButtonEffect: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .brightness(configuration.isPressed ? 0.1 : 0)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
