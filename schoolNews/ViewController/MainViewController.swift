//
//  ViewController.swift
//  schoolNews
//
//  Created by 이유리 on 14/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewController: UIViewController, SchoolRegistDataDelegate {
    
    @IBOutlet weak var emptyEnrolledSchool: UIView!
    @IBOutlet weak var schoolNewsTableView: UITableView!
    @IBOutlet weak var nonSchoolFoodDataView: UIView!
    
    /// 등록된 학교있는지 없는지
    var isEnrolledSchool = BehaviorRelay<Bool>(value: false)
    /// 등록된 학교있을때 해당 학교 데이터 저장
    var registedSchoolData = BehaviorRelay<School?>(value: nil)
    var foodRelayData = BehaviorRelay<[SchoolFood]>(value: [])
    
    var errorRelayData = BehaviorRelay<[SchoolFood]>(value: [])
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initializeUI()
        self.setTableView()
    }
    
    deinit {
        print("MainViewController ----> Deinit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.enrollSchool {
            if let schoolSearchVC = segue.destination as? SchoolSearchViewController {
                schoolSearchVC.delegate = self
            }
        } else if segue.identifier == Segue.monthFoodList {
            if let monthFoodListVC = segue.destination as? MonthFoodListViewController {
                // 한달치 급식화면으로 이동하면, 등록된 학교 데이터를 넘겨줌
                monthFoodListVC.registedSchool = self.registedSchoolData
            }
        }
    }
    
    @IBAction func schoolEnrollButtonAction(_ sender: UIButton) {
        self.performSegue(withIdentifier: Segue.enrollSchool, sender: self)
    }
    
    @IBAction func schoolDeleteButtonActioin(_ sender: UIBarButtonItem) {
        self.registedSchoolData.accept(nil)
        self.isEnrolledSchool.accept(false)
    }
}

extension MainViewController {
    struct Segue {
        static let enrollSchool     = "enrollSchoolSegue"
        static let monthFoodList    = "monthFoodListSegue"
    }
    
    // SchoolRegistDataDelegate 함수 오버라이딩
    func registData(data: School) {
        // 받아온 데이터를 테이블뷰에 로드하기위해 accept해주고, 등록된 학교 있는걸로 변경
        self.registedSchoolData.accept(data)
        self.isEnrolledSchool.accept(true)
        print("registedSchoolData : \(self.registedSchoolData.value)")
    }
}

// MARK: UI Binding
extension MainViewController {
    func initializeUI() {
        isEnrolledSchool.subscribe(onNext: { [weak self] value in
            guard let `self` = self else { return }
            // 등록된 학교있으면 해당학교에 대한 소식띄움
            if value {
                self.title = self.registedSchoolData.value?.schoolName
                self.navigationItem.rightBarButtonItem?.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.emptyEnrolledSchool.isHidden = true
                self.schoolNewsTableView.isHidden = false
                self.nonSchoolFoodDataView.isHidden = false
                self.requestData()
            }
            // 등록된 학교없으면 등록하라는 화면띄움
            else {
                self.title = "학교 소식"
                self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                self.emptyEnrolledSchool.isHidden = false
                self.schoolNewsTableView.isHidden = true
                self.nonSchoolFoodDataView.isHidden = true
            }
        }).disposed(by: disposeBag)
    }
    
    func setTableView() {
        schoolNewsTableView.estimatedRowHeight = 100.0
        schoolNewsTableView.rowHeight = UITableView.automaticDimension
        schoolNewsTableView.register(UINib(nibName: SchoolFoodListTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: SchoolFoodListTableViewCell.identifier)
        
        // food값이 변경되면 테이블뷰 재구성
        self.foodRelayData.asDriver(onErrorJustReturn: []).drive(self.schoolNewsTableView.rx.items(cellIdentifier: SchoolFoodListTableViewCell.identifier, cellType: SchoolFoodListTableViewCell.self)) { [weak self] _, element, cell in
            guard let _ = self else { return }
            cell.foodServiceDateLabel?.text = element.foodDate
            cell.foodCategoryLabel?.text = element.foodCategory
            // 문자열에 <br/>로 되어있는 부분을 줄바꿈처리
            let foodString = element.foodName?.replacingOccurrences(of: "<br/>", with: "\n")
            cell.foodNameLabel?.text = foodString
            }.disposed(by: self.disposeBag)
        
        self.schoolNewsTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                if let schoolData = self.registedSchoolData.value {
                    self.performSegue(withIdentifier: Segue.monthFoodList, sender: self)
                }
            }).disposed(by: self.disposeBag)
    }
}


