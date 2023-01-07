//
//  PhoneViewController.swift
//  RxAuthorization
//
//  Created by Vladimir Alecseev on 27.12.2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class PhoneViewController: UIViewController{
    //MARK: - properties
    private let identifier = "PhoneCell"

    private let viewModel: PhoneViewModelTypes
    private let disposeBag = DisposeBag()

    //MARK: - lifecycle
    init(viewModel: PhoneViewModelTypes = PhoneViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        setSubview()
        setConstraints()
        
        phoneCollectionView.delegate = self
        phoneCollectionView.dataSource = self
        phoneCollectionView.register(PhoneCell.self, forCellWithReuseIdentifier: identifier)
        
        bindings()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hiddenTextField.becomeFirstResponder()
    }
    //MARK: - Subviews
    private let countryCodeView = CountryCodeView()
    
    private let hiddenTextField: UITextField = {
       let tf = UITextField()
        tf.keyboardType = .numberPad
        tf.isHidden = true
        return tf
    }()
    
    private let phoneCollectionView: UICollectionView  = {
        let flow = UICollectionViewFlowLayout()
        flow.minimumLineSpacing = 5

        let c = UICollectionView(frame: .zero, collectionViewLayout: flow)
        c.isScrollEnabled = false
        c.backgroundColor = .gray
       return c
    }()
    
    private let nextButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .lightGray
        b.layer.cornerRadius = 20
        b.isEnabled = false
        b.setTitle("Данные не введены", for: .disabled)
        b.setTitle("Войти", for: .normal)
       return b
    }()
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        ai.hidesWhenStopped = true
        ai.color = .systemPink
        ai.style = .large
        return ai
    }()
}
//MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension PhoneViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PhoneCell
        return cell
    }
}

extension PhoneViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((view.bounds.width - (3 * 10)) / 12)
        
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
}

//MARK: - bindings
private extension PhoneViewController{
    func bindings(){
        phoneCollectionView.rx.itemSelected
            .observe(on: MainScheduler.asyncInstance)
            .bind { [hiddenTextField] _ in
            hiddenTextField.becomeFirstResponder()
        }.disposed(by: disposeBag)
        
        hiddenTextField.rx.text.orEmpty.distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: viewModel.inputs.didChange(newText:))
            .disposed(by: disposeBag)
        
        viewModel.outputs.trimPhoneAtHiddenTextField
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [unowned self] trimmedStr in
                hiddenTextField.text = trimmedStr.element
            }.disposed(by: disposeBag)
        
        viewModel.outputs.lastEnteredDigit
            .skip(1)
            .observe(on: MainScheduler.asyncInstance)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [unowned self] digit in
                let enteredPhoneLength = viewModel.outputs.enteredPhoneLength
                
                if enteredPhoneLength == 0 {
                    let indexpathh = IndexPath(row: viewModel.outputs.enteredPhoneLength, section: 0)
                    let celll = phoneCollectionView.cellForItem(at: indexpathh) as! PhoneCell
                    celll.updateNumberWith("•")
                }
                else if enteredPhoneLength == 10{
                    let indexpath = IndexPath(row: viewModel.outputs.enteredPhoneLength - 1, section: 0)
                    let cell = phoneCollectionView.cellForItem(at: indexpath) as! PhoneCell
                    cell.updateNumberWith(digit)
                    hiddenTextField.endEditing(false)
                }
                else {
                    let indexpath = IndexPath(row: viewModel.outputs.enteredPhoneLength - 1, section: 0)
                    let cell = phoneCollectionView.cellForItem(at: indexpath) as! PhoneCell
                    cell.updateNumberWith(digit)
                    
                    let indexpathh = IndexPath(row: viewModel.outputs.enteredPhoneLength, section: 0)
                    let celll = phoneCollectionView.cellForItem(at: indexpathh) as! PhoneCell
                    celll.updateNumberWith("•")
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.isPhoneValid
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [nextButton, phoneCollectionView] isValid in
                print("isPhoneValid: \(isValid)")
                nextButton.isEnabled = isValid
                nextButton.backgroundColor = isValid ? .blue : .gray
                
                let cells = phoneCollectionView.visibleCells as! [PhoneCell]
                cells.forEach({isValid ? $0.setPhoneValidTheme() : $0.setPhoneInvalidTheme()})
            }
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [viewModel] tap in
                viewModel.inputs.submit()
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.activityIndicatorState
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [activityIndicator] isActive in
                if isActive {
                    activityIndicator.startAnimating()
                } else {
                    activityIndicator.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
        
        
        viewModel.outputs.submitResult.subscribe { isSucsessed in
            print("is isSucsessed: \(isSucsessed)")
        }
        .disposed(by: disposeBag)
        
        
        let gesture = UITapGestureRecognizer()
        gesture.delegate = self
        gesture.rx.event
        
            .subscribe { [unowned self] tap in
                view?.endEditing(false)
            }
            .disposed(by: disposeBag)
        
        view.addGestureRecognizer(gesture)
        
    }
}
private extension PhoneViewController{
    //MARK: - Constraints
    func setConstraints(){
        let collectionViewHeight = ((view.bounds.width - (3 * 10)) / 12)
        phoneCollectionView.snp.makeConstraints { make in
            make.left.equalTo(countryCodeView.snp.right).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview().offset(-150)
            make.height.equalTo(collectionViewHeight)
        }
        hiddenTextField.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.width.height.equalTo(1)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.bottom.equalToSuperview().offset(-300)
        }
        
        let countryCodeViewHeight = (view.bounds.width - (3 * 10)) / 10
        countryCodeView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview().offset(-150)
            make.height.equalTo(countryCodeViewHeight)
            make.width.equalTo(countryCodeViewHeight)
        }
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    //MARK: - Set subviews
    func setSubview(){
        view.addSubview(phoneCollectionView)
        view.addSubview(hiddenTextField)
        view.addSubview(nextButton)
        view.addSubview(countryCodeView)
        view.addSubview(activityIndicator)
    }
}
//MARK: - gestureRecognizer delegate
extension PhoneViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
}
