//
//  Utility.swift
//  CADV
//
//  Created by Misha Vakhrushin on 16.09.2024.
//

import Foundation
import SwiftUI

func textFieldValidatorEmail(_ string: String) -> Bool {
    if string.count > 64 || string.isEmpty || string.count < 2 {
        return false
    }
    let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
    return emailPredicate.evaluate(with: string)
}

extension Date {
    func monthDayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }
}

extension View {
    func hideBackButton() -> some View {
        self.modifier(HideBackButtonModifier())
    }
}

struct HideBackButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}

func formattedTotalAmount(amount: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2
    formatter.usesGroupingSeparator = true
    formatter.groupingSeparator = "."
    
    if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
        return formattedAmount
    }
    return "\(amount)"
}

func getNumberOfPages(itemsPerPage: Int = 20, itemsArray: [Any]) -> Int {
    return (itemsArray.count + itemsPerPage - 1) / itemsPerPage
}

func getTransactionsForPage(pageIndex: Int, groupedTransactions: [(date: Date, transactions: [Transaction])]) -> [(date: Date, transactions: [Transaction])] {
    let start = pageIndex * 5
    let end = min(start + 5, groupedTransactions.count)
    return Array(groupedTransactions[start..<end])
}

func getGroupedTransactions(_ transactions: [Transaction]) -> [(date: Date, transactions: [Transaction])] {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"

    let grouped = Dictionary(grouping: transactions) { transaction -> Date in
        if let date = dateFormatter.date(from: transaction.date) {
            return Calendar.current.startOfDay(for: date)
        } else {
            return Date()
        }
    }
    
    return grouped.map { (key: Date, value: [Transaction]) in
        (date: key, transactions: value)
    }
}

func currencyCodeToSymbol(code: String) -> String{
    switch code{
    case "RUB":
        return "₽"
    case "EUR":
        return "€"
    case "USD":
        return "$"
    default:
        return "₽"
    }
}

func currencyCodeAndTypeToSymbol(type: TransactionType, code: String) -> String {
    switch code{
    case "RUB":
        return "\(type.rawValue == "Доход" ? "+" : "-")₽"
    case "EUR":
        return "\(type.rawValue == "Доход" ? "+" : "-")€"
    case "USD":
        return "\(type.rawValue == "Доход" ? "+" : "-")$"
    default:
        return "\(type.rawValue == "Доход" ? "+" : "-")₽"
    }
}


func abstractFetchData(
    endpoint: String,
    method: String = "POST",
    parameters: [String: Any] = [:],
    headers: [String: String] = [:],
    completion: @escaping (Result<[String: Any], Error>) -> Void
) {
    var urlString = "HOST/\(endpoint)"
    
    if method == "GET", !parameters.isEmpty {
        let queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = queryItems
        urlString = urlComponents?.url?.absoluteString ?? urlString
    }
    
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    
    for (key, value) in headers {
        request.setValue(value, forHTTPHeaderField: key)
    }
    
    if method == "POST" || method == "PUT" {
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Failed to encode JSON")
            return
        }
    }
    
    let sessionConfig = URLSessionConfiguration.default
    let session = URLSession(configuration: sessionConfig, delegate: URLSessionHelper.shared, delegateQueue: nil)
    
    let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Request failed with error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            return
        }
        
        if let response = response as? HTTPURLResponse, let data = data {
            do {
                let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                switch response.statusCode {
                case 200:
                    completion(.success(responseObject ?? [:]))
                case 401:
                    completion(.success(responseObject ?? [:]))
                case 500:
                    completion(.success(responseObject ?? [:]))
                default:
                    let error = NSError(domain: "", code: response.statusCode, userInfo: ["response": responseObject ?? [:]])
                    completion(.failure(error))
                }
            } catch {
                print("Failed to parse JSON response")
                completion(.failure(error))
            }
        }
    }
    task.resume()
}

func stringToDate(_ dateString: String) -> Date? {
    let dateFormatter = ISO8601DateFormatter()
    
    if dateString.contains(".") {
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    } else {
        dateFormatter.formatOptions = [.withInternetDateTime]
    }

    if let date = dateFormatter.date(from: dateString) {
        return date
    } else {
        print("Ошибка: Не удалось преобразовать строку в дату.")
        return nil
    }
}

func monthsBetween(startDate: Date, endDate: Date) -> CGFloat? {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.month], from: startDate, to: endDate)
    return CGFloat(components.month ?? 1)
}

func monthsPassedInts(from startDateString: String, to endDateString: String) -> (CGFloat, CGFloat) {
    guard let startDate = stringToDate(startDateString), let endDate = stringToDate(endDateString) else {
        return (0, 1)
    }
    
    guard let monthsTotal = monthsBetween(startDate: startDate, endDate: endDate) else {
        return (0, 1)
    }
    
    let monthsPassed = monthsBetween(startDate: startDate, endDate: Date()) ?? 1
    
    return (monthsPassed, monthsTotal)
}
