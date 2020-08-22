//  File name   : NoteVC.swift
//
//  Author      : Dung Vu
//  Created date: 9/19/18
//  Version     : 1.00
//  --------------------------------------------------------------
//  Copyright © 2018 Vato. All rights reserved.
//  --------------------------------------------------------------

import RIBs
import RxCocoa
import RxSwift
import SnapKit
import UIKit
import FwiCoreRX

protocol NotePresentableListener: class {
    // todo: Declare properties and methods that the view controller can invoke to perform
    // business logic, such as signIn(). This protocol is implemented by the corresponding
    // interactor class.
    func previousNote() -> Observable<String>
    func update(note text: String?)
    func cancel()
}

final class NoteVC: UIViewController, NotePresentable, NoteViewControllable {
    /// Class's public properties.
    weak var listener: NotePresentableListener?
    private lazy var noteView: NoteView = self.createNoteView()
    private(set) lazy var disposeBag = DisposeBag()

    // MARK: View's lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRX()
        visualize()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        localize()
        self.noteView.textView?.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.noteView.textView?.resignFirstResponder()
        super.viewWillDisappear(animated)
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
        self.listener?.cancel()
    }
}

// MARK: Class's public methods
extension NoteVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            textView.resignFirstResponder()
//            return false
//        }

        let current = textView.text as NSString?
        let new = current?.replacingCharacters(in: range, with: text)
        return !((new?.count ?? 0) > TextInput.maximumCharacterNote)
    }
}

// MARK: Class's private methods
private extension NoteVC {
    private func localize() {
        // todo: Localize view's here.
    }

    private func createNoteView() -> NoteView {
        let v = NoteView.loadXib() >>> self.view >>> {
            let h = $0.frame.height
            $0.snp.makeConstraints({ make in
                make.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(h)
            })
        }
        return v
    }

    private func visualize() {
        // todo: Visualize view's here.
        self.view.backgroundColor = Color.black40
        self.listener?.previousNote().filter({ !$0.isEmpty }).subscribe(onNext: { [weak self] notePrevious in
            self?.noteView.textView?.text = notePrevious
            self?.noteView.btnConfirm?.isEnabled = true
            self?.noteView.lblPlaceHolder?.isHidden = true
            self?.noteView.btnClear?.isHidden = false
        }).dispose()
    }

    private func setupRX() {
        // todo: Bind data to UI here.
        self.noteView.textView?.rx.setDelegate(self).disposed(by: disposeBag)
        // Keyboard
        setupKeyboardAnimation()

        self.noteView.btnCancel?.rx.tap.bind { [weak self] in
            self?.listener?.cancel()
        }.disposed(by: disposeBag)

        self.noteView.btnConfirm?.rx.tap.bind { [weak self] in
            self?.listener?.update(note: self?.noteView.textView?.text)
        }.disposed(by: disposeBag)

        self.noteView.textView?.rx.text.map({ !($0?.count == 0) }).bind { [weak self] in
            self?.noteView.lblPlaceHolder?.isHidden = $0
            self?.noteView.btnClear?.isHidden = !$0
        }.disposed(by: disposeBag)

        self.noteView.btnClear?.rx.tap.bind { [weak self] in
            self?.noteView.textView?.text = ""
            self?.noteView.lblPlaceHolder?.isHidden = false
            self?.noteView.btnClear?.isHidden = true
        }.disposed(by: disposeBag)
    }
}

extension NoteVC: KeyboardAnimationProtocol {
    var containerView: UIView? {
        return noteView
    }
}
