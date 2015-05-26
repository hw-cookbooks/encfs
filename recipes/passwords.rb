unless node.run_state[:encfs]
  if node[:encfs][:passwords][:data_bag][:enabled]
    begin
      if node[:encfs][:passwords][:data_bag][:encrypted]

      else
        bag = data_bag_item(
          node[:encfs][:passwords][:data_bag][:name],
          node[:encfs][:data_bag][:item]
        )
      end
      node.run_state[:encfs] = Mash.new(bag.to_hash)
    rescue 404
      warn 'Failed to locate encfs password data bag!'
    end
  end
end
