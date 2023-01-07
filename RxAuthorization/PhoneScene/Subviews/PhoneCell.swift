//
//  PhoneCell.swift
//  RxAuthorization
//
//  Created by Vladimir Alecseev on 28.12.2022.
//

import UIKit
import RxSwift

class PhoneCell: UICollectionViewCell{
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 5
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = 1
        setSubviews()
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let label: UILabel = {
        let l = UILabel()
        l.text = "•"
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.boldSystemFont(ofSize: 15)
       return l
    }()
    
}


extension PhoneCell{
    func setConstraints(){
        label.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(5)
            make.bottom.right.equalToSuperview().offset(-5)
        }
    }
    func setSubviews(){
        addSubview(label)
    }
    func updateNumberWith(_ number: String) {
        label.fadeTransition(0.3)
        label.text = number
    }
    
    func setPhoneValidTheme(){
        UIView.animate(withDuration: 0.5) { [unowned self] in
            layer.borderColor = UIColor.green.cgColor
            layer.borderWidth = 2
            label.font = UIFont.boldSystemFont(ofSize: 18)
        }
        
    }
    func setPhoneInvalidTheme(){
        UIView.animate(withDuration: 0.5) { [unowned self] in
            layer.borderColor = UIColor.black.cgColor
            layer.borderWidth = 1
            label.font = UIFont.boldSystemFont(ofSize: 15)
        }
    }
    
}
