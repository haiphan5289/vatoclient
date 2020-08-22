//  File name   : NoteDeliveryVC.swift
//
//  Author      : Dung Vu
//  Created date: 8/14/19
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2019 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import UIKit
import RxSwift
import FwiCore
import FwiCoreRX

protocol NoteDeliveryPresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    
    var noteTextConfig: NoteTextConfig { get }
    func moveBack()
    func update(note: NoteDeliveryModel)
}

final class NoteDeliveryVC: UIViewController, NoteDeliveryPresentable, NoteDeliveryViewControllable {
    
    private(set) lazy var disposeBag = DisposeBag()
    
    private struct Config {
        static let titleText = Text.noteTitle.localizedText
        static let NotePlaceholder = Text.notePakage.localizedText
        static let confirmButton = Text.confirm.localizedText
    }
    
    /// Class's public properties.
    weak var listener: NoteDeliveryPresentableListener?
    @IBOutlet weak var noteView: UIView?
    @IBOutlet weak var lbTitle: UILabel?
    @IBOutlet weak var textView: UITextView?
    @IBOutlet weak var btnClose: UIButton?
    @IBOutlet weak var placeHolderLabel: UILabel?
//    @IBOutlet weak var tfNote: UITextField?
    
    @IBOutlet weak var btnConfirm: UIButton!
    
    private lazy var mContainer: HeaderCornerView = {
        let v = HeaderCornerView(with: 14)
        v.containerColor = .white
        return v
    }()

    private var arrayCell = [NotePakageSizeTableViewCell]()
    private var noteDelivery: NoteDeliveryModel?
    
    /// Class's constructors.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, noteDelivery note: NoteDeliveryModel?) {
        self.noteDelivery = note
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        visualize()
        setupRX()
        makeDataSource()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        textView?.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView?.resignFirstResponder()
    }

    /// Class's private properties.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first else {
            return
        }
        
        let p = point.location(in: self.view)
        guard self.containerView?.frame.contains(p) == false else {
            return
        }
        self.listener?.moveBack()
    }
}

// MARK: View's event handlers
extension NoteDeliveryVC {
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

// MARK: Class's public methods
extension NoteDeliveryVC {
}

// MARK: Class's private methods
private extension NoteDeliveryVC {
    private func localize() {
        // todo: Localize view's here.
        lbTitle?.text = listener?.noteTextConfig.titleText
        self.placeHolderLabel?.text = listener?.noteTextConfig.notePlaceholder
        self.textView?.tintColor = Color.orange
        btnConfirm?.setTitle(listener?.noteTextConfig.confirmButton, for: .normal)
    }
    
    private func visualize() {
        // todo: Visualize view's here.
        noteView?.backgroundColor = .clear
        noteView?.insertSubview(mContainer, at: 0)
        mContainer >>> {
            $0.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
        }
    }
    
    private func makeDataSource() {
        if self.noteDelivery == nil {
            self.noteDelivery = NoteDeliveryModel(note: nil, option: nil)
        }
    }
    
    private func setupRX() {
        
        self.textView?.text = noteDelivery?.note
        self.placeHolderLabel?.isHidden = !(self.textView?.text.count ?? 0 > 0)
        
        self.textView?.rx.text.map({ !($0?.count == 0) }).bind { [weak self] in
            self?.placeHolderLabel?.isHidden = $0
            }.disposed(by: disposeBag)
        
        self.btnClose?.rx.tap.bind { [weak self] in
            self?.listener?.moveBack()
        }.disposed(by: disposeBag)
        
        self.btnConfirm?.rx.tap.bind { [weak self] in
            guard let wSelf = self, var deliveryNote = wSelf.noteDelivery else {
                return
            }
        
            deliveryNote.note = wSelf.textView?.text
            wSelf.listener?.update(note: deliveryNote)
        }.disposed(by: disposeBag)
        
        setupKeyboardAnimation()
    }
}

extension NoteDeliveryVC: KeyboardAnimationProtocol {
    var containerView: UIView? {
        return noteView
    }
}

