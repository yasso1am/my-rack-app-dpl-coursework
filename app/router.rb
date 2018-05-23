class Router
  def initialize(req)
    @request = req
  end

  def route
    if resource = controller_class
      @request.params.merge!(route_info)
      controller = resource.new(@request)
      action = route_info[:action]
      
      if controller.respond_to?(action)
        puts "\nStarting #{action} to #{resource}"
        return controller.public_send(action)
      end

    end

    page_not_found
  end

  private
    def controller_name
      #TodosController
      "#{route_info[:resource].capitalize}Controller"
    end

    def controller_class
      #"TodosController"
      #TodosController
      Object.const_get(controller_name) rescue nil
    end

    def route_info
      @route_info ||= begin
        resource = path_fragments[0] || "base"
        id, action = find_id_and_action(path_fragments[1])
        { resource: resource, action: action, id: id }
      end
    end

    def find_id_and_action(fragment)
      case fragment
      when "new"
        [nil, :new]
      when nil
        action = @request.get? ? :index : :create
        [nil, action]
      else
        [fragment, :show]
      end
    end

    def path_fragments
      @fragments ||= @request.path.split("/").reject { |s| s.empty? } 
    end

    def page_not_found
      [404, {"Content-Type" => "text/plain"}, ["404 Page Not Found"]]
    end
end