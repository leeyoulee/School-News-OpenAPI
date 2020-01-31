//
//  MonthFoodListViewController.swift
//  schoolNews
//
//  Created by 이유리 on 29/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class MonthFoodListViewController: UIViewController {
    
    @IBOutlet weak var monthFoodListTableView: UITableView!
    
    var monthFoodRelayData = BehaviorRelay<[SchoolFood]>(value: [])
    var registedSchool = BehaviorRelay<School?>(value: nil)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeUI()
        self.requestData()
        self.setTableView()
    }
    
}

// MARK: UI Binding
extension MonthFoodListViewController {
    func initializeUI() {
        if let schoolName = self.registedSchool.value?.schoolName {
            self.title = schoolName + " 한달치 급식"
        }
    }
    
    func setTableView() {
        monthFoodListTableView.estimatedRowHeight = 100.0
        monthFoodListTableView.rowHeight = UITableView.automaticDimension
        monthFoodListTableView.register(UINib(nibName: SchoolFoodListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SchoolFoodListTableViewCell.identifier)
        monthFoodListTableView.register(UINib(nibName: EmptySearchDataTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: EmptySearchDataTableViewCell.identifier)
        
        // food값이 변경되면 테이블뷰 재구성
        self.monthFoodRelayData.asDriver(onErrorJustReturn: []).drive(self.monthFoodListTableView.rx.items(cellIdentifier: SchoolFoodListTableViewCell.identifier, cellType: SchoolFoodListTableViewCell.self)) { [weak self] _, element, cell in
            guard let `self` = self else { return }
            cell.foodServiceDateLabel?.text = element.foodDate
            cell.foodCategoryLabel?.text = element.foodCategory
            // 문자열에 <br/>로 되어있는 부분을 줄바꿈처리
            let foodString = element.foodName?.replacingOccurrences(of: "<br/>", with: "\n")
            cell.foodNameLabel?.text = foodString
            }.disposed(by: self.disposeBag)
    }
}

// MARK: Data Requset
extension MonthFoodListViewController {
    /// 등록한 학교에 대한 급식 정보를 요청
    func requestData() {
        // 현재 날짜를 yyyymmdd 형식으로 포맷함
        let formatDate = DateFormatter()
        formatDate.dateFormat = "yyyymmdd"
        let date = formatDate.string(from: Date())
        print("date ===== \(date)")
        
        if let data = self.registedSchool.value {
            DataService.SchoolNews.schoolFoodGet(educationCode: data.educationCode ?? "", schoolCode: data.schoolCode ?? "", startDate: "20191005", endDate: "20191105").subscribe(onSuccess: { [weak self] result in
                guard let `self` = self else { return }
                    self.monthFoodRelayData.accept(result)
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    if let err = error as? ErrorCode {
                        switch err {
                        case .responseFailure(code: .if_200):
                            DispatchQueue.main.async {
                                print("**error**")
                            }
                        }
                    }
            }).disposed(by: self.disposeBag)
        }
    }
}
