module ActiveRecord
  module Adapters
    module Mongoid
      module Associations
        extend ActiveSupport::Concern

        def save(*args)
          super(*args)
          self.class.send(:__has_one_documents).each do |document|
            save_document(document)
          end
          self.class.send(:__has_many_documents).each do |document|
            save_documents(document)
          end
          self
        end

        private

        module InstanceMethods
          def save_document(document)
            send(document).save if send(document) && (send(document).changed? || send(document).new_record?)
            instance_variable_get("@old_#{document}".to_sym).save if instance_variable_get("@old_#{document}".to_sym)
          end

          def save_documents(documents)
            send(documents).each do |document|
              document.save if document && (document.changed? || document.new_record?)
            end
            if instance_variable_get("@old_#{documents}".to_sym)
              instance_variable_get("@old_#{documents}".to_sym).each do |old_document| 
                old_document.save
              end
            end
          end

          def method_missing(meth, *args, &block)
            case meth
            when /build_(.+)$/
              self.send("#{$1}=".to_sym, ($1.classify.constantize).new(*args, &block)) rescue super(meth, *args, &block)
            when /create_(.+)$/          
              self.send("#{$1}=".to_sym, ($1.classify.constantize).create(*args, &block)) rescue super(meth, *args, &block)
            else
              super(meth, *args, &block)
            end
          end

        end

        module ClassMethods

          def has_one_document(name, options={})
            __has_one_documents.delete(name)
            __has_one_documents.push(name)
            add_has_one_accessors_for(name, options)
          end

          def has_many_documents(name, options={})
            __has_many_documents.delete(name)
            __has_many_documents.push(name)
            add_has_many_accessors_for(name, options)
          end

          private

          def __has_one_documents
            @__has_one_documents ||= Array.new
          end

          def __has_many_documents
            @__has_many_documents ||= Array.new
          end

          def add_has_many_accessors_for(name, options={})
            class_eval %Q{
              def #{name}
                @#{name} ||= #{options[:class_name] ? options[:class_name] : name.to_s.classify}.where( (self.class.to_s.underscore + "_id").to_sym => id)
              end

              def #{name}=(others)
                if #{name}
                  @old_#{name} = #{name}
                  @old_#{name}.each do |doc|
                    doc.send((self.class.to_s.underscore + "_id=").to_sym, nil)
                  end
                end
                others.each do |doc|
                  doc.send((self.class.to_s.underscore + "_id=").to_sym, id)
                end
                @#{name} = others
              end
            }        
          end

          def add_has_one_accessors_for(name, options={})
            class_eval %Q{
              def #{name}
                @#{name} ||= #{options[:class_name] ? options[:class_name] : name.to_s.classify}.first(:conditions => {(self.class.to_s.underscore + "_id").to_sym => id})
              end

              def #{name}=(other)
                if #{name}
                  @old_#{name} = #{name}
                  @old_#{name}.send((self.class.to_s.underscore + "_id=").to_sym, nil)              
                end
                other.send((self.class.to_s.underscore + "_id=").to_sym, id)
                @#{name} = other
              end
            }
          end
        end
      end
    end
  end
end