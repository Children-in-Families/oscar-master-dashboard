module MultiSchema
  extend ActiveSupport::Autoload

  autoload :Behaviors

  include Behaviors
  extend Behaviors
end