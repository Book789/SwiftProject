# Uncomment the next line to define a global platform for your project
 platform :ios, '11.0'

def all_pods
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Template
  pod 'Alamofire'
  pod 'SnapKit'
  pod 'Kingfisher'
  pod 'IQKeyboardManagerSwift'
  pod 'HandyJSON'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'ZLPhotoBrowser'
  pod 'FSPagerView' #轮播图
#  pod 'KTVHTTPCache', '~> 2.0.0'
  pod 'lottie-ios'
  pod 'Toast-Swift'

  #Objective-C
  pod 'YYCategories', '~> 1.0.4'
  pod 'MBProgressHUD'
  pod 'MJRefresh'
  pod 'YYText'
  pod 'FDFullscreenPopGesture'
  pod 'SDWebImage'
  pod 'FLAnimatedImage'
  pod 'Qiniu'

# cocopods 支持模拟器arm64
#        post_install do |installer|
#          installer.pods_project.build_configurations.each do |config|
#            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
#          end
#        end

  
end

target 'SwiftProject' do
    all_pods
end


post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
               end
          end
   end
end





