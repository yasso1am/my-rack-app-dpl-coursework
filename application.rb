files = File.expand_path('../app/**/*.rb', __FILE__)
Dir.glob(files).each { |file| require(file) }

class Application
  def call(env)
    request = Rack::Request.new(env)
    resolve(request)
  end

  def resolve(request)
    Router.new(request).route
  end

end