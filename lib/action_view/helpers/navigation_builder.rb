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
      # <%= navigation_select 'Design', :in => :popup %>
      def navigation_for( nav_name, options = {}, &block )
        raise ArgumentError, "Missing block" unless block_given?

        builder = options[:builder] || ActionView::Base.default_navigation_builder

        options.reverse_merge!(
          :wrapper_tag => :ul,
          :nav_item_tag => :li,
          :selected_class => 'selected',
          :html => {}
        )

        concat( tag(options[:wrapper_tag], options[:html], true) ) if navigation_has_wrapper?( options )
        yield builder.new(self, nav_name, options, block)
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

      def initialize( template, nav_name, options, proc )
        @template, @nav_name, @options, @proc = template, nav_name, options, proc
      end

      def link_to( *args, &link_block )
        if block_given?
          name         = @template.capture(&link_block)
          options      = args.first || {}
          html_options = args.second

          link_to_in_block( name, options, html_options, &link_block )
        else
          name         = args[0]
          options      = args[1] || {}
          html_options = args[2]

          link_to_in_html( name, options, html_options )
        end
      end

    private

      def link_to_in_block( name, options, html_options, &link_block )
        item_html_options = extract_item_options!( html_options )

        set_selected_link( name, item_html_options ) if is_selected?( name )

        @template.concat( @template.tag( @options[:nav_item_tag], item_html_options, true) ) if @options[:nav_item_tag]
        @template.link_to(options, html_options, &link_block)
        @template.concat( "</#{@options[:nav_item_tag]}>".html_safe ) if @options[:nav_item_tag]
      end

      def link_to_in_html( name, options, html_options )
        item_html_options = extract_item_options!( html_options )

        set_selected_link( name, item_html_options ) if is_selected?( name )

        link_html = @template.link_to(name, options, html_options)

        if @options[:nav_item_tag]
          @template.content_tag(@options[:nav_item_tag], link_html, item_html_options )
        else
          link_html
        end
      end

      def extract_item_options!( options )
        options.try(:delete, :item_html) || {}
      end

      def set_selected_link( name, item_html_options )
        ((item_html_options[:class] ||= '') << " #{@options[:selected_class]}").strip!
      end

      def is_selected?( name )
        if @template.navigation_builder[@nav_name].is_a? String
          name == @template.navigation_builder[@nav_name]
        else
          name =~ @template.navigation_builder[@nav_name]
        end
      end

    end

  end

  class Base
    cattr_accessor :default_navigation_builder
    self.default_navigation_builder = ::ActionView::Helpers::NavigationBuilder
  end

end

# For Rails 3?
# ActiveSupport.on_load(:action_view) do
#   class ActionView::Base
#     cattr_accessor :default_navigation_builder
#     @@default_navigation_builder = ::ActionView::Helpers::NavigationBuilder
#   end
# end
