if defined?(Rails) && Rails.version.to_i == 3
  # TODO: Rails 3 Support
else
  class ActionView::Base
    autoload :NavigationBuilderHelper, 'action_view/helpers/navigation_builder'

    include NavigationBuilderHelper
  end
end