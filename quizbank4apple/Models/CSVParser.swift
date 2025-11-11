//
//  CSVParser.swift
//  quizbank4apple
//
//  Created by zihao hu on 11/11/25.
//

import Foundation

class CSVParser {
    static func parseCSV(from fileName: String, extension: String = "csv") throws -> [Question] {
        // 尝试在主Bundle中查找文件
        let fileName = "QuizBanks/" + fileName
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "csv") else {
            print("无法找到文件: \(fileName).csv，Bundle路径: \(Bundle.main.bundlePath)")
            // 列出Bundle中的所有文件用于调试
            let bundlePath = Bundle.main.bundlePath
            let fileManager = FileManager.default
            do {
                let files = try fileManager.contentsOfDirectory(atPath: bundlePath)
                print("Bundle中的文件: \(files)")
            } catch {
                print("无法列出Bundle文件: \(error)")
            }
            throw ParseError.fileNotFound(fileName)
        }

        let data = try String(contentsOf: url, encoding: .utf8)
        let lines = data.components(separatedBy: .newlines)

        var questions: [Question] = []
        var headers: [String] = []

        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLine.isEmpty else { continue }

            if index == 0 {
                // 解析标题行
                headers = parseHeaders(trimmedLine)
                continue
            }

            // 解析数据行
            do {
                let question = try parseQuestion(from: trimmedLine, headers: headers, questionBank: fileName)
                questions.append(question)
            } catch {
                print("解析第\(index + 1)行时出错: \(error)")
            }
        }

        return questions
    }

    private static func parseHeaders(_ line: String) -> [String] {
        let components = parseCSVLine(line)
        return components.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private static func parseCSVLine(_ line: String) -> [String] {
        var components: [String] = []
        var currentComponent = ""
        var inQuotes = false

        for character in line {
            if character == "\"" {
                inQuotes.toggle()
            } else if character == "," && !inQuotes {
                components.append(currentComponent.trimmingCharacters(in: .whitespacesAndNewlines))
                currentComponent = ""
            } else {
                currentComponent.append(character)
            }
        }

        components.append(currentComponent.trimmingCharacters(in: .whitespacesAndNewlines))
        return components
    }

    private static func parseQuestion(from line: String, headers: [String], questionBank: String) throws -> Question {
        let components = parseCSVLine(line)

        guard components.count >= headers.count else {
            throw ParseError.invalidFormat("列数不匹配")
        }

        var questionData: [String: String] = [:]
        for (index, header) in headers.enumerated() {
            if index < components.count {
                questionData[header] = components[index]
            }
        }

        guard let questionIdString = questionData[""],
              let questionId = Int(questionIdString) else {
            throw ParseError.invalidFormat("缺少必要字段 number")
        }
        guard let yearString = questionData["grade"],
              let year = Int(yearString) else {
            throw ParseError.invalidFormat("缺少必要字段 grade")
        }
        guard let moduleString = questionData["module"],
              let module = Int(moduleString)else {
            throw ParseError.invalidFormat("缺少必要字段 module")
        }
        guard let weekString = questionData["week"],
              let week = Int(weekString) else {
            throw ParseError.invalidFormat("缺少必要字段 week")
        }
        guard let questionText = questionData["question_stem"] else {
            throw ParseError.invalidFormat("缺少必要字段 question_stem")
        }
        guard let optionsString = questionData["choice"] else {
            throw ParseError.invalidFormat("缺少必要字段 choice")
        }
        guard let correctAnswer = questionData["correct_answer"] ?? questionData["answer"] else {
            throw ParseError.invalidFormat("缺少必要字段 correct_answer")
        }

        let options = Question.parseOptions(optionsString)
        guard options.count >= 2 else {
            throw ParseError.invalidFormat("选项数量不足")
        }

        return Question(
            questionId: questionId,
            year: year,
            module: module,
            week: week,
            questionText: questionText,
            options: options,
            correctAnswer: correctAnswer,
            questionBank: questionBank
        )
    }

    static func getAvailableQuestionBanks() -> [String] {
        // 直接返回已知的题库名称
        //return ["M5_week1", "M5_week2", "M5_week3"]
        
        //备用：从Bundle读取（如果需要动态读取的话）
        
        guard let dataDirectoryPath = Bundle.main.path(forResource: "QuizBanks", ofType: nil) else {
            print("QuizBanks 文件夹不存在于 Bundle 中")
            //let dataDirectoryPath = Bundle.main.path(forResource: "M1_week1", ofType: "csv")
            //print(dataDirectoryPath)
            return []
        }
        let dataDirectoryURL = URL(fileURLWithPath: dataDirectoryPath)
        do {
            // 读取 data 文件夹中的所有文件 URL
            let fileURLs = try FileManager.default.contentsOfDirectory(at: dataDirectoryURL, includingPropertiesForKeys: nil)
            
            // 处理文件（例如筛选 CSV 文件并去除后缀，延续之前的逻辑）
            let csvFileNames = fileURLs
                .compactMap { $0.lastPathComponent }
                .filter { $0.hasSuffix(".csv") }
                .map { $0.replacingOccurrences(of: ".csv", with: "") }
            
            print("读取Bundle 中 QuizBanks 题库目录：", csvFileNames)
            return csvFileNames
        } catch {
            print("读取 Bundle 中 QuizBanks 题库目录时出错：", error.localizedDescription)
            return []
        }
        /*
         let fileManager = FileManager.default
         do {
         let files = try fileManager.contentsOfDirectory(atPath: bundlePath)
         return files.filter { $0.hasSuffix(".csv") }.map { $0.replacingOccurrences(of: ".csv", with: "") }
         } catch {
         print("读取题库目录时出错: \(error)")
         return []
         }
         */
    }
}

enum ParseError: Error, LocalizedError {
    case fileNotFound(String)
    case invalidFormat(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "找不到文件: \(fileName).csv"
        case .invalidFormat(let details):
            return "格式错误: \(details)"
        }
    }
}
