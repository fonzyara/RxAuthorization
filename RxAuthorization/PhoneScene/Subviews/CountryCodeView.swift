//
//  CountryCodeView.swift
//  RxAuthorization
//
//  Created by Vladimir Alecseev on 28.12.2022.
//

import UIKit
import SnapKit
class CountryCodeView: UIView{
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
        l.text = "+7"
        l.textAlignment = .center
        l.textColor = .black
        l.font = UIFont.boldSystemFont(ofSize: 15)
       return l
    }()
}
extension CountryCodeView{
    func setConstraints(){
        label.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(5)
            make.bottom.right.equalToSuperview().offset(-5)
        }
    }
    func setSubviews(){
        addSubview(label)
    }
}
