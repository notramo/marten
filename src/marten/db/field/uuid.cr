module Marten
  module DB
    module Field
      class UUID < Base
        getter default

        def initialize(
          @id : ::String,
          @primary_key = false,
          @default : ::UUID? = nil,
          @blank = false,
          @null = false,
          @unique = false,
          @index = false,
          @editable = true,
          @db_column = nil
        )
        end

        def from_db(value : ::DB::Any) : ::UUID?
          case value
          when Nil
            value.as?(Nil)
          when ::String
            ::UUID.new(value.as(::String))
          else
            raise_unexpected_field_value(value)
          end
        end

        def from_db_result_set(result_set : ::DB::ResultSet) : ::UUID?
          from_db(result_set.read(::String?))
        end

        def to_column : Management::Column::Base?
          Management::Column::UUID.new(
            db_column!,
            primary_key?,
            null?,
            unique?,
            index?,
            to_db(default)
          )
        end

        def to_db(value) : ::DB::Any
          case value
          when Nil
            nil
          when ::UUID
            value.to_s
          else
            raise_unexpected_field_value(value)
          end
        end

        def validate(record, value)
          return if value.nil?
          return if value.as?(::UUID)

          if (v = value.as?(::String))
            begin
              return if ::UUID.new(v)
            rescue ArgumentError
            end
          end

          record.errors.add(id, I18n.t("marten.db.field.uuid.errors.invalid"))
        end
      end
    end
  end
end
