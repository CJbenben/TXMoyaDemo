//
//  ViewController.swift
//  TXMoyaDemo
//
//  Created by powershare on 2024/7/1.
//

import UIKit
import SnapKit
import Moya

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MoyaProviderDelegate {

    private var cancellable: Cancellable?
    private var dataAry: [String] = ["发送请求，result 对象是字典（block形式回调）",
                                     "发送请求，result 对象是数组（block形式回调）",
                                     "发送请求，result 对象是字典（RxSwift请求方式）",
                                     "发送请求，result 对象是数组（RxSwift请求方式）",
                                     "发送请求，result 对象是字典（delegate形式回调）",
                                     "发送请求，result 对象是数组（delegate形式回调）",
                                     "发送模拟请求，使用 sampleData",
                                     "请求失败后重试",
    ]
    
    // MARK: Public Method
    
    
    // MARK: Private Method
    @objc private func sendRequest0() {
        NetWorkRequest(Api.testApiNoParams, modelType: TXTestNewsModel.self) { response in
            print("response.result 这个是对象 = \(String(describing: response.result))")
        } failureCallback: { error in
            print("请求----失败，error = \(String(describing: error))")
        }
    }

    @objc private func sendRequest1() {
        let params: [String: String] = ["key": "value"]
        NetWorkRequest(Api.testApiHasParams(params: params), modelsType: [TXTestModel].self) { response in
            print("response.result 这个是数组 = \(String(describing: response.result))")
        } failureCallback: { error in
            print("请求----失败，error = \(String(describing: error))")
        }
    }
    
    @objc private func sendRequest2() {
        NetWorkRxRequest(Api.testApiNoParams, modelType: TXTestNewsModel.self) { response in
            print("response.result 这个是对象 = \(String(describing: response.result))")
        } failureCallback: { error in
            print("请求----失败，error = \(String(describing: error))")
        }
    }
    
    @objc private func sendRequest3() {
        let params: [String: String] = ["key": "value"]
        NetWorkRxRequest(Api.testApiHasParams(params: params), modelsType: [TXTestModel].self) { response in
            print("response.result 这个是数组 = \(String(describing: response.result))")
        } failureCallback: { error in
            print("请求----失败，error = \(String(describing: error))")
        }
    }
    
    @objc private func sendRequest4() {
        NetWorkRequest(Api.testApiNoParams, modelType: TXTestNewsModel.self, delegate: self)
    }
    
    @objc private func sendRequest5() {
        let params: [String: String] = ["key": "value"]
        NetWorkRequest(Api.testApiHasParams(params: params), modelsType: [TXTestModel].self, delegate: self)
    }
    
    @objc private func sendRequest6() {
        NetWorkRxRequest(Api.testApiSampleData, modelType: TXSampleDataModel.self, useSampleData: true) { response in
            print("response = \(String(describing: response))")
        }
    }
    
    @objc private func sendRequest7() {
        let params: [String: String] = ["key": "value"]
        NetWorkRxRequest(Api.testApiRetry(params: params), modelType: TXSampleDataModel.self, useSampleData: false) { response in
            print("response = \(String(describing: response))")
        }
    }

    @objc private func btnCancelRequestAction() {
        if let isCancelled = cancellable?.isCancelled, isCancelled {
            print("请求已取消")
        } else {
            cancellable?.cancel()
        }
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Moya Demo"
        self.view.backgroundColor = .white
        
        setupUI()
        
    }
    
    // MARK: MoyaProviderDelegate
    func callApiDidSuccess<T>(target: TargetType, response: APIResponseModel<T>) where T : Decodable, T : Encodable {
        if target.path == Api.testApiNoParams.path {
            if let result = response.result as? TXTestNewsModel, let data = result.data {
                for newsModel in data {
                    print("newsModel?.title = \(String(describing: newsModel?.title))")
                }
            }
        } else if target.path == Api.testApiHasParams(params: nil).path {
            if let result = response.result as? [TXTestModel] {
                for model in result {
                    print("model = \(model)")
                }
            }
        }
        
    }
    
    func callApiDidFailure(target: TargetType, error: (any Error)?) {
        print("请求失败 path = \(target.path), error = \(String(describing: error?.localizedDescription))")
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataAry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
        cell.textLabel?.text = dataAry[indexPath.row]
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            sendRequest0()
        } else if indexPath.row == 1 {
            sendRequest1()
        } else if indexPath.row == 2 {
            sendRequest2()
        } else if indexPath.row == 3 {
            sendRequest3()
        } else if indexPath.row == 4 {
            sendRequest4()
        } else if indexPath.row == 5 {
            sendRequest5()
        } else if indexPath.row == 6 {
            sendRequest6()
        } else if indexPath.row == 7 {
            sendRequest7()
        }
    }
    
    // MARK: UI
    private func setupUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    
    // MARK: lazy
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
        return tableView
    }()

}

