//
//  LoginViewController.swift
//  RxAuthorization
//
//  Created by Vladimir Alecseev on 27.12.2022.
//
import UIKit
import RxCocoa
import RxSwift
import SnapKit

class LoginViewController: UIViewController{
    //MARK: - preperties
    private let viewModel: LoginViewModelTypes
    private let disposeBag = DisposeBag()

    //MARK: - lifecycle
    init(viewModel: LoginViewModelTypes = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray

        setSubviews()
        setConstraints()
        bindings()
    }
    
    //MARK: - subviews
    private let emailField: UITextField = {
       let tf = UITextField()
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 2
        tf.layer.borderColor = UIColor.white.cgColor
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.placeholder = "Почта"
        tf.setLeftPaddingPoints(10)
        return tf
    }()
    private let passField: UITextField = {
       let tf = UITextField()
        tf.layer.cornerRadius = 10
        tf.layer.borderWidth = 2
        tf.layer.borderColor = UIColor.white.cgColor
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "Пароль"
        tf.setLeftPaddingPoints(10)
        return tf
    }()
    
    private let loginButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .lightGray
        b.layer.cornerRadius = 20
        b.isEnabled = false
        b.setTitle("Данные не введены", for: .disabled)
        b.setTitle("Войти", for: .normal)
       return b
    }()
    
    private let invalidEmailError: UILabel = {
       let l = UILabel()
        l.text = "Почта должна иметь формат xxx@x.xx"
        l.textColor = .red
        l.isHidden = true
        l.font = UIFont.systemFont(ofSize: 13)
        return l
    }()
    
    private let invalidPassError: UILabel = {
       let l = UILabel()
        l.text = "Пароль должен содержать цифры, строчные и заглавные буквы"
        l.textColor = .red
        l.font = UIFont.systemFont(ofSize: 13)
        l.isHidden = true
        return l
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = .systemPink
        ai.style = .large
        return ai
    }()
}


private extension LoginViewController{
    //MARK: - bindings
    func bindings(){
        emailField.rx.text.orEmpty.distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: viewModel.inputs.didChange(email:))
            .disposed(by: disposeBag)
        
        passField.rx.text.orEmpty.distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: viewModel.inputs.didChange(password:))
            .disposed(by: disposeBag)
        
        viewModel.outputs.isEnableLoginButton
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.outputs.isEnableLoginButton
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [loginButton] (isEnabled) in
                loginButton.backgroundColor = isEnabled ? .blue : .lightGray
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.isEmailValid
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: invalidEmailError.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.isPasswordValid
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: invalidPassError.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.activityIndacatorState
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [activityIndicator] isActive in
                if isActive {
                    activityIndicator.startAnimating()
                } else {
                    activityIndicator.stopAnimating()
                }
            }.disposed(by: disposeBag)
        
        viewModel.outputs.loginResult
            .subscribe { [unowned self] isSuccesed in
                
                navigationController?.show(PhoneViewController(), sender: self)
            print("isLoginnSuccesed: \(isSuccesed)")
            }.disposed(by: disposeBag)
        
        loginButton.rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [unowned self] _ in
            viewModel.inputs.submit()
            activityIndicator.startAnimating()
        }.disposed(by: disposeBag)
        
        
        
        
        let gesture = UITapGestureRecognizer()
        gesture.rx.event
            .subscribe { [view] tap in
                view?.endEditing(false)
            }
            .disposed(by: disposeBag)
        
        view.addGestureRecognizer(gesture)
    }
    //MARK: - constraints
    func setConstraints(){
        emailField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(150)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        invalidEmailError.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(3)
            make.left.equalTo(emailField.snp.left)
            make.height.equalTo(30)
        }
        passField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(150)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        invalidPassError.snp.makeConstraints { make in
            make.top.equalTo(passField.snp.bottom).offset(3)
            make.left.equalTo(passField.snp.left)
            make.height.equalTo(30)
        }
        loginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.bottom.equalToSuperview().offset(-200)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    //MARK: - Set subviews
    func setSubviews(){
        view.addSubview(emailField)
        view.addSubview(passField)
        view.addSubview(loginButton)
        view.addSubview(invalidPassError)
        view.addSubview(invalidEmailError)
        view.addSubview(activityIndicator)
    }
}

