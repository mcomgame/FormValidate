//
//  EkycTextField.swift
//  KPayCustomer
//
//  Created by gusguz on 15/3/2564 BE.
//  Copyright © 2564 KTB. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

enum StyleTextField: Int {
    case ekyc
    case firstPage
    case gold
    case health
    case plainText
}

open class EkycTextField: UITextField {
    var disposeBag = DisposeBag()
    var styleTextField: StyleTextField? = .ekyc
    private var _rightViewWidth: CGFloat = 0
    private var _rightViewHeight: CGFloat = 0
    private var rightImage: UIImage?
    var rightImageView = UIImageView()
    var enableErrorMode = true

    private var extensionHeight: CGFloat = 0
    var defaultCornerRadius: CGFloat = 5

    var defaultSize = CGSize.zero {
        didSet {
            errorLable.frame = CGRect(x: 16, y: defaultSize.height + 4, width: defaultSize.width, height: 17)
        }
    }
    //    var currentBorderColor
    public var activeBorderColor = UIColor(hex: "4457e3")
    public var defaultBorderColor = UIColor(hex: "e0e0e0")
    public var defaultErrorColor = UIColor(hex: "db0000")

    private var isValidated: Bool {
        get {
            return extensionHeight == 0
        }
        set {
            if newValue == false {
                extensionHeight = errorLable.frame.size.height
                floatingLabelTextColor = defaultErrorColor
                self.addSubview( errorLable )
            } else {
                extensionHeight = 0
                errorLable.removeFromSuperview()
            }
            updateSize()
        }
    }
    public var validateFunction: ((String?) -> String?)?

    lazy var errorLable: UILabel = {
        let label = UILabel()
        label.font = self.font?.withSize(14)
        label.textColor = self.defaultErrorColor
        label.numberOfLines = 0
        return label
    }()

    public enum ValidateType {
        case phone
        case mobile
        case email
        case laserId
        case citizenId
    }

    public func setValidateType(type: ValidateType) {
        switch type {
        case .mobile:
            validateFunction = mobileValidate
        case .phone:
            validateFunction = phoneValidate
        case .email:
            validateFunction = emailValidate
        case .laserId:
            validateFunction = isValidLaserCode
        case .citizenId:
            validateFunction = citizenValidate
        }
    }

    @IBInspectable var textFieldStyle: Int {
        get {
            return self.styleTextField?.rawValue ?? -1
        }
        set( textFieldStyle) {
            self.styleTextField = StyleTextField(rawValue: textFieldStyle)
        }
    }

    @IBInspectable var rightViewWidth: CGFloat {
        get {
            return self._rightViewWidth
        }

        set ( width ) {
            self._rightViewWidth = width
        }
    }

    @IBInspectable var rightViewHeight: CGFloat {
        get {
            return self._rightViewHeight
        }

        set ( height ) {
            self._rightViewHeight = height
        }
    }


