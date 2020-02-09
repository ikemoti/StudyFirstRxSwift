//
//  ViewController.swift
//  StudyFirstRxSwift
//
//  Created by USER on 2020/02/02.
//  Copyright © 2020 USER. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    
    let disposebag = DisposeBag()
    //segmentControlの値定義
    enum State:Int {
        case useButtons
        case useTextField
    }
    //UI実装
    @IBOutlet weak var greetLabel: UILabel!
    @IBOutlet weak var Segment: UISegmentedControl!
    @IBOutlet weak var freeTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    
    
    @IBOutlet var gettingButton: [UIButton]!
    
        
    let  lastSelectedGreeting:Variable<String> = Variable("こんにちは")
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //名前欄、テキスト入力イベントを観測対象にする
        let nameobservable: Observable<String?> = nameTextField.rx.text.asObservable()
        //自由入力
        let freeobservable:Observable<String?> = freeTextField.rx.text.asObservable()
        //(combineltist)　お名前と自由入力　それぞれの直近の最新値同士で結合
        let freewordWithNameObservable:Observable<String?> = Observable.combineLatest(nameobservable,freeobservable){
            (string1:String?,string2:String?)in return string1! + string2!
        }
        //(bindTo)イベントのプロパティ接続
        //(Disposebag)鉱毒状態からの解放
        freewordWithNameObservable.bindTo(greetLabel.rx.text).addDisposableTo(disposebag)
        
        //セグメントコントロールを観測対象
        let segmentedControlObservable:Observable<Int> = Segment.rx.value.asObservable()
        
        //セグメントコントロールの値変化を検知して、その状態に対応するenumを返す
        //(map)別の要素に変換する　Int →State
        let stateObservable:Observable<State> = segmentedControlObservable.map{
            (selectedIndex:Int) ->State in return State(rawValue: selectedIndex)!
        }
        
        //enumの値変化を検知して」、テキストフィールドが編集を受け付ける状態かを返す
        //(map)state→bool
        let greetingTextFieldEnableObservable:Observable<Bool> = stateObservable.map{
            (state:State) -> Bool in return state == .useTextField
        }
        //イベントのプロパティ接続
        greetingTextFieldEnableObservable.bindTo(freeTextField.rx.isEnabled).addDisposableTo(disposebag)
        
         //テキストフィールドが編集を受け付けるかどうかを検知して、ボタン部分が選択可能かを返す
        let buttonsEnableObserble:Observable<Bool> = greetingTextFieldEnableObservable.map { (greetingEnabled:Bool) -> Bool in return !greetingEnabled
        }
        //アウトレットコレクションで接続したボタンに関する処理
        gettingButton.forEach{ button in
            
            //イベントのプロパティ接続する、
            buttonsEnableObserble.bindTo(button.rx.isEnabled).addDisposableTo(disposebag)
            
            //onNext (値が更新された時のイベント)　以下処理
            //ボタンタップ時subscribeする
            button.rx.tap.subscribe(onNext: { (nothing:Void) in
                self.lastSelectedGreeting.value = button.currentTitle!
                }).addDisposableTo(disposebag)
        }
        let predefinedGreetingObservable:Observable<String> = lastSelectedGreeting.asObservable()
 
        let finalGreetingObservable :Observable<String> = Observable.combineLatest(stateObservable,freeobservable,predefinedGreetingObservable,nameobservable){
            (state:State ,freeword:String?,predifinedGreeting: String,name:String?)-> String in
            
            switch state {
            case .useTextField: return freeword! + name!
            case .useButtons : return predifinedGreeting + name!
        }
        }
    
        finalGreetingObservable.bindTo(greetLabel.rx.text).addDisposableTo(disposebag)
        }
        

     

}

