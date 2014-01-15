actions :mount, :unmount, :destroy
default_action :mount

attribute :encrypted_path, :kind_of => String
attribute :visible_path, :kind_of => String, :required => true, :name_argument => true
attribute :owner, :kind_of => String, :default => 'root'
attribute :group, :kind_of => String, :default => 'root'
attribute :password, :kind_of => String
