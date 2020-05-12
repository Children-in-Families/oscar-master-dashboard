module MultiSchema
  module Behaviors
    @@disable_message = false

    def disable_message=(val)
      @@disable_message = val
    end

    def disable_message
      @@disable_message
    end

    def within_schema(schema_name)
      set_schema_path schema_name

      output = yield

      reset_schema_path

      output
    end

    def all_schemas
      ActiveRecord::Base.connection.select_values <<-END
      SELECT *
      FROM pg_namespace
      WHERE
        nspname NOT IN ('information_schema') AND
        nspname NOT LIKE 'pg%'
      END
    end

    def current_schema
      ActiveRecord::Base.connection.current_schema
    end

    def reset_schema_path
      puts "--- Restore Schema to public" unless disable_message
      ActiveRecord::Base.connection.schema_search_path = 'public'
    end

    def schema_path
      ActiveRecord::Base.connection.schema_search_path
    end

    def set_schema_path(schema)
      puts "--- Select Schema: #{schema} " unless disable_message
      ActiveRecord::Base.connection.schema_search_path = schema
    end

    def push_schema_to_path(schema)
      new_path = "#{schema}, #{schema_path}"
      set_schema_path(new_path)
    end

    def pop_schema_from_path
      new_path = schema_path.sub(/\w,/, '')
      set_schema_path(new_path)
    end

    private

    def unify_type(input, type)
      if input.is_a?(type)
        input
      else
        yield input
      end
    end

    def unify_array_item_type(input, type, &block)
      input.map do |item|
        unify_type item, type, &block
      end
    end
  end
end
