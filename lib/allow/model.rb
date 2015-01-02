module Allow::Model
  extend ActiveSupport::Concern

  module ClassMethods
    def roles_namespace
      @roles_namespace || "Roles::"
    end

    def roles_namespace= value
      @roles_namespace = value
    end
  end

  def roles_list
    roles.map do |role|
      begin
        "#{self.class.roles_namespace}#{role.to_s.classify}".constantize
      rescue NameError => e
        msg = "Undefined role '#{role}', #{e.message}"
        msg = msg.colorize(:red) if msg.respond_to?(:colorize)
        Rails.logger.info(msg)
        nil
      end
    end.compact
  end

  def can?(*args) #(action, resource_or_record = nil, options = nil)
    options = args.extract_options!
    action, resource_or_record = *args
    Allow::Supervisor.check_permission(self, action, resource_or_record, options)
  end

  module ComaStorage
    extend ActiveSupport::Concern

    included do
      scope :with_role, lambda { |role_name|
        where("#{self.roles_column} REGEXP ?", "(,|^)#{Regexp.escape(role_name.to_s)}(,|$)")
      }
    end

    module ClassMethods
      def roles_column
        @roles_column || :roles
      end

      def roles_column= value
        @roles_column = value
      end
    end

    def roles
      self[self.class.roles_column].to_s.split(",").select(&:present?).map(&:to_sym)
    end

    def roles=(values)
      values = values.values if values.kind_of?(Hash)
      write_attribute(self.class.roles_column, values.uniq.join(','))
    end

    def add_role(role)
      write_attribute(self.class.roles_column, (roles + [role.to_sym]).uniq.join(','))
    end

    def add_role!(role)
      add_role(role)
      save
    end

    def remove_role!(role)
      remove_role(role)
      save
    end

    def remove_role(role)
      write_attribute(self.class.roles_column, (roles - [role.to_sym]).uniq.join(','))
    end

    def has_role?(role)
      roles.include?(role.to_sym)
    end
  end
end
