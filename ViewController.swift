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
        
        validate().bind { [weak self] result in
            print("update \(result)")
            self?.setEnableButton(isEnable: result.isValidate, inValidString: result.message )
        }.disposed(by: disposeBag)
    }
    
    func setEnableButton( isEnable: Bool, inValidString: String? = "Not Valid" ) {
        nextButton.backgroundColor = isEnable ? .systemBlue : .systemPink
        nextButton.setTitle( isEnable ? "Valid" : inValidString , for: .normal)
    }
}


class SubForm: UIStackView, Validatable {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    func validate() -> Observable<ValidateResult> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            let allField = Observable<ValidateResult>.combineLatest([
                self.firstName.validate(),
                self.lastName.validate(),
            ]).map { allResult -> ValidateResult in
                if let nonValid = allResult.first(where: { result in
                    result.isValidate == false
                }) {
                    return nonValid
                } else {
                    return .valid
                }
            }
            
            return allField.bind(to: observer)
        }
    }
}

extension ViewController: Validatable {
    func validate() -> Observable<ValidateResult> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            let subFormValidate = self.subFormSwitch.rx.isOn.flatMapLatest { isOn -> Observable<ValidateResult> in
                return isOn ? self.subForm.validate() : .just(.valid)
            }
            
            let allField = Observable<ValidateResult>.combineLatest([
                self.emailTextView.validate(),
                self.telTextView.validate(),
                subFormValidate
            ]).map { allResult -> ValidateResult in
                if let nonValid = allResult.first(where: { result in
                    result.isValidate == false
                }) {
                    return nonValid
                } else {
                    return .valid
                }
            }
            
            return allField.bind(to: observer)
        }
    }
}

extension UITextField: Validatable {
    func validate() -> Observable<ValidateResult> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            return self.rx.text.map { text -> ValidateResult in
                return text?.isEmpty == true ? .invalid("\(self.placeholder ?? "Textfield") isEmpty") : .valid
            }.bind(to: observer)
        }
    }
}
