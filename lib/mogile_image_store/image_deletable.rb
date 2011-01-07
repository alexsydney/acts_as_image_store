# coding: utf-8

##
# == 概要
# 添付画像をMogileFSに格納するプラグイン
#
module MogileImageStore
  #
  # ActionControllerにincludeするモジュール
  #
  module ImageDeletable
    def self.included(base)
      base.extend(ClassMethods)
    end
    #
    # ActionControllerにextendされるモジュール
    #
    module ClassMethods
      def image_deletable(model=nil)
        cattr_accessor  :image_model

        model = eval(model.to_s) unless model.is_a? ::ActiveRecord::Base

        self.image_model  = model || eval(self.name[/(.+)Controller/,1].singularize)

        class_eval <<-EOV
        include MogileImageStore::ImageDeletable::InstanceMethods
        rescue_from MogileImageStore::ColumnNotFound do |e| render ({:nothing => true, :status => "404 Not Found"}) end
        EOV
      end
    end
    #
    # 各コントローラにincludeされるモジュール
    #
    module InstanceMethods
      def image_delete
        begin
          image_model.transaction do
            @record = image_model.lock(true).find(params[:id])
            column = params[:column].to_sym
            raise MogileImageStore::ColumnNotFound unless @record.image_columns.include?(column)
            key = @record[column]
            raise MogileImageStore::ImageNotFound if !key || key.empty?
            @record[column] = nil
            if @record.save!
              MogileImage.destroy_image(key)
              deleted = true
            end
          end
        rescue ::ActiveRecord::RecordInvalid, ::MogileImageStore::ImageNotFound
          redirect_to({ :action => 'edit', :id => @record },
                      :alert => I18n.translate('mogile_image_store.errors.flashes.delete_failed'))
          return
        end
        redirect_to @record
      end
    end
  end
end

