def load_current_resource
  unless(new_resource.visible_path)
    new_resource.visible_path new_resource.name
  end

  unless(new_resource.encrypted_path)
    new_resource.encrypted_path(
      ::File.join(
        node[:encfs][:directories][:crypt],
        Digest::SHA.hexdigest(new_resource.visible_path)
      )
    )
  end
end

action :mount do
  run_context.include_recipe 'encfs'

  unless(new_resource.password)
    run_context.include_recipe 'encfs::passwords'
    if(fs_pass = node.run_state[:encfs][new_resource.visible_path])
      new_resource.password fs_pass
    else
      raise "EncFS requires a password for mounting directories! (path: #{new_resource.visible_path})"
    end
  end

  args = Mash.new(
    :visible => new_resource.visible_path,
    :crypted => new_resource.encrypted_path,
    :password => new_resource.password,
    :owner => new_resource.owner,
    :group => new_resource.group
  )

  [args[:visible], args[:crypted]].each do |dir_name|
    directory dir_name do
      owner args[:owner]
      group args[:group]
      recursive true
    end
  end

  execute "EncFS mount <#{args[:visible]}>" do
    execute "echo '#{args[:password]} | encfs --standard --stdinpass #{args[:crypted]} #{args[:visible]}"
    not_if "mountpoint #{args[:visible]}"
  end

end

action :unmount do
  point = new_resource.visible_path

  mount "EncFS unmount <#{point}>" do
    path point
    action :umount
  end

end

action :destroy do

  encfs new_resource.visible_path do
    action :unmount
  end

  [new_resource.visible_path, new_resource.encrypted_path].each do |dir_name|
    directory dir_name do
      action :delete
      recursive true
    end
  end

end
