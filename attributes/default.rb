# Will be created if it doesn't exist
default[:backup][:backup_user] = "backup"
default[:backup][:config] = {}
default[:backup][:models] = {}

# This is not used yet. We need to merge this with the node config for each model
# Search for merge_attribute_tree in this article:
# http://omniti.com/seeds/seeds-our-experiences-with-chef-cookbook-and-attribute-design
default[:backup][:model_defaults] = {
  :description => "",
  :split_into_chunks_of => 5120,
  :compress_with => :gzip,
  :archives => {},
  :databases => {},
  :store_with => {},
  :encrpyt_with => {},
  :notifies => {},
  :schedule => {}
}
