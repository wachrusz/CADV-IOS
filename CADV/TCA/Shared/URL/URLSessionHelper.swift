//
//  SessionHelper.swift
//  CADV
//
//  Created by Misha Vakhrushin on 12.02.2025.
//

class URLSessionHelper: NSObject, URLSessionDelegate {
    static let shared = URLSessionHelper()

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, urlCredential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