    @IBInspectable var rightViewImage: UIImage? {
        get {
            return self.rightImage
        }

        set ( image ) {
            self.rightImage = image
            setupRightImage()
        }
    }
    private func setupRightImage() {
        if let rightImage = self.rightImage {
            rightImageView.image = rightImage
            rightImageView.contentMode = .scaleAspectFit
            rightViewMode = .always
            rightView = rightImageView
        }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        self.setupConstraintsPriority()
        if #available(iOS 11.0, *) {
            if keyboardType == .numberPad || keyboardType == .phonePad {
                textContentType = .username
            } else {
                textContentType = .init(rawValue: "")
            }
            autocorrectionType = .no
        }
        switch styleTextField {
        case .ekyc:
            confixTextField(
                floatingYPadding: 7,
                placeholderYPadding: 5,
                borderWidth: 1,
                borderColor: UIColor(hex: "e0e0e0"),
                cornerRadius: 8,
                placeholderColor: UIColor(hex: "838383"),
                paddingLeft: 16,
                colorActive: UIColor(hex: "4457e3")
            )
        case .health:
            self.floatingLabelFont = UIFont.kanitRegular(ofSize: 14.0)
            self.tintColor = UIColor._3ca982
            if !(self.floatingLabel.text?.isEmpty ?? false) {
                self.floatingLabelTextColor = UIColor._3ca982
            }
            confixTextField(
                floatingYPadding: 7,
                placeholderYPadding: 5,
                borderWidth: 1,
                borderColor: UIColor._e0e0e0,
                cornerRadius: 8,
                placeholderColor: UIColor._838383,
                paddingLeft: 16,
                colorActive: UIColor._3ca982
            )
        case .plainText:
            confixTextField(
                floatingYPadding: 0,
                placeholderYPadding: 0,
                borderWidth: 0,
                borderColor: .clear,
                cornerRadius: 0,
                placeholderColor: UIColor._f2f2f2,
                paddingLeft: 0,
                colorActive: UIColor.clear
            )
        default:
            confixTextField(
                floatingYPadding: 7,
                placeholderYPadding: 5,
                borderWidth: 1,
                borderColor: UIColor(hex: "F2F2F2"),
                cornerRadius: 8,
                placeholderColor: UIColor(hex: "838383"),
                paddingLeft: 16,
                colorActive: UIColor(hex: "4457e3")
            )
        }
    }
    
    @discardableResult
    public func updateValidate() -> String? {
        var errorText: String? = nil
        if self.enableErrorMode {
            errorText = self.validateFunction?( self.text )
        }
        self.setShowError(errorString: errorText)
        return errorText
    }
    
    public func setShowError( errorString: String? ) {
        self.resignFirstResponder()
        var errorText: String? {
            if let validateText = errorString, !validateText.isEmpty {
                return validateText
            } else { return nil }
        }
        
        var frame = errorLable.frame
        let width = self.frame.width - frame.origin.x
        let height = (errorText?.computeStringHeight(width, errorLable.font) ?? 17) + 5
        frame.size.width = width
        frame.size.height = height
        errorLable.frame = frame
        
        self.errorLable.text = errorText
        self.isValidated = errorText == nil
        self.setNeedsDisplay()
    }

    public func isTextFieldValidated() -> Bool {
        let errorText = validateFunction?(self.text)
        return errorText == nil
    }

    public override var intrinsicContentSize: CGSize {
        if defaultSize == CGSize.zero {
            defaultSize = super.intrinsicContentSize

            if let height = self.constraints.first(where: { $0.firstAttribute == .height } ) {
                defaultSize.height = height.constant
            }
        }
        var size = defaultSize
        size.height = (size.height + extensionHeight)
        return size
    }

    let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return updateEditBound(forBounds: rect)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return updateEditBound(forBounds: rect)
    }

    func updateEditBound(forBounds bounds: CGRect) -> CGRect {
        var rect = bounds
        rect.origin.y = (rect.origin.y - (extensionHeight * 0.5))
        return rect
    }

    func bind() {
        let disposeBag = DisposeBag()
        self.disposeBag = disposeBag
        self.rx.controlEvent(.editingDidBegin)
            .bind { [weak self] _ in
                self?.isValidated = true
                self?.setNeedsDisplay()
            }
            .disposed(by: disposeBag)

        self.rx.controlEvent(.editingDidEnd)
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.updateValidate()
            }
            .disposed(by: disposeBag)
    }

    private func updateSize() {
        self.invalidateIntrinsicContentSize()
    }

    func setupConstraintsPriority() {
        self.constraints.forEach({ constraint in
            if constraint.priority.rawValue >= 950 {
                constraint.priority = UILayoutPriority(950)
            }
        })
        self.setContentCompressionResistancePriority(UILayoutPriority(1000), for: NSLayoutConstraint.Axis.vertical)
    }

    func confixTextField(floatingYPadding: CGFloat, placeholderYPadding: CGFloat, borderWidth: CGFloat, borderColor: UIColor, cornerRadius: CGFloat, placeholderColor: UIColor, paddingLeft: CGFloat, colorActive: UIColor) {
        self.floatingLabelYPadding = floatingYPadding
        self.placeholderYPadding = placeholderYPadding
        borderStyle = .none
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        self.defaultCornerRadius = cornerRadius
        self.placeholderColor = placeholderColor
        self.activeBorderColor = colorActive
        self.defaultBorderColor = borderColor
        floatingLabelTextColor = colorActive
        floatingLabelActiveTextColor = colorActive

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: paddingLeft, height: frame.size.height))
        leftView = paddingView
        leftViewMode = .always
        bind()
    }

    public override func draw(_ rect: CGRect) {
        let height = rect.height - extensionHeight
        let width = rect.width
        let corner = self.defaultCornerRadius
        var color: UIColor {
            if self.isFirstResponder { // Active case
                floatingLabelTextColor = activeBorderColor
                return  self.activeBorderColor
            } else if isValidated == false { // Error case
                return self.defaultErrorColor
            } else if self.isEnabled == false { // Error case
                return .clear
            } else { // default case
                return self.defaultBorderColor
            }
        }
        let drect = CGRect(x: 0, y: 0, width: width, height: height)
        let bpath = UIBezierPath(roundedRect: drect, cornerRadius: corner)
        bpath.lineWidth = UIScreen.main.scale * 1
        bpath.addClip()
        color.set()
        bpath.stroke()
    }
}

public extension EkycTextField {
    func mobileValidate(text: String?) -> String? {
        guard let text = text, !text.isEmpty else { return nil }
        let phone = text.removeDashAndSpace()
        if let phoneType = PhoneStringType(text: phone), phoneType == .cellPhone {
            return nil
        }
        return "รูปแบบเบอร์มือถือไม่ถูกต้อง"
    }

    func phoneValidate(text: String?) -> String? {
        guard let text = text, !text.isEmpty else { return nil }
        let phone = text.removeDashAndSpace()
        if let phoneType = PhoneStringType(text: phone) {
            return nil
        }
        return "รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง"
    }

    func citizenValidate(text: String?) -> String? {
        guard let text = text, !text.isEmpty else { return nil }
        if text.removeDashAndSpace().citizenIdValidate() {
            return nil
        }
        return "รูปแบบเลขบัตรประชาชนไม่ถูกต้อง"
    }

    func isValidLaserCode(text: String?) -> String? {
        guard let text = text, !text.isEmpty else { return nil }
        let laserCode = text.removeDashAndSpace()
        if RegularExpression.laserCardCitizen.isValid(comparedString: laserCode) {
            return nil
        }
        return "รูปแบบรหัสหลังบัตรประชาชนไม่ถูกต้อง"
    }

    func emailValidate(text: String?) -> String? {
        guard let email = text, !email.isEmpty else { return nil }
        if  RegularExpression.email.isValid(comparedString: email) {
            return nil
        }
        return "รูปแบบอีเมลไม่ถูกต้อง"
    }
}
