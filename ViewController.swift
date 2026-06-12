//
//  ViewController.swift
//  FormValidate
//
//  Created by 630177 on 19/5/2569 BE.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var emailTextView: UITextField!
    @IBOutlet weak var telTextView: UITextField!
    
    @IBOutlet weak var subFormSwitch: UISwitch!
    @IBOutlet weak var subForm: SubForm!
    
    @IBOutlet weak var nextButton: UIButton!
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setEnableButton(isEnable: false)
        setup()
        bind()
    }
    
    func setup() {
        nextButton.setTitleColor( .white , for: .normal)
        nextButton.layer.cornerRadius = 10
    }
    
    func bind() {
        
        disposeBag = DisposeBag()
        subFormSwitch.rx.isOn.bind { [weak self] value in
            UIView.animate(withDuration: 0.3) {
                self?.subForm.alpha = value ? 1 : 0
                self?.subForm.isHidden = !value
            }
        }.disposed(by: disposeBag)
    }
    
    func setEnableButton( isEnable: Bool, inValidString: String? = "Not Valid" ) {
        nextButton.backgroundColor = isEnable ? .systemBlue : .systemPink
        nextButton.setTitle( isEnable ? "Valid" : inValidString , for: .normal)
    }
}


class SubForm: UIStackView {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
}
