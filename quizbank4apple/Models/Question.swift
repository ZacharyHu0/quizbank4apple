//
//  Question.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import Foundation

struct Question: Identifiable, Codable {
    let id: String
    let questionId: Int
    let year: Int
    let module: Int
    let week: Int
    let questionText: String
    let options: [String]
    let correctAnswer: String
    let questionBank: String

    // 用于挑战中的用户选择
    var userAnswer: String?
    var isAnswered: Bool {
        return userAnswer != nil
    }

    var isCorrect: Bool {
        return userAnswer == correctAnswer
    }

    enum CodingKeys: String, CodingKey {
        case questionId = "number"
        case year = "grade"
        case module = "module"
        case week = "week"
        case questionText = "question_stem"
        case options = "choice"
        case correctAnswer = "correct_answer"
    }

init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        questionId = try container.decode(Int.self, forKey: .questionId)
        year = try container.decode(Int.self, forKey: .year)
        module = try container.decode(Int.self, forKey: .module)
        week = try container.decode(Int.self, forKey: .week)
        questionText = try container.decode(String.self, forKey: .questionText)
        correctAnswer = try container.decode(String.self, forKey: .correctAnswer)

        let optionsString = try container.decode(String.self, forKey: .options)
        options = Question.parseOptions(optionsString)

        let tempQuestionBank = "" // 临时变量
        id = "\(tempQuestionBank)-\(questionId)"
        questionBank = tempQuestionBank
    }

    init(questionId: Int, year: Int, module: Int, week: Int, questionText: String, options: [String], correctAnswer: String, questionBank: String) {
        self.id = "\(questionBank)-\(questionId)"
        self.questionId = questionId
        self.year = year
        self.module = module
        self.week = week
        self.questionText = questionText
        self.options = options
        self.correctAnswer = correctAnswer
        self.questionBank = questionBank
    }

    static func parseOptions(_ optionsString: String) -> [String] {
        // 解析选项字符串，如 "A.2", "B.4", "C.6", "D.8"
        // 正则：匹配“连续的大写字母（A-Z）或点号（.）”的前面位置（零宽断言）
            // [A-Z.]+ 表示“1个或多个连续的大写字母或点号”
        // 正则表达式：匹配“大写字母+点号”（如A.、B.、C.），并在其前面添加分割标记
            // 零宽断言(?=([A-Z]\\.))：匹配“后面紧跟着大写字母+点号”的位置
        let pattern = "(?=([A-Z]\\.))"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: optionsString.utf16.count)
            
            // 用特殊标记（如"||"）替换分割位置，避免与原字符串冲突
            let markedString = regex.stringByReplacingMatches(in: optionsString, range: range, withTemplate: "||")
            
            // 按标记分割，并过滤空字符串（处理可能的开头空值）
            var components = markedString.components(separatedBy: "||").filter { !$0.isEmpty }
                
                // 过滤可能的空字符串（若字符串以分隔符开头，第一个元素可能为空）
            components = components.filter { !$0.isEmpty }
            print("解析选项：\(components)")
            return components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        } catch {
            print("解析选项正则错误：\(error)")
            return []
        }
        
        //let components = optionsString.components(separatedBy: ",")
        //return components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}

extension Question: Equatable {
    static func == (lhs: Question, rhs: Question) -> Bool {
        return lhs.id == rhs.id
    }
}
