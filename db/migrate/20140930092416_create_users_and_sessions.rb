class CreateUsersAndSessions < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password_digest
    end

    create_table :sessions do |t|
      t.belongs_to :user
      t.string :session_id
    end
  end
end
