//
//  HomeView.swift
//  QuizSUI
//
//  Created by Paul Makey on 5.05.24.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

struct HomeView: View {
    @State private var quizInfo: Info?
    @State private var questions: [Question] = []
    @State private var startQuiz = false
    
    /// - User Anonymous Log Status
    @AppStorage("log_status") private var logStatus = false
    
    var body: some View {
        if let info = quizInfo {
            VStack(spacing: 10) {
                Text(info.title)
                    .font(.title)
                    .fontWeight(.semibold)
                    .hAlign(.leading)
                
                /// - Custom Label
                CustomLabel("list.bullet.rectangle.portrait",
                            "\(questions.count)",
                            "Количество вопросов"
                )
                .padding(.top, 20)
                
                CustomLabel(
                    "person",
                    "\(info.peopleAttended)",
                    "Прошло тест"
                )
                .padding(.top, 5)
                
                Divider()
                    .padding(.horizontal, -15)
                    .padding(.top, 15)
                
                if !info.rules.isEmpty {
                    RulesView(info.rules)
                }
                
                CustomButton(title: "Начать тест") {
                    startQuiz.toggle()
                }
                .vAlign(.bottom)
                
            }
            .padding(15)
            .vAlign(.top)
            .fullScreenCover(isPresented: $startQuiz) {
                QuestionView(info: info, questions: questions) {
                    /// - User has Successfully Finished the Quiz
                    /// - Thus Update the UI
                    quizInfo?.peopleAttended += 1
                }
            }
        } else {
            /// - Presenting Progress View
            VStack(spacing: 4) {
                ProgressView()
                Text("Пожалуйста, подождите")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            .task {
                do {
                    try await fetchData()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    /// - Rules View
    @ViewBuilder
    func RulesView(_ rules: [String]) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Правила")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.bottom, 12)
            
            ForEach(rules, id: \.self) { rule in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(.yellow)
                        .frame(width: 8, height: 8)
                        .offset(y: 6)
                    Text(rule)
                        .font(.callout)
                        .lineLimit(3)
                    
                }
            }
        }
    }
    
    /// - Custom Label
    @ViewBuilder
    func CustomLabel(_ image: String, _ title: String, _ subTitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: image)
                .font(.title3)
                .frame(width: 45, height: 45)
                .background {
                    Circle()
                        .fill(.gray.opacity(0.1))
                        .padding(-1)
                        .background {
                            Circle()
                                .stroke(Color(.yellow), lineWidth: 1)
                        }
                }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .fontWeight(.bold)
                    .foregroundStyle(.yellow)
                Text(subTitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.gray)
            }
            .hAlign(.leading)
        }
    }
    
    /// - Fetching Quiz Info and Questions
    func fetchData() async throws {
        try await loginUserAnonymous()
        
        let info = try await Firestore
            .firestore()
            .collection("Quiz")
            .document("Info")
            .getDocument()
            .data(as: Info.self)
        
        let questions = try await Firestore
            .firestore()
            .collection("Quiz")
            .document("Info")
            .collection("Questions")
            .getDocuments()
            .documents
            .compactMap {
                try $0.data(as: Question.self)
            }
        
        /// - UI Must be Updated on Main Thread
        await MainActor.run {
            quizInfo = info
            self.questions = questions
        }
        
    }
    
    /// - Login User as Anonymous For Firestore Access
    // TODO: - Implement own user profile
    func loginUserAnonymous() async throws {
        if !logStatus {
            try await Auth.auth().signInAnonymously()
        }
    }
}

// MARK: - Custom Button
struct CustomButton: View {
    var title: String
    var onClick: () -> ()
    
    var body: some View {
        Button {
            onClick()
        } label: {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .hAlign(.center)
                .padding(.top, 15)
                .padding(.bottom, 10)
                .foregroundStyle(.white)
                .background {
                    Rectangle()
                        .fill(.pink)
                        .ignoresSafeArea()
                }
        }
        /// - Removing Padding
        .padding([.bottom, .horizontal], -15)
    }
}
