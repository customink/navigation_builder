module ActionView
  module Helpers

    module NavigationBuilderHelper

      # Holds references to the currently selected links for each navigation block on the page.
      def navigation_builder
        @navigation_builder ||= { :main => nil }
      end

      # Generates a block of navigation to be rendered to the page.
      #
      # Example:
      #   <% navigation_for :popup do |n| %>
      #     <%= nav_to 'Members', members_path %>
      #   <% end %>
      #
      # Generally speaking, this should go in your layout.
      def navigation_for( nav_name, options = {}, &block )
        raise ArgumentError, "Missing block" unless block_given?

        builder = options[:builder] || ActionView::Base.default_navigation_builder

        options.reverse_merge!(
          :wrapper_tag => :ul,
          :nav_item_tag => :li,
          :selected_class => 'selected',
          :html => {}
        )

        start_tag( options ) if navigation_has_wrapper?( options )
        body_content( builder, nav_name, options, &block )
        close_tag( options ) if navigation_has_wrapper?( options )

        # Mark the navigation block has having been rendered
        navigation_builder[nav_name] = true
      end

      # Make sure this is called *before* your navigation is rendered.
      # Ideally, this should go in your views and navigation_for() should
      # be in your layout.
      #
      # Example:
      #   <%= navigation_select 'Members', :in => :popup %>
      def navigation_select( link_name, options = {} )
        if navigation_builder[options[:in]] == true
          raise RuntimeError, "The #{options[:in]} navigation block has already been rendered. You cannot call navigation_select if navigation_for has already been called."
        else
          options.reverse_merge!( :in => :main )
          navigation_builder[options[:in]] = link_name
        end
      end

    private

      def navigation_has_wrapper?( options )
        options[:wrapper_tag] and options[:nav_item_tag].to_s == 'li'
      end

      def start_tag( options )
        concat( tag(options[:wrapper_tag], options[:html], true) )
      end

      def body_content( builder, nav_name, options, &block )
        yield builder.new(self, nav_name, options, block)
      end

      def close_tag( options )
        concat("</#{options[:wrapper_tag]}>".html_safe)
      end

    end

    class NavigationBuilder

      attr_reader :item_count

      # Initializes the NavigationBuilder.
      # You'll mostly likely never call this method directly.
      def initialize( template, nav_name, options, proc )
        @item_count = 0
        @template, @nav_name, @options, @proc = template, nav_name, options, proc
      end

      # Builds a link_to tag within the context of the current navigation block.
      # This accepts all of the same parameters that ActiveView's link_to method
      #
      # Example:
      #   <%= nav.link_to 'Home', '#' %>
      #
      # This will also increment the item_count once the link's markup has been generated.
      # This allows you to special case link_to options based on the index of current link
      # in your customized implementations of the Navigation Builder.
      # ---
      def link_to( *args, &link_block )
        if block_given?
          name         = @template.capture(&link_block)
          options      = args.first || {}
          html_options = args.second || {}

          link_to_in_block( name, options, html_options, &link_block )
        else
          name         = args[0]
          options      = args[1] || {}
          html_options = args[2] || {}

          link_to_in_html( name, options, html_options )
        end.tap { @item_count += 1 } # Increment the number of links generated (and still return markup)
      end

    private

      def link_to_in_block( name, options, html_options, &link_block )
        item_html_options = extract_item_options!( html_options )

        set_selected_link( name, html_options, item_html_options ) if is_selected?( name )

        @template.concat( @template.tag( @options[:nav_item_tag], item_html_options, true) ) if @options[:nav_item_tag]
        link_html = @template.link_to(options, html_options, &link_block)
        @template.concat(link_html)
        @template.concat( "</#{@options[:nav_item_tag]}>".html_safe ) if @options[:nav_item_tag]
        nil # have to return nil here so that the generated HTML is not added twice
      end

      def link_to_in_html( name, options, html_options )
        item_html_options = extract_item_options!( html_options )

        set_selected_link( name, html_options, item_html_options ) if is_selected?( name )

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

      def set_selected_link( name, html_options, item_html_options )
        (selected_tag_options( html_options, item_html_options ) << " #{@options[:selected_class]}").strip!
      end

      def selected_tag_options( html_options, item_html_options )
        if @options[:nav_item_tag]
          item_html_options[:class] ||= ''
        else
          html_options[:class] ||= ''
        end
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

    include NavigationBuilderHelper
  end

end
