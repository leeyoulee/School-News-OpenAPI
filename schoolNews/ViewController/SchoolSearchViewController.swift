//
//  SchoolSearchViewController.swift
//  schoolNews
//
//  Created by 이유리 on 17/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol SchoolRegistDataDelegate: class {
    func registData(data: School)
}

class SchoolSearchViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var schoolListTableView: UITableView!
    @IBOutlet weak var nonSearchDataView: UIView!
    
    var schoolRelayData = BehaviorRelay<[School]>(value: [])
    var errorCodeRelayData = BehaviorRelay<[ErrorResponse]>(value: [])
    
    var searchText: String?
    weak var delegate: SchoolRegistDataDelegate?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "학교 검색"
        self.setTableView()
        self.searchAction()
    }
    
    deinit {
        print("SchoolSearchViewController ----> Deinit")
    }
    
}

extension SchoolSearchViewController {
    func setTableView() {
        self.nonSearchDataView.isHidden = false
        self.schoolListTableView.isHidden = true
        
        schoolListTableView.register(UINib(nibName: SchoolListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SchoolListTableViewCell.identifier)
        schoolListTableView.register(UINib(nibName: EmptySearchDataTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: EmptySearchDataTableViewCell.identifier)
        
        // school값이 변경되면 테이블뷰 재구성
        self.schoolRelayData.asDriver(onErrorJustReturn: []).drive(self.schoolListTableView.rx.items(cellIdentifier: SchoolListTableViewCell.identifier, cellType: SchoolListTableViewCell.self)) { [weak self] _, element, cell in
            guard let `self` = self else { return }

            cell.schoolNameLabel?.text = element.schoolName
            cell.schoolAddressLabel?.text = element.schoolAddress

            cell.buttonActionHandler = { [weak self] in
                guard let `self` = self else { return }
                // 등록 버튼을 클릭하면 클릭한 학교를 MainViewController로 넘겨주고, 화면 닫음
                self.delegate?.registData(data: element)
                self.navigationController?.popViewController(animated: true)
            }
            }.disposed(by: self.disposeBag)
    }
    
    func searchAction() {
        //text 값을 옵셔널 타입(String?)이 아닌 String으로 받아오기 위해 orEmpty 사용
        searchTextField.rx.text.orEmpty.filter{ !$0.isEmpty }.subscribe(onNext: { [weak self] text in
            guard let `self` = self else { return }
            self.searchText = text
            self.requestData()
        }).disposed(by: disposeBag)
        
        searchButton.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if let text = self.searchText {
                self.requestData()
            }
        }).disposed(by: disposeBag)
    }
}

// MARK: Data Request
extension SchoolSearchViewController {
    func requestData() {
        //school 값을 받아와서 schoolRelayData에 넣어주면 테이블뷰 리로드됨
        DataService.SchoolNews.schoolGet(schoolName: self.searchText!).subscribe(onSuccess: { [weak self] result in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.nonSearchDataView.isHidden = true
                self.schoolListTableView.isHidden = false
            }
            self.schoolRelayData.accept(result)
            }, onError: { [weak self] error in
                guard let `self` = self else { return }
                if let err = error as? ErrorCode {
                    switch err {
                    case .responseFailure(code: .if_200):
                        DispatchQueue.main.async {
                            self.nonSearchDataView.isHidden = false
                            self.schoolListTableView.isHidden = true
                            print("**error**")
                        }
                    }
                }
        }).disposed(by: self.disposeBag)
    }
}
