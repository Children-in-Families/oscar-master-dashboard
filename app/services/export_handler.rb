class ExportHandler
  include ApplicationHelper

  attr_reader :klass, :collection, :columns

  def self.call(klass, collection, columns)
    new(klass, collection, columns).call
  end

  def initialize(klass, collection, columns)
    @klass = klass
    @collection = collection
    @columns = columns
  end

  def call
    CSV.generate(headers: true) do |csv|
      csv << columns.map { |column| klass.human_attribute_name(column) }

      collection.each do |record|
        csv << columns.map { |column| format_value(record.public_send(column)) }
      end
    end
  end
end
