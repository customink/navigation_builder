module ActionView
  module Helpers

    module NavigationBuilderHelper

      def navigation_builder
        @navigation_builder ||= { :main => nil }
      end

      # <% navigation_for :popup do |n| %>
      #   <%= nav_to 'Design', :action => :design %>
      # <% end %>
      # 
      # <%= nav_at 'Design', :in => :popup %>
      def navigation_for( nav_name, options = {}, &block )
        raise ArgumentError, "Missing block" unless block_given?

        builder = options[:builder] || ActionView::Base.default_navigation_builder

        options.reverse_merge!( :wrapper_tag => :ul, :nav_item_tag => :li, :html => {} )

        concat( tag(options[:wrapper_tag], options[:html], true) ) if navigation_has_wrapper?( options )
        yield builder.new(self, options, block)
        concat("</#{options[:wrapper_tag]}>".html_safe) if navigation_has_wrapper?( options )
      end

      def navigation_select( link_name, options = {} )
        options.reverse_merge!( :in => :main )
        navigation_builder[options[:in]] = link_name
      end

    private

      def navigation_has_wrapper?( options )
        options[:wrapper_tag] and options[:nav_item_tag].to_s == 'li'
      end

    end

    class NavigationBuilder

      def initialize( template, options, proc )
        @template, @options, @proc = template, options, proc
      end

      def link_to( *args, &block )
        if block_given?
          options      = args.first || {}
          html_options = args.second
          item_html_options = extract_item_options!( html_options )

          name = @template.capture(&block)

          set_selected_link( name, item_html_options )

          link_html = @template.link_to(options, html_options, &block)
        else
          name         = args[0]
          options      = args[1] || {}
          html_options = args[2]

          item_html_options = extract_item_options!( html_options )

          set_selected_link( name, item_html_options )

          link_html = @template.link_to(name, options, html_options)
        end

        if @options[:nav_item_tag]
          @template.content_tag(@options[:nav_item_tag], link_html, item_html_options )
        else
          link_html
        end
      end

    private

      def extract_item_options!( options )
        options.try(:delete, :item_html) || {}
      end

      def set_selected_link( name, item_html_options )
        ((item_html_options[:class] ||= '') << ' selected').strip! if is_selected?( name )
      end

      def is_selected?( name )
        if @template.navigation_builder[:main].is_a? String
          name == @template.navigation_builder[:main]
        else
          name =~ @template.navigation_builder[:main]
        end
      end

    end

  end
end

ActiveSupport.on_load(:action_view) do
  class ActionView::Base
    cattr_accessor :default_navigation_builder
    @@default_navigation_builder = ::ActionView::Helpers::NavigationBuilder
  end
end
