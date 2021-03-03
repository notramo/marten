module Marten
  module DB
    module Field
      class DateTime < Base
        getter auto_now
        getter auto_now_add
        getter default

        def initialize(
          @id : ::String,
          @primary_key = false,
          @default : Time? = nil,
          @blank = false,
          @null = false,
          @unique = false,
          @editable = true,
          @db_column = nil,
          @db_index = false,
          @auto_now = false,
          @auto_now_add = false
        )
          if @auto_now || @auto_now_add
            @blank = true
            @editable = false
          end
        end

        # Returns a boolean indicating if the field automatically sets the current time at record save time.
        def auto_now?
          @auto_now
        end

        # Returns a boolean indicating if the field automatically sets the current time at record creation time.
        def auto_now_add?
          @auto_now_add
        end

        def from_db_result_set(result_set : ::DB::ResultSet) : Time?
          value = result_set.read(Time?)
          value.in(Marten.settings.time_zone) unless value.nil?
        end

        def prepare_save(record, new_record = false)
          if @auto_now || (@auto_now_add && new_record)
            record.set_field_value(id, Time.local)
          end
        end

        def to_column : Management::Column::Base?
          Management::Column::DateTime.new(
            db_column,
            primary_key?,
            null?,
            unique?,
            db_index?,
            to_db(default)
          )
        end

        def to_db(value) : ::DB::Any
          case value
          when Nil
            nil
          when Time
            value.to_utc
          else
            raise_unexpected_field_value(value)
          end
        end
      end
    end
  end
end
