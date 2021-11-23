//
//  EditUserInfoViewController.swift
//  Booster
//
//  Created by mong on 2021/11/18.
//

import UIKit
import RxCocoa
import RxSwift

final class EditUserInfoViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - Enum
    private enum genderButtonType: String {
        case male = "남"
        case female = "여"

        mutating func toggle() {
            (self == .male) ? (self = .female) : (self = .male)
        }
    }

    // MARK: - @IBOutlet
    @IBOutlet private weak var nickNameTextField: EditUserInfoTextField!
    @IBOutlet private weak var heightTextField: EditUserInfoTextField!
    @IBOutlet private weak var weightTextField: EditUserInfoTextField!
    @IBOutlet private weak var ageTextField: EditUserInfoTextField!
    @IBOutlet private weak var maleGenderButton: UIButton!
    @IBOutlet private weak var femaleGenderButton: UIButton!

    // MARK: - Properties
    var viewModel: UserViewModel

    private let disposeBag = DisposeBag()
    private var genderButtonState: genderButtonType = .female
    private lazy var pickerViewFrame = CGRect(x: 0,
                                              y: view.frame.height - 170,
                                              width: view.frame.width,
                                              height: 170)
    private lazy var heightPickerView: InfoPickerView = {
        let pickerView = InfoPickerView(frame: pickerViewFrame, type: .height)
        pickerView.rx.itemSelected.map { (row, _) -> Int in
            return Int(row + pickerView.type.range.lowerBound)
        }.bind { [weak self] value in
            self?.heightTextField.text = "\(value)"
        }.disposed(by: disposeBag)

        return pickerView
    }()

    private lazy var weightPickerView: InfoPickerView = {
        let pickerView = InfoPickerView(frame: pickerViewFrame, type: .weight)
        pickerView.rx.itemSelected.map { (row, _) -> Int in
            return Int(row + pickerView.type.range.lowerBound)
        }.bind { [weak self] value in
            self?.weightTextField.text = "\(value)"
        }.disposed(by: disposeBag)

        return pickerView
    }()

    private lazy var agePickerView: InfoPickerView = {
        let pickerView = InfoPickerView(frame: pickerViewFrame, type: .age)
        pickerView.rx.itemSelected.map { (row, _) -> Int in
            return Int(row + pickerView.type.range.lowerBound)
        }.bind { [weak self] value in
            self?.ageTextField.text = "\(value)"
        }.disposed(by: disposeBag)

        return pickerView
    }()

    // MARK: - Init
    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    init?(coder: NSCoder, viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBarTitle()
        configureUIButton()
        configureUITextField()
        loadUserInfoToView()
    }

    // MARK: - @IBActions
    @IBAction private func backButtonDidTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func editDoneButtonDidTap(_ sender: Any) {
        let nickNameText = nickNameTextField.text ?? ""
        let heightText = heightTextField.text ?? ""
        let weightText = weightTextField.text ?? ""
        let ageText = ageTextField.text ?? ""
        saveEditedUserInfo(gender: genderButtonState.rawValue,
                           age: ageText,
                           height: heightText,
                           weight: weightText,
                           nickName: nickNameText)
    }

    @IBAction private func genderButtonDidTap(_ sender: Any) {
        genderButtonState.toggle()
        maleGenderButton.isEnabled.toggle()
        femaleGenderButton.isEnabled.toggle()
        allTextFieldResignFirstResponder()
    }

    @IBAction private func viewDidTap(_ sender: Any) {
        allTextFieldResignFirstResponder()
    }

    // MARK: - Functions
    private func configureNavigationBarTitle() {
        navigationItem.title = "개인 정보 수정"
    }

    private func saveEditedUserInfo(gender: String,
                                    age: String,
                                    height: String,
                                    weight: String,
                                    nickName: String) {
        let gender = gender
        let age = Int(age) ?? nil
        let height = Int(height) ?? nil
        let weight = Int(weight) ?? nil
        let nickName = nickName == "" ? nil : nickName
        var alert = UIAlertController()

        viewModel.editUserInfo(gender: gender,
                               age: age,
                               height: height,
                               weight: weight,
                               nickname: nickName)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSaved in
                guard let self = self
                else { return }

                if isSaved {
                    let message = "수정 완료"
                    alert = self.popViewControllerAlertController(message: message)
                } else {
                    let message = "수정 실패"
                    alert = self.popViewControllerAlertController(message: message)
                }
            }, onCompleted: { [weak self] in
                self?.present(alert, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }

    private func configureUIButton() {
        maleGenderButton.isEnabled = true
        femaleGenderButton.isEnabled = true

        maleGenderButton.setBackgroundColor(color: .boosterOrange, for: .disabled)
        maleGenderButton.setBackgroundColor(color: .boosterEnableButtonGray, for: .normal)
        femaleGenderButton.setBackgroundColor(color: .boosterOrange, for: .disabled)
        femaleGenderButton.setBackgroundColor(color: .boosterEnableButtonGray, for: .normal)
    }

    private func configureUITextField() {
        heightTextField.inputView = heightPickerView
        weightTextField.inputView = weightPickerView
        ageTextField.inputView = agePickerView
    }

    private func allTextFieldResignFirstResponder() {
        nickNameTextField.resignFirstResponder()
        heightTextField.resignFirstResponder()
        weightTextField.resignFirstResponder()
        ageTextField.resignFirstResponder()
    }

    private func loadUserInfoToView() {
        if let gender = genderButtonType(rawValue: viewModel.model.gender) {
            (gender == .male) ? (maleGenderButton.isEnabled = false) : (femaleGenderButton.isEnabled = false)
        }

        nickNameTextField.text = viewModel.model.nickname
        heightTextField.text = "\(viewModel.model.height)"
        weightTextField.text = "\(viewModel.model.weight)"
        ageTextField.text = "\(viewModel.model.age)"
    }

    private func popViewControllerAlertController(title: String = "", message: String) -> UIAlertController {
        let alert = UIAlertController.simpleAlert(title: title,
                                              message: message,
                                              action: { (_) -> Void in
            self.navigationController?.popViewController(animated: true)
        })

        return alert
    }
}
