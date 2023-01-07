//
//  LoginViewModel.swift
//  RxAuthorization
//
//  Created by Vladimir Alecseev on 27.12.2022.
//

import Foundation
import RxRelay
import RxSwift
import RxCocoa

protocol LoginViewModelInputs {
    
    func didChange(email: String)
    func didChange(password: String)
    func submit()
}

protocol LoginViewModelOutputs {
    
    var isEmailValid: PublishRelay<Bool> { get }
    var isPasswordValid: PublishRelay<Bool> { get }
    var isEnableLoginButton: PublishRelay<Bool> { get }
    var loginResult: PublishRelay<Bool> { get }
    var activityIndacatorState: PublishRelay<Bool> { get }
}

protocol LoginViewModelTypes: LoginViewModelInputs, LoginViewModelOutputs {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

class LoginViewModel: LoginViewModelTypes {
    var activityIndacatorState: PublishRelay<Bool> = PublishRelay()

    var inputs: LoginViewModelInputs { self }
    var outputs: LoginViewModelOutputs { self }
    
    var isEmailValid: PublishRelay<Bool> = PublishRelay()
    var isPasswordValid: PublishRelay<Bool> = PublishRelay()
    
    var isEnableLoginButton: PublishRelay<Bool> = PublishRelay()
    var loginResult: PublishRelay<Bool> = PublishRelay()
    
    private let disposeBag = DisposeBag()
    private var didChangeEmailProperty = PublishSubject<String>()
    private var didChangePasswordProperty = PublishSubject<String>()
    
    init(){

        didChangeEmailProperty
            .observe(on: MainScheduler.asyncInstance)
            .map({$0.validate(ofType: .email) })
            .bind(to: isEmailValid)
            .disposed(by: disposeBag)
        
        didChangePasswordProperty
            .observe(on: MainScheduler.asyncInstance)
            .map({$0.validate(ofType: .password)})
            .bind(to: isPasswordValid)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(isEmailValid, isPasswordValid).map { email, password in
            return email && password
        }
        .bind(to: isEnableLoginButton)
        .disposed(by: disposeBag)
        
    }
    
    func submit(){
        activityIndacatorState.accept(true)
        let emailAndPass = Observable.combineLatest(didChangeEmailProperty.share(),
                                                    didChangePasswordProperty.share()){
            (email: $0, pass: $1)
        }

        //api request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){ [unowned self] in
            print("succesed with \(emailAndPass)")
            activityIndacatorState.accept(false)
            loginResult.accept(true)
        }
    }

    
    func didChange(email: String) {
        didChangeEmailProperty.onNext(email)
    }
    
    func didChange(password: String) {
        didChangePasswordProperty.onNext(password)
    }
}

