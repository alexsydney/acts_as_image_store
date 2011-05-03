Rails.application.routes.draw do
  begin
    mount_at = ActsAsImageStore.backend['mount_at']

    if mount_at
      match "#{mount_at}:size/:name.:format", :to => "stored_images#show", :via => 'get', :constraints => {
        :size => /(raw|\d+x\d+[a-z]*\d*)/,
        :name =>/[0-9a-f]{0,32}/,
        :format =>/(jpg|gif|png)/,
      }
      match "#{mount_at}flush", :to => "stored_images#flush", :via => 'post'
    end

    match ':controller/:id/image_delete/:column', :action => 'image_delete'
  rescue NoMethodError
    #do nothing
  end
end
