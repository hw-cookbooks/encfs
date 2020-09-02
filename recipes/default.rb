package 'encfs'

directory node['encfs']['directories']['crypt'] do
  action :create
  recursive true
end
