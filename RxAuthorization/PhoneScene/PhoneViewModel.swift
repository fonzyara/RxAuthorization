//
//  PhoneViewModel.swift
//  RxAuthorization
//
//  Created by Vladimir Alecseev on 28.12.2022.
//

import Foundation
import RxRelay
import RxSwift
import RxCocoa

protocol PhoneViewModelInputs {
    func didChange(newText: String)
    func submit()
}

protocol PhoneViewModelOutputs {
    var allPhone: PublishRelay<String> {get}
    var lastEnteredDigit: PublishRelay<String> {get}
    var isPhoneValid: PublishRelay<Bool> {get}
    var enteredPhoneLength: Int {get}
    var trimPhoneAtHiddenTextField: PublishRelay<String> {get}
    var activityIndicatorState: PublishRelay<Bool> {get}
    var submitResult: PublishRelay<Bool> {get}
}

protocol PhoneViewModelTypes: PhoneViewModelInputs, PhoneViewModelOutputs {
    var inputs: PhoneViewModelInputs { get }
    var outputs: PhoneViewModelOutputs { get }
}

class PhoneViewModel: PhoneViewModelTypes {
    var inputs: PhoneViewModelInputs  { self }
    var outputs: PhoneViewModelOutputs  { self }
    
    
    var allPhone: PublishRelay<String> = PublishRelay()
    var lastEnteredDigit: PublishRelay<String> = PublishRelay()
    var isPhoneValid: PublishRelay<Bool> = PublishRelay()
    var enteredPhoneLength = 0
    var trimPhoneAtHiddenTextField: PublishRelay<String> = PublishRelay()
    var activityIndicatorState: PublishRelay<Bool> = PublishRelay()
    var submitResult: PublishRelay<Bool> = PublishRelay()

    
    private let disposeBag = DisposeBag()

    init(){
        allPhone.map({$0.count})
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { [unowned self] length in
                enteredPhoneLength = length
            })
            .disposed(by: disposeBag)
        
        allPhone
            .observe(on: MainScheduler.asyncInstance)
            .map({String($0.last ?? " ")})
            .bind(to: lastEnteredDigit)
            .disposed(by: disposeBag)
        
        allPhone
            .observe(on: MainScheduler.asyncInstance)
            .map({$0.validate(ofType: .phone)})
            .distinctUntilChanged()
            .bind(to: isPhoneValid)
            .disposed(by: disposeBag)
        
    }
    
    func didChange(newText: String) {
        guard newText.count <= 10 else {
            let str = String(newText.prefix(10))
            trimPhoneAtHiddenTextField.accept(str)
            return
        }
        allPhone.accept(newText)
        print(newText)
    }
    
    func submit(){
        activityIndicatorState.accept(true)

        //api request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){ [unowned self] in
            print("succesed with: +7\(allPhone)")
            activityIndicatorState.accept(false)
            submitResult.accept(true)
        }
    }

}
