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
    
    @StateObject private var quizViewModel = QuizViewModel()

    var body: some View {
        Group {
            if quizViewModel.showMenu {
                menuView
            } else if quizViewModel.showResult && quizViewModel.mode == .exam {
                resultView
            } else {
                quizView
            }
        }
        .alert(isPresented: $quizViewModel.showAlert) {
            if quizViewModel.mode == .exam {
                return Alert(
                    title: Text("End Exam"),
                    message: Text("Are you sure you want to end your exam?"),
                    primaryButton: .destructive(Text("End Exam")) {
                        quizViewModel.endExam()
                    },
                    secondaryButton: .cancel()
                )
            } else {
                return Alert(title: Text("Error"), message: Text("Unexpected mode"), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private var menuView: some View {
        VStack(spacing: 30) {
            Text("Apple Certified Support Professional Practice Exam")
                .multilineTextAlignment(.center)
                .font(.title)
                .padding(.top, 50)
            
            Spacer()
            
            Button(action: {
                quizViewModel.startStudyMode()
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
                quizViewModel.startExamMode()
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
    
    private var resultView: some View {
        VStack(spacing: 30) {
            Text(quizViewModel.passed ? "Pass" : "Fail")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 15) {
                Text("Performance Breakdown")
                    .font(.title2)

                Text("Percentage Correct: \(quizViewModel.percentageCorrect)%")
                Text("Questions Correct: \(quizViewModel.correctAnswers)")
                Text("Questions Incorrect: \(quizViewModel.incorrectAnswers)")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            HStack(spacing: 20) {
                Button(action: {
                    quizViewModel.retryQuiz()
                }) {
                    Text("Retry")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(MagicButtonEffect())

                Button(action: {
                    quizViewModel.returnToMenu()
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
                if quizViewModel.showConfetti {
                    ConfettiView()
                        .edgesIgnoringSafeArea(.all)
                }
            }
        )
    }
    
    private var quizView: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                ExitButton(action: {
                    quizViewModel.handleExit()
                })
                .buttonStyle(MagicButtonEffect())
            }
            .overlay(
                quizViewModel.mode == .exam ? AnyView(
                    Text(quizViewModel.timeString)
                        .font(.headline)
                        .padding(.top, 10)
                        .foregroundColor(quizViewModel.timerColor)
                ) : AnyView(EmptyView()),
                alignment: .center
            )
            
            HStack {
                ProgressBar(progress: quizViewModel.progress)
                    .frame(maxWidth: quizViewModel.maxWidth)
            }

            if !quizViewModel.questions.isEmpty {
                GeometryReader { geometry in
                    ScrollView {
                        Text(quizViewModel.currentQuestion.question)
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
                        ForEach(quizViewModel.currentQuestion.allOptions, id: \.self) { option in
                            Button(action: {
                                quizViewModel.selectAnswer(option)
                            }) {
                                Text(option)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(quizViewModel.buttonColor(for: option))
                                    .foregroundColor(.primary)
                                    .overlay(quizViewModel.correctBorder(for: option))
                                    .cornerRadius(10)
                                    .blur(radius: quizViewModel.shouldBlur(option: option) ? 5 : 0)
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
                    quizViewModel.submitAnswer()
                }) {
                    Text(quizViewModel.submitButtonText)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!quizViewModel.selectedAnswers.isEmpty ? Color.green : Color.gray)
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                        .minimumScaleFactor(0.5)
                        .lineLimit(nil)
                }
                .buttonStyle(MagicButtonEffect())
                .disabled(quizViewModel.selectedAnswers.isEmpty)
                .padding(.bottom, 20)
            }
        }
        .padding()
        .onAppear {
            quizViewModel.initializeQuiz()
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

struct ExitButton: View {
    @Environment(\.colorScheme) var colorScheme
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .padding(10)
                .background(colorScheme == .dark ? Color.black : Color.white)
                .foregroundColor(.primary)
                .clipShape(Circle())
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
