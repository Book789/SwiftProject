//
//  ObjectDetector.swift
//  SwiftProject
//
//  Created by cloud on 2025/11/29.
//
import Vision

class ObjectDetector:NSObject{
    
    var request: VNCoreMLRequest?
    
    override init() {
        super.init()
        self.setUpModel()
    }

    func setUpModel() {
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3Tiny", withExtension: "mlmodelc") else {
            return
        }
        DispatchQueue.global(qos: .background).async {
            do {
                let config = MLModelConfiguration()
                config.computeUnits = .all // 明确指定使用CPU和GPU

                let model = try MLModel(contentsOf: modelURL, configuration: config)
            
             

                let visionModel = try VNCoreMLModel(for: model)
                DispatchQueue.main.async {
                    let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: self.visionRequestDidComplete)
                    self.request = objectRecognition
                    self.request?.imageCropAndScaleOption = .scaleFit
                    
                }
            } catch {
                print("Model loading went wrong: \(error)")
            }
        }
    }
    // 使用Vision进行推理
    func predictUsingVision(handler:VNImageRequestHandler) {
        //获取请求
        guard let request = request else { return }
        //使用Vision进行推理。​request​对象包含了模型和相关配置
        try? handler.perform([request])
    }

        // MARK: - Post-processing
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
            //给当前度量添加了一个标签 ​"endInference"​来表示推理结束的时间点--初始化
            //通过判断 ​request.results​是否为 ​[VNRecognizedObjectObservation]​类型，来检查Vision请求的结果是否是识别对象的观察结果。
            DispatchQueue.main.async(execute: {
                if let predictions = request.results as? [VNRecognizedObjectObservation] {
                    if(predictions.first?.confidence ?? 0 > 0.8){
                        guard let box = predictions.first?.boundingBox else { return  }
                       
                        print(box)
                    }
                }else{

                }
            })
       
    }

}
