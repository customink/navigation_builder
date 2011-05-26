require File.dirname(__FILE__) + '/helper'

require 'action_view'
require 'action_view/template'
require 'action_view/test_case'

class TestNavigationBuilder < ActionView::TestCase

  tests ActionView::Helpers::NavigationBuilderHelper

  should "set the default NavigationBuilder" do
    assert_equal ActionView::Helpers::NavigationBuilder, ActionView::Base.default_navigation_builder
  end

  should "generate HTML that contains navigation" do
    navigation_for :main do |nav|
      concat nav.link_to( 'Foo', '#' )
    end

    expected = [
      "<ul>",
        "<li>",
          "<a href=\"#\">Foo</a>",
        "</li>",
      "</ul>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "know how many links have been rendered" do
    count = 0
    navigation_for :main do |nav|
      concat nav.link_to( 'Foo', '#' )
      concat nav.link_to( 'Bar', '#' )
      count = nav.item_count
    end

    assert_equal 2, count
  end

  should "generate HTML with custom wrapper tag name" do
    navigation_for :main, :wrapper_tag => :ol do |nav|
      concat nav.link_to( 'Foo', '#' )
    end

    expected = [
      "<ol>",
        "<li>",
          "<a href=\"#\">Foo</a>",
        "</li>",
      "</ol>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "generate HTML with no wrapper" do
    navigation_for :main, :wrapper_tag => false do |nav|
      concat nav.link_to( 'Foo', '#' )
    end

    expected = [
      "<li>",
        "<a href=\"#\">Foo</a>",
      "</li>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "generate HTML with no wrapper and a custom nav item tag name" do
    navigation_for :main, :nav_item_tag => 'div' do |nav|
      concat nav.link_to( 'Foo', '#' )
    end

    expected = [
      "<div>",
        "<a href=\"#\">Foo</a>",
      "</div>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "generate HTML with no wrapper and a no nav item tag" do
    navigation_for :main, :nav_item_tag => false do |nav|
      concat nav.link_to( 'Foo', '#' )
    end

    expected = [
      "<a href=\"#\">Foo</a>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "generate HTML that contains user-defined attributes" do
    navigation_for :main, :html => { :class => 'bar', 'data-more' => 'baz' } do |nav|
      concat nav.link_to( 'Foo', '#' )
    end

    expected = [
      "<ul class=\"bar\" data-more=\"baz\">",
        "<li>",
          "<a href=\"#\">Foo</a>",
        "</li>",
      "</ul>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "generate HTML with links that were created with blocks" do
    # lambda {
      navigation_for :main do |nav|
        # concat nav.link_to( '#' ) { "<span>Foo</span>".html_safe } # For Rails 3?
        nav.link_to( '#' ) { "<span>Foo</span>".html_safe }
      end
    # }.call(ActionView::Base.new) # For Rails 3: Scoped call so that the capture call works inside the Builder

    expected = [
      "<ul>",
        "<li>",
          "<a href=\"#\"><span>Foo</span></a>",
        "</li>",
      "</ul>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "generate HTML with links that contain user-defined classes" do
    navigation_for :main do |nav|
      concat nav.link_to( 'Foo', '#', :class => 'bar' )
    end

    expected = [
      "<ul>",
        "<li>",
          "<a href=\"#\" class=\"bar\">Foo</a>",
        "</li>",
      "</ul>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "generate HTML with links that contain user-defined classes on the container items" do
    navigation_for :main do |nav|
      concat nav.link_to( 'Foo', '#', :item_html => { :class => 'bar' } )
    end

    expected = [
      "<ul>",
        "<li class=\"bar\">",
          "<a href=\"#\">Foo</a>",
        "</li>",
      "</ul>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "generate HTML that highlights the currently selected navigation link" do
    navigation_select 'Foo', :in => :main

    navigation_for :main do |nav|
      concat nav.link_to( 'Foo', '#' )
    end

    expected = [
      "<ul>",
        "<li class=\"selected\">",
          "<a href=\"#\">Foo</a>",
        "</li>",
      "</ul>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "generate HTML that highlights the currently selected navigation link with a custom class name" do
    navigation_select 'Foo', :in => :main

    navigation_for :main, :selected_class => 'current-page' do |nav|
      concat nav.link_to( 'Foo', '#' )
    end

    expected = [
      "<ul>",
        "<li class=\"current-page\">",
          "<a href=\"#\">Foo</a>",
        "</li>",
      "</ul>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "generate HTML that highlights the currently selected navigation link even where there is no item tag" do
    navigation_select 'Foo', :in => :main

    navigation_for :main, :nav_item_tag => false do |nav|
      concat nav.link_to( 'Foo', '#' )
    end

    expected = [
      "<a href=\"#\" class=\"selected\">Foo</a>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "generate HTML that highlights the currently selected navigation link by using a Regular Expression" do
    navigation_select /Foo/, :in => :main

    # lambda {
      navigation_for :main do |nav|
        # concat nav.link_to( '#' ) { "<span>Foo</span>".html_safe } # For Rails 3?
        nav.link_to( '#' ) { "<span>Foo</span>".html_safe }
      end
    # }.call(ActionView::Base.new) # For Rails 3: Scoped call so that the capture call works inside the Builder

    expected = [
      "<ul>",
        "<li class=\"selected\">",
          "<a href=\"#\"><span>Foo</span></a>",
        "</li>",
      "</ul>"
    ].join('')

    assert_dom_equal expected, output_buffer
  end

  should "raise an exception if a link is selected AFTER the navigation has been rendered" do
    assert_raises RuntimeError do
      navigation_for :main do |nav|
        concat nav.link_to( 'Foo', '#' )
      end
      navigation_select 'Foo', :in => :main
    end
  end

end
