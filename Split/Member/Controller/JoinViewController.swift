//
//  JoinViewController.swift
//  Split
//
//  Created by najin on 2020/10/14.
//

import UIKit
import Alamofire

class JoinViewController: UIViewController, UITextFieldDelegate {

    //MARK:- 선언 및 초기화
    //MARK: 프로퍼티 선언
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nickTextField: UITextField!
    @IBOutlet weak var nickCheckLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    var nickCheck = false
    var phone = ""
    var isMemberCheck = ""
    
    //MARK: 버튼 활성화 함수
    func buttonEnableStyle(button: UIButton){
        button.backgroundColor = Common().lightpurple
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = true
        button.layer.cornerRadius = 5
    }
    
    //MARK: 버튼 비활성화 함수
    func buttonDisableStyle(button: UIButton){
        button.backgroundColor = .darkGray
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = false
        button.layer.cornerRadius = 5
    }
    
    //MARK: 초기화
    override func viewDidLoad() {
        super.viewDidLoad()
        nickTextField.delegate = self
        
        buttonDisableStyle(button: nextButton)
        //반응형 폰트
        titleLabel.font = Common().koPubDotumBold16
        nickTextField.font = Common().koPubDotumBold16
        nickCheckLabel.font = Common().koPubDotumBold14
        nextButton.titleLabel!.font = Common().koPubDotumBold16
    }
    
    //MARK: status bar 색상 지정하기
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    //MARK: 입력값 유효성 검사
    func textFieldDidChangeSelection(_ textField: UITextField) {
        //핸드폰번호길이 유효성 검사
        if nickTextField.text!.count > 8 || nickTextField.text!.count < 2 {
            nickCheckLabel.text = "사용하실 닉네임을 2~8자로 설정해주세요"
            nickCheck = false
            buttonDisableStyle(button: nextButton)
        }else {
            if self.nickTextField.text!.range(of: "^[a-zA-Z가-힣0-9]*$", options: .regularExpression) != nil {
                let URL = Common().baseURL+"/member/check.nick"
                let headers: HTTPHeaders = ["nick": self.nickTextField.text!]
                let alamo = AF.request(URL, method: .post, headers: headers).validate(statusCode: 200..<300)
    
                alamo.responseString { response in
                    switch response.result {
                    case .success(let value):
                        if value == "false" {
                            self.nickCheckLabel.text = "사용가능한 닉네임입니다"
                            self.nickCheck = true
                            self.buttonEnableStyle(button: self.nextButton)
                        } else {
                            self.nickCheckLabel.text = "중복된 닉네임입니다"
                            self.nickCheck = false
                            self.buttonDisableStyle(button: self.nextButton)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            } else {
                nickCheckLabel.text = "한글,영문,숫자만 입력해주세요"
                self.buttonDisableStyle(button: self.nextButton)
            }
        }
    }

    //MARK:- 완료버튼 누른 후
    @IBAction func nextButtonClick(_ sender: UIButton) {
        
        let URL = Common().baseURL+"/member/insert.do"
        let headers: HTTPHeaders = ["pNum": MemberVO.shared.phone!, "nick": self.nickTextField.text!]
        let alamo = AF.request(URL, method: .post, headers: headers).validate(statusCode: 200..<300)

        struct Join : Decodable {
            let mId : Int
            let message : String
        }
        
        alamo.responseDecodable(of: Join.self) { (response) in
            guard let join = response.value else { return }
            UserDefaults.standard.set(join.mId, forKey: "id")
            //메인페이지로 이동
            let nextView = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController")
            self.navigationController?.pushViewController(nextView!, animated: false)
        }
        
//        alamo.responseDecodable(of: MemberVO.self) { (response) in
//            guard let member = response.value else { return }
//            UserDefaults.standard.set(member.id, forKey: "id")
//            //메인페이지로 이동
//            let nextView = self.storyboard?.instantiateViewController(withIdentifier: "tabBarController")
//            self.navigationController?.pushViewController(nextView!, animated: false)
//        }
    }
}
