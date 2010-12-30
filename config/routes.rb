Rails.application.routes.draw do
  begin
    mount_at = MogileImageStore::Engine.config.mount_at

    match "#{mount_at}:size/:name.:format", :to => "mogile_images#show", :constraints => {
      :size => /(raw|[a-z]*\d*x\d*)/,
      :name =>/[0-9a-f]{0,32}/,
      :format =>/(jpg|gif|png)/,
    }
    match ':controller/:id/image_delete/:column', :to => 'image_tests#image_delete'
  rescue NoMethodError
    #do nothing
  end
end
