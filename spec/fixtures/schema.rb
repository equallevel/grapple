ActiveRecord::Schema.define do

	create_table "users", :force => true do |t|
		t.string   "login",                      :limit => 100, :default => "",       :null => false
		t.string   "crypted_password",           :limit => 40,  :default => "",       :null => false
		t.string   "email",                      :limit => 100, :default => "",       :null => false
		t.string   "firstname",                  :limit => 50
		t.string   "lastname",                   :limit => 50
		t.string   "salt",                       :limit => 40,  :default => "",       :null => false
		t.datetime "created_at"
		t.datetime "updated_at"
		t.datetime "logged_in_at"
		t.boolean  "deleted",                                   :default => false
		t.datetime "deleted_at"
	end

end
