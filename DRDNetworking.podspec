Pod::Spec.new do |s|
    s.name                = "DRDNetworking"
    s.version             = "0.6.1"
    s.summary             = "DRDNetworking is a networking sdk started by IMF."
    s.description         = <<-DESC
        Name story:
        Durandal is the sword of Charlemagne's paladinRoland in the literary series known as the Matter of France.(From Wiki)

        Our Durandal:
        It's a easy way to handle remote api call. Currently, in Durandal we are using AFNetworking Session Manager.
        DESC
    s.homepage            = "https://github.com/Eleme-IMF/DRDNetworking"
    s.license             = 'MIT'
    s.author              = { "cendywang" => "cendymails@gmail.com" }
    s.source              = { :git => "https://github.com/Eleme-IMF/DRDNetworking.git", :tag => s.version.to_s }
    s.platform            = :ios, '7.0'
    s.requires_arc        = true
    s.source_files        = 'Pod/Classes/**/*'
    s.public_header_files = 'Pod/Classes/**/*.h'
    s.dependency 'AFNetworking', '~> 3.0.0'
end
