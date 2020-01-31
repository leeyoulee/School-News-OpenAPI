//
//  emptyEnrolledSchoolView.swift
//  schoolNews
//
//  Created by 이유리 on 16/01/2020.
//  Copyright © 2020 이유리. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class emptyEnrolledSchoolView: UIView {

    var buttonActionHandler: (() -> Void)?
    let disposeBag = DisposeBag()
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    @IBAction func schoolEnrollButton(_ sender: UIButton) {
        self.buttonActionHandler?()
    }
    
}
