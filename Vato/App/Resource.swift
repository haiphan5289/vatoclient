import UIKit

// MARK: Constant
struct ZoneConstant {
    static let vn = 1
}

struct PromotionConfig {
    static let titleWarningPromotion = Text.warningPromotion.localizedText
    static let titleWarningMessagePromotion = Text.warningMessagePromotion.localizedText
    static let titleWarningReviewPromotion = Text.warningReviewPromotion.localizedText
    static let titleWarningOKPromotion = Text.warningPromotion.localizedText
    
    static let errorTitle = Text.error.localizedText
    static let noticeTitle = Text.notification.localizedText
    static let ok = Text.dismiss.localizedText
    
    static let noItemMessage = Text.noPromotion.localizedText
    static let title = Text.yourPromotion.localizedText
    static let placeHolderSearch = Text.inputYourPromotionCode.localizedText
    static let cancelText = Text.cancel.localizedText
    static let bookTitle = Text.quickBooking.localizedText
    static let copy = Text.copy.localizedText
    static let validTo = Text.validTo.localizedText
    static let searchNotFound = Text.searchPromotionNotFound.localizedText
    static let promotionIcon = "ic_promotion_item"
    // Apply
    static let promotionApplySuccess = Text.promotionApplySuccess.localizedText
    static let promotionApplyForAllError = Text.promotionApplyForAllError.localizedText
    static let promotionNotFound = Text.promotionNotFound.localizedText
    static let promotionExceedDay = Text.promotionExceedDay.localizedText
    static let promotionApplyCodeError = Text.promotionApplyCodeError.localizedText
    static let promotionSuccessColor = #colorLiteral(red: 0, green: 0.5333333333, blue: 0.2196078431, alpha: 1)
    static let promotionSuccessBGColor = #colorLiteral(red: 0.9215686275, green: 0.9764705882, blue: 0.9176470588, alpha: 1)
    
    static let promotionErrorColor = #colorLiteral(red: 0.662745098, green: 0.4823529412, blue: 0, alpha: 1)
    static let promotionErrorBGColor = #colorLiteral(red: 1, green: 0.9411764706, blue: 0.7803921569, alpha: 1)
    static let detailPrice = Text.detailPrice.localizedText
    static let detroyPromotion = Text.detroyPromotion.localizedText
}

struct Regex {
    static let email = "[A-Z0-9a-z._%+-]{2,}@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let fullname = "^\\w+(\\s+\\w+){1,4}$"
}

enum AuthenticationError: Error {
    case cannotVerifyPhoneNumber(e: Error)
    case empty(s: String?)

    case invalidVerificationCode(e: Error)
    case invalidFirebaseAuthenticatedData

    case invalidSocialAccount(accountName: String)
    case socialLinkFail(e: Error)

    case tokenFail(error: Error)
    case tokenEmpty(s: String?)
    case unknown
}

struct ButtonConfig {
    static let height: CGFloat = 48
    static let spaceButton: CGFloat = 8
}

struct MapConfig {
    struct Zoom {
        static let min: Float = 11
        static let max: Float = 20
    }
}

// MARK: Color
struct Color {
    static let darkGreen = #colorLiteral(red: 0, green: 0.3803921569, blue: 0.2392156863, alpha: 1) // Primary green
    static let orange = #colorLiteral(red: 0.937254902, green: 0.3215686275, blue: 0.1333333333, alpha: 1) // Primary orange

    static let battleshipGrey = #colorLiteral(red: 0.3882352941, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
    static let colorSelectService = #colorLiteral(red: 0.9294117647, green: 0.368627451, blue: 0.1411764706, alpha: 0.2)
    static let greyishBrown = #colorLiteral(red: 0.3098039216, green: 0.3098039216, blue: 0.3098039216, alpha: 1)
    static let battleshipGreyTwo = #colorLiteral(red: 0.6352941176, green: 0.6705882353, blue: 0.7019607843, alpha: 1)
    static let black40 = #colorLiteral(red: 0.06666666667, green: 0.06666666667, blue: 0.06666666667, alpha: 0.4)
    static let reddishOrange60 = #colorLiteral(red: 0.9215686275, green: 0.368627451, blue: 0.1411764706, alpha: 0.6)
    static let battleshipGreyThree = #colorLiteral(red: 0.3607843137, green: 0.4470588235, blue: 0.5019607843, alpha: 1)
}

struct Padding {
    static let left: CGFloat = 16.0
    static let right: CGFloat = 16.0
    static let bottom: CGFloat = 16.0
    static let top: CGFloat = 16.0
}

struct StyleView {
    let tint: UIColor
    let background: UIColor

    static let `default` = StyleView(tint: .white, background: Color.orange)
    static let cancel = StyleView(tint: .white, background: .white)
    static let disable = StyleView(tint: .white, background: Color.battleshipGrey)
    
    static let newDefault = StyleView(tint: .white, background: .white)
}

struct StyleButton {
    let view: StyleView
    let textColor: UIColor
    let font: UIFont
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let borderColor: UIColor

    static let `default` = StyleButton(view: .default, textColor: .white, font: .systemFont(ofSize: 16, weight: .semibold), cornerRadius: 8, borderWidth: 1, borderColor: .clear)
    static let cancel = StyleButton(view: .cancel, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), font: .systemFont(ofSize: 16, weight: .semibold), cornerRadius: 8, borderWidth: 1, borderColor: #colorLiteral(red: 0.8005949259, green: 0.8212553859, blue: 0.8408017755, alpha: 1))
    static let disable = StyleButton(view: .disable, textColor: .white, font: .systemFont(ofSize: 16, weight: .semibold), cornerRadius: 8, borderWidth: 1, borderColor: .clear)
    
    static let newDefault = StyleButton(view: .newDefault, textColor: Color.orange, font: .systemFont(ofSize: 15, weight: .medium), cornerRadius: 8, borderWidth: 0, borderColor: .clear)
    
    static let newCancel = StyleButton(view: .newDefault, textColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), font: .systemFont(ofSize: 15, weight: .medium), cornerRadius: 8, borderWidth: 0, borderColor: .clear)
}

extension UIView {
    func apply(style: StyleView) {
        self.tintColor = style.tint
        self.backgroundColor = style.background
    }

    func applyCustom(block: () -> StyleView) {
        let style = block()
        self.apply(style: style)
    }
}

extension UIButton {
    func applyButton(style: StyleButton, state: UIControl.State = .normal, needSet: Bool = true) {
        self.apply(style: style.view)
        self.setTitleColor(style.textColor, for: state)
        guard needSet else {
            return
        }
        self.titleLabel?.font = style.font
        self.layer.cornerRadius = style.cornerRadius
        self.layer.borderWidth = style.borderWidth
        self.layer.borderColor = style.borderColor.cgColor
    }

    func applyButtonWithoutBackground(style: StyleButton) {
        self.setTitleColor(style.textColor, for: .normal)
        self.titleLabel?.font = style.font
        self.layer.cornerRadius = style.cornerRadius
        self.layer.borderWidth = style.borderWidth
        self.layer.borderColor = style.borderColor.cgColor
    }

    func setBackground(using color: UIColor, state: UIControl.State) {
        let img = UIImage.image(from: color, with: CGSize(width: 5, height: 5))
        self.setBackgroundImage(img, for: state)
    }

    func circle() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }

    func shadow() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
    }
}


struct MapResource {
    static var urlMapFile = Bundle.main.url(forResource: "custom-map", withExtension: "json")
}
