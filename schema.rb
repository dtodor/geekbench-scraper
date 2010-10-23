require 'score'

unless Score.table_exists?
  ActiveRecord::Base.connection.create_table(:scores) do |t|
    t.string :processor
    t.datetime :score
    t.string :relative_time
  end
end
