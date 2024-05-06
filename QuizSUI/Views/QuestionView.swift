//
//  QuestionView.swift
//  QuizSUI
//
//  Created by Paul Makey on 5.05.24.
//

import SwiftUI
import FirebaseFirestore

struct QuestionView: View {
    var info: Info
    
    /// - Making it a State, so that we can do View Modifications
    @State var questions: [Question]
    var onFinish: () -> ()
    
    /// - View Properties
    @Environment(\.dismiss) private var dismiss
    @State private var progress = 0.0
    @State private var score = 0.0
    @State private var currentIndex = 0
    @State private var showScoreCard = false
    
    var body: some View {
        VStack(spacing: 15) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .hAlign(.leading)
            
            Text(info.title)
                .font(.title)
                .fontWeight(.semibold)
                .hAlign(.leading)
            
            GeometryReader {
                let size = $0.size
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.black.opacity(0.2))
                    
                    Rectangle()
                        .fill(.yellow)
                        .frame(width: progress * size.width, alignment: .leading)
                }
                .clipShape(Capsule())
            }
            .frame(height: 20)
            .padding(.top, 5)
            
            /// - Questions
            GeometryReader { _ in
                ForEach(questions.indices, id: \.self) { index in
                    /// - Using Transitions for Moving Forth and Between Instead of Using TabView
                    if currentIndex == index {
                        QuestionView(question: questions[currentIndex])
                        /// - The View Enters from the Left and Leaves Towards the Right
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .trailing),
                                    removal: .move(
                                        edge: .leading
                                    )
                                )
                            )
                        
                    }
                }
            }
            .padding(.horizontal, -15)
            .padding(.vertical, 15)
            
            /// - Changing Button to "Finish" When the Last Question Arrived
            CustomButton(title: currentIndex == (questions.count - 1) ? "Завершить" : "Следующий вопрос") {
                if currentIndex == questions.count - 1 {
                    /// - Presenting Score Card View
                    showScoreCard.toggle()
                } else {
                    withAnimation(.easeInOut) {
                        currentIndex += 1
                        progress = Double(currentIndex) / Double(questions.count - 1)
                    }
                }
            }
            .disabled(questions[currentIndex].tappedAnswer == "")
        }
        .padding(15)
        .hAlign(.center)
        .vAlign(.top)
        .background {
            Color(.systemGray6)
                .ignoresSafeArea()
        }
        
        /// - This View is Going to be Dark Since our Background is Dark
        .environment(\.colorScheme, .dark)
        .fullScreenCover(isPresented: $showScoreCard) {
            ScoreCardView(score: score / Double(questions.count) * 100) {
                /// - Closing View
                dismiss()
                onFinish()
            }
        }
    }
    
    // MARK: - Question View
    @ViewBuilder
    func QuestionView(question: Question) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Вопрос \(currentIndex + 1)/\(questions.count)")
                .font(.callout)
                .foregroundStyle(.gray)
                .hAlign(.leading)
            
            Text(question.question)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
            
            VStack(spacing: 12) {
                ForEach(question.options, id: \.self) { option in
                    /// - Displaying Correct and Wrong Answers After user has Tapped any one of the Options
                    ZStack {
                        OptionView(option, Color(.systemGray3))
                            .opacity(
                                question.answer == option && question.tappedAnswer != ""
                                ? 0
                                : 1
                            )
                        OptionView(option, .green)
                            .opacity(
                                question.answer == option && question.tappedAnswer != ""
                                ? 1
                                : 0
                            )
                        OptionView(option, .red)
                            .opacity(
                                question.tappedAnswer == option && question.tappedAnswer != question.answer
                                ? 1
                                : 0
                            )
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        /// - Disabling Tap when Answer was Selected
                        guard questions[currentIndex].tappedAnswer == "" else {
                            return
                        }
                        
                        withAnimation(.easeInOut) {
                            questions[currentIndex].tappedAnswer = option
                        }
                        
                        if question.answer == option {
                            score += 1
                        }
                    }
                }
            }
            .padding(.vertical, 10)
        }
        .padding(15)
        .hAlign(.center)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white)
        }
        .padding(.horizontal, 15)
    }
    
    // MARK: - Option View
    @ViewBuilder
    func OptionView(_ option: String, _ tint: Color) -> some View {
        Text(option)
            .foregroundStyle(tint)
            .padding(.horizontal, 15)
            .padding(.vertical, 20)
            .hAlign(.leading)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.15))
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(
                                tint.opacity(tint == Color(.systemGray3) ? 0.15 : 1),
                                lineWidth: 2
                            )
                    }
            }
    }
}

// MARK: - Score Card View
struct ScoreCardView: View {
    var score: Double
    var onDismiss: () -> ()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            VStack(spacing: 15) {
                Text("Результаты")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                VStack(spacing: 15) {
                    Text("Поздравляю! Ты\n набрал")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    /// - Removing Floating Points
                    Text(String(format: "%.0f", score) + "%")
                        .font(.title.bold())
                        .padding(.bottom, 10)
                    
                    Image("prize")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 220)
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 15)
                .padding(.vertical, 20)
                .hAlign(.center)
                .background {
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(.white)
                }
            }
            .vAlign(.center)
            
            CustomButton(title: "Вернуться домой") {
                /// - Before Closing Updating Attended People Count on Firestore
                Firestore.firestore().collection("Quiz").document("Info").updateData([
                    "peopleAttended": FieldValue.increment(1.0)
                ])
                onDismiss()
                dismiss()
            }
        }
        .padding(15)
        .background {
            Color(.systemGray3)
                .ignoresSafeArea()
        }
    }
}
