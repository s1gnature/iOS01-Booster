//
//  EraseAllDataViewController.swift
//  Booster
//
//  Created by mong on 2021/11/17.
//

import UIKit

class EraseAllDataViewController: UIViewController, BaseViewControllerTemplate {
    // MARK: - @IBOutlet
    @IBOutlet var subTitleLabel: UILabel!

    // MARK: - Properties
    var viewModel: UserViewModel = UserViewModel()

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        naivgationBarConfigure()
        UIConfigure()
    }

    // MAKR: - @IBAction
    @IBAction func eraseAllButtonDidTap(_ sender: Any) {
        viewModel.eraseAllData { [weak self] (result) in
            DispatchQueue.main.async {
                var alert = UIAlertController()
                switch result {
                case .success(let count):
                    alert = UIAlertController.simpleAlert(title: "삭제 완료", message: "총 \(count)개의 정보가 삭제됐어요!")
                case .failure(let error):
                    dump(error)
                    alert = UIAlertController.simpleAlert(title: "삭제 실패", message: "알 수 없는 오류로 인하여 정보를 삭제할 수 없어요")
                }
                self?.present(alert, animated: true) {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    @IBAction func backButtonDidTap(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Functions
    private func naivgationBarConfigure() {

    }

    private func UIConfigure() {
        subTitleLabel.text = "산책에 대한 기록들은 \(viewModel.nickname())님의\n휴대폰에서만 소중하게 보관하고 있어요"
    }
}
