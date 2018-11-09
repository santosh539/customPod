Pod::Spec.new do |s|
s.name             = 'custompodTest'  
s.version          = '0.0.3'  
s.summary          = ‘checking pod files’ 
s.description      = <<-DESC
This highletbale view changes highlet text and makes your app look fantastic!
DESC

s.homepage         = 'https://github.com/santosh539/customPod' 
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'santosh539' => 'santosh539@gmail.com' } 
s.source           = { :git => 'https://github.com/santosh539/customPod.git', :tag => s.version.to_s } 
s.ios.deployment_target = '10.0'
s.source_files = 'custompodTest/*'  
end