// MARK: Data Requset
extension MainViewController {
    /// 등록한 학교에 대한 급식 정보를 요청
    func requestData() {
        // 현재 날짜를 yyyymmdd 형식으로 포맷함
        let formatDate = DateFormatter()
        formatDate.dateFormat = "yyyymmdd"
        let date = formatDate.string(from: Date())
        print("date ===== \(date)")
        
        if let data = self.registedSchoolData.value {
            DataService.SchoolNews.schoolFoodGet(educationCode: data.educationCode ?? "", schoolCode: data.schoolCode ?? "", startDate: "20191105", endDate: "20191105").subscribe(onSuccess: { [weak self] result in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.nonSchoolFoodDataView.isHidden = true
                    self.schoolNewsTableView.isHidden = false
                    self.foodRelayData.accept(result)
                }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    if let err = error as? ErrorCode {
                        switch err {
                        case .responseFailure(code: .if_200):
                            DispatchQueue.main.async {
                                self.nonSchoolFoodDataView.isHidden = false
                                self.schoolNewsTableView.isHidden = true
                                print("**error**")
                            }
                        }
                    }
            }).disposed(by: self.disposeBag)
        }
    }
}




// MARK: Single & Observable Create
extension MainViewController {
    func singleCreate() -> Single<[String: Any]> {
        return Single<[String: Any]>.create { single in
            print("single create")
            let urlString = "https://open.neis.go.kr/hub/schoolInfo?Type=json&pIndex=1&pSize=100&SCHUL_NM=가산"
            let encoded  = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            let url = URL(string: encoded!)!
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("single error")
                    single(.error(error))
                    return
                }
                
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let result = json as? [String: Any] else {
                        print("single error")
                        single(.error(error!))
                        return
                }
                print("single success")
                single(.success(result))
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
    
    func observableCreate() -> Observable<[String: Any]> {
        return Observable<[String: Any]>.create { observer in
            print("observable create")
            let urlString = "https://open.neis.go.kr/hub/schoolInfo?Type=json&pIndex=1&pSize=100&SCHUL_NM=sin"
            let encoded  = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
            let url = URL(string: encoded!)!
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("observable error")
                    observer.onError(error)
                    return
                }
                
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let result = json as? [String: Any] else {
                        print("observable error")
                        observer.onError(error!)
                        return
                }
                print("observable onNext1")
                observer.onNext(result)
                print("observable onNext2")
                observer.onNext(result)
                print("observable onCompleted")
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create { task.cancel() }
        }
    }
    
    func observerSubscribe() {
        singleCreate()
            .subscribe { event in
                print("single subscribe")
                switch event {
                case .success(let result):
                    print("Result: ", result)
                case .error(let error):
                    print("Error: ", error)
                }
            }.disposed(by: disposeBag)
        
        singleCreate()
            .filter{ !$0.isEmpty }
            .map{ $0.values }
            .subscribe(onSuccess: { result in
                print("Result: ", result)
            },onError: { error in
                print("Error: ", error)
            }).disposed(by: disposeBag)
        
        observableCreate()
            .subscribe(onNext: { result in
                print("Result: ", result)
            },onError: { error in
                print("Error: ", error)
            },onCompleted: {
                print("Completed!!")
            },onDisposed: {
                print("Disposed!!")
            }).disposed(by: disposeBag)
    }
}


