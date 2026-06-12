import RxSwift

protocol Validatable {
    func validate() -> Observable<ValidateResult>
}

struct ValidateResult {
    let isValidate: Bool
    let message: String

    static let valid = ValidateResult(
        isValidate: true,
        message: ""
    )

    static func invalid(_ message: String) -> ValidateResult {
        ValidateResult(
            isValidate: false,
            message: message
        )
    }
}

