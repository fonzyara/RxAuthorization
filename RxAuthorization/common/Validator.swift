//
//  Validator.swift
//  RxAuthorization
//
//  Created by Vladimir Alecseev on 27.12.2022.
//

import Foundation
enum ValidateRegex: String {
    case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    case password = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{1,16}$"
    case phone = "^\\d{3}\\d{3}\\d{4}$"
}

extension String{
    
    func validate(ofType: ValidateRegex) -> Bool{
        switch ofType {
        case .email:
            guard isValid(from: ValidateRegex.email.rawValue, input: self) else {
                return false
            }
            return true
        case .password:
            guard isValid(from: ValidateRegex.password.rawValue, input: self) else {
                return false
            }
            return true
        case .phone:
            guard isValid(from: ValidateRegex.phone.rawValue, input: self) else {
                return false
            }
            return true
        }
    }
    
    private func isValid(from regex: String, input: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: input)
    }
}
