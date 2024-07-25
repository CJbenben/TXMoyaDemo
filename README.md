# 对 Moya 的二次封装

[Moya的官方地址](https://github.com/Moya/Moya)

[Moya的中文文档](https://github.com/Moya/Moya/tree/master/docs_CN)


关于 Moya 的基本使用和介绍，度娘上已经有很多文章了，这里只是基于 Moya/RxSwift 做了简单的封装，便于项目中直接使用。

## 基本介绍
此 demo 做了哪些事情？
1. 发送请求后通过 block 形式回调结果
2. 发送请求后通过 delegate 形式回调结果
3. 支持使用 Moya / RxSwift 两种形式发送请求
4. 对响应的结果使用 Codable 转成对应的模型
5. 使用 Moya 的 sampleData 案例
6. 请求失败后重试案例（还未完成）


![MoyaDemo.png](https://upload-images.jianshu.io/upload_images/674752-68b6191828500cca.png)


![目录结构.png](https://upload-images.jianshu.io/upload_images/674752-4217cd8a9f96b45d.png)

- APIResponseModel：json 转 Model 时，处理响应结果最外层结构
- Api：请求参数配置
- NetworkManager：对 Moya 封装后的请求工具


## 部分代码
```
    /* 
    json 格式: result 是对象
    {
         "reason": "sample-data",
          "result": {
            "index": "1",
            "data": [{
                "id": "1589f954e57bba15b40d795e0c2dd700",
                "title": "金乡农商银行“零钱包”架起“连心桥”",
                "time": "2024-07-19 10:37:00",
                "price": 18.88,
                "count": 123
            }],
            "currPage": "1",
            "pageSize": "30"
        },
        "error_code": 0
    }
    */

  NetWorkRequest(Api.testApiNoParams, modelType: TXTestNewsModel.self) { response in
      print("response.result 这个是对象 = \(String(describing: response.result))")
  } failureCallback: { error in
      print("请求----失败，error = \(String(describing: error))")
  }
  
  NetWorkRequest(Api.testApiNoParams, modelType: TXTestNewsModel.self, delegate: self)
```

```
/* 
    json 格式: result 是数组
    {
         "reason": "sample-data",
          "result": [{
            "index": "1",
            "data": [{
                "id": "1589f954e57bba15b40d795e0c2dd700",
                "title": "金乡农商银行“零钱包”架起“连心桥”",
                "time": "2024-07-19 10:37:00",
                "price": 18.88,
                "count": 123
            }],
            "currPage": "1",
            "pageSize": "30"
        }],
        "error_code": 0
    }
    */

   let params: [String: String] = ["key": "value"]
   NetWorkRequest(Api.testApiHasParams(params: params), modelsType: [TXTestModel].self) { response in
      print("response.result 这个是数组 = \(String(describing: response.result))")
   } failureCallback: { error in
      print("请求----失败，error = \(String(describing: error))")
   }
  
    NetWorkRequest(Api.testApiHasParams(params: params), modelsType: [TXTestModel].self, delegate: self)
```
