class AddConfigurationThreadsForRanking < ActiveRecord::Migration[6.1]
  def up
    ::Configuration.create(key: 'feature.trhead_count_for_ranking', value_as_str: '4')
  end

  def down
    ::Configuration.find_by(key: 'feature.trhead_count_for_ranking').destroy
  end
end
