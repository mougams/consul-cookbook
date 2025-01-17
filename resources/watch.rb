default_action :create

# @!property path
# @return [String]
property :path, kind_of: String, default: lazy { node.join_path(node['consul']['service']['config_dir'], "#{name}.json") }
# @!property user
# @return [String]
property :user, kind_of: String, default: lazy { node['consul']['service_user'] }
# @!property group
# @return [String]
property :group, kind_of: String, default: lazy { node['consul']['service_group'] }
# @!property type
# @return [String]
property :type, equal_to: %w(checks event key keyprefix nodes service services)
# @!property parameters
# @return [Hash]
property :parameters, kind_of: Hash, default: {}

def params_to_json
  JSON.pretty_generate(watches: [{ type: type }.merge(parameters)])
end

action :create do
  directory ::File.dirname(new_resource.path) do
    recursive true
    unless platform?('windows')
      owner new_resource.user
      group new_resource.group
      mode '0755'
    end
  end

  file new_resource.path do
    content new_resource.params_to_json
    unless platform?('windows')
      owner new_resource.user
      group new_resource.group
      mode '0640'
    end
  end
end

action :delete do
  file new_resource.path do
    action :delete
  end
end
