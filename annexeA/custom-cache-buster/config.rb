sass_dir   = "sass"
css_dir    = "css"
images_dir = "img"

asset_cache_buster do |path, real_path|
  if File.exists?(real_path)
    pathname = Pathname.new(path)
    modified_time = File.mtime(real_path).strftime("%s")
    new_path = "%s/%s-%s%s" % [
      pathname.dirname,
      pathname.basename(pathname.extname),
      modified_time,
      pathname.extname
    ]
    {:path => new_path, :query => nil}
  end
end