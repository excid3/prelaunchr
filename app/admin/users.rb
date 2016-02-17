require 'csv'

ActiveAdmin.register User do
  csv do
    column :id
    column :email
    column :referral_code
    column :referrer_id
    column :created_at
    column :updated_at
  end

  actions :index, :show

  action_item do
    link_to "Download Winners", winners_admin_users_path
  end

  collection_action :winners, method: :get do
    stops = User::REFERRAL_STEPS.map{|stop| stop["count"]}

    winners = Hash.new {|h,k| h[k]=[]}
    User.all.each do |user|
      found = nil

      stops.reverse_each do |stop|
        found = stop if stop <= user.referrals.count and !found
      end

      winners[found] << user if found
    end

    winners = CSV.generate do |csv|
      winners.each do |stop, list|
        csv << [stop, "------"]
        list.each do |user|
          csv << [user.email, user.referrals.count]
        end
      end
    end
    send_data winners, filename: "winners.csv"
  end
end
