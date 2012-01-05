require File.dirname(__FILE__) + '/helper'

require 'action_view'
require 'action_view/template'
require 'action_view/test_case'

class TestNavigationBuilder < ActionView::TestCase

  include CustomAssertions

  tests ActionView::Helpers::NavigationBuilderHelper

  should "set the default NavigationBuilder" do
    assert_equal ActionView::Helpers::NavigationBuilder, ActionView::Base.default_navigation_builder
  end

  should "generate HTML that contains navigation" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_for :main do |nav| %>
          <%= nav.link_to 'Foo', '#' %>
        <% end %>
      EOS

      test.expected = <<-EOS
        <ul>
          <li>
            <a href=\"#\">Foo</a>
          </li>
        </ul>
      EOS
    end
  end

  should "know how many links have been rendered" do
    render :inline => <<-EOS
      <% navigation_for :main do |nav| %>
        <%= nav.link_to( 'Foo', '#' ) %>
        <%= nav.link_to( 'Bar', '#' ) %>
        <%= nav.item_count %> links
      <% end %>
    EOS

    assert_match /2 links/, rendered
  end

  should "generate HTML with custom wrapper tag name" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_for :main, :wrapper_tag => :ol do |nav| %>
          <%= nav.link_to( 'Foo', '#' ) %>
        <% end %>
      EOS

      test.expected = <<-EOS
       <ol>
         <li>
           <a href="#">Foo</a>
         </li>
       </ol>
      EOS
    end
  end

  should "generate HTML with no wrapper" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_for :main, :wrapper_tag => false do |nav| %>
          <%= nav.link_to( 'Foo', '#' ) %>
        <% end %>
      EOS

      test.expected = <<-EOS
       <li>
         <a href="#">Foo</a>
       </li>
      EOS
    end
  end

  should "generate HTML with no wrapper and a custom nav item tag name" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_for :main, :nav_item_tag => 'div' do |nav| %>
          <%= nav.link_to( 'Foo', '#' ) %>
        <% end %>
      EOS

      test.expected = <<-EOS
       <div>
         <a href="#">Foo</a>
       </div>
      EOS
    end
  end

  should "generate HTML with no wrapper and a no nav item tag" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_for :main, :nav_item_tag => false do |nav| %>
          <%= nav.link_to( 'Foo', '#' ) %>
        <% end %>
      EOS

      test.expected = <<-EOS
        <a href="#">Foo</a>
      EOS
    end
  end

  should "generate HTML that contains user-defined attributes" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_for :main, :html => { :class => 'bar', 'data-more' => 'baz' } do |nav| %>
          <%= nav.link_to( 'Foo', '#' ) %>
        <% end %>
      EOS

      test.expected = <<-EOS
       <ul class="bar" data-more="baz">
         <li>
           <a href="#">Foo</a>
         </li>
       </ul>
      EOS
    end
  end

  should "generate HTML with links that were created with blocks" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_for :main do |nav| %>
          <% nav.link_to( '#' ) do %>
            <span>Foo</span>
          <% end %>
        <% end %>
      EOS

      test.expected = <<-EOS
       <ul>
         <li>
           <a href="#"><span>Foo</span></a>
         </li>
       </ul>
      EOS

    end
  end

  should "generate HTML with links that contain user-defined classes" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_for :main do |nav| %>
          <%= nav.link_to( 'Foo', '#', :class => 'bar' ) %>
        <% end %>
      EOS

      test.expected = <<-EOS
       <ul>
         <li>
           <a href="#" class="bar">Foo</a>
         </li>
       </ul>
      EOS
    end
  end

  should "generate HTML with links that contain user-defined classes on the container items" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_for :main do |nav| %>
          <%= nav.link_to( 'Foo', '#', :item_html => { :class => 'bar' } ) %>
        <% end %>
      EOS

      test.expected = <<-EOS
       <ul>
         <li class="bar">
           <a href="#">Foo</a>
         </li>
       </ul>
      EOS
    end
  end

  should "generate HTML that highlights the currently selected navigation link" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_select 'Foo', :in => :main %>
        <% navigation_for :main do |nav| %>
          <%= nav.link_to( 'Foo', '#' ) %>
        <% end %>
      EOS

      test.expected = <<-EOS
       <ul>
         <li class="selected">
           <a href="#">Foo</a>
         </li>
       </ul>
      EOS
    end
  end

  should "generate HTML that highlights the currently selected navigation link with a custom class name" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_select 'Foo', :in => :main %>
        <% navigation_for :main, :selected_class => 'current-page' do |nav| %>
          <%= nav.link_to( 'Foo', '#' ) %>
        <% end %>
      EOS

      test.expected = <<-EOS
       <ul>
         <li class="current-page">
           <a href="#">Foo</a>
         </li>
       </ul>
      EOS
    end
  end

  should "generate HTML that highlights the currently selected navigation link even where there is no item tag" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_select 'Foo', :in => :main %>
        <% navigation_for :main, :nav_item_tag => false do |nav| %>
          <%= nav.link_to( 'Foo', '#' ) %>
        <% end %>
      EOS

      test.expected = <<-EOS
       <a href="#" class="selected">Foo</a>
      EOS
    end
  end

  should "generate HTML that highlights the currently selected navigation link by using a Regular Expression" do
    assert_generated_markup do |test|
      test.template = <<-EOS
        <% navigation_select /Foo/, :in => :main %>
        <% navigation_for :main do |nav| %>
          <% nav.link_to( '#' ) do %>
            <span>Foo</span>
          <% end %>
        <% end %>
      EOS

      test.expected = <<-EOS
       <ul>
         <li class="selected">
           <a href="#"><span>Foo</span></a>
         </li>
       </ul>
      EOS
    end
  end

  should "raise an exception if a link is selected AFTER the navigation has been rendered" do
    assert_raises RuntimeError do
      render :inline => <<-EOS
        <% navigation_for :main do |nav| %>
          <%= nav.link_to( 'Foo', '#' ) %>
        <% end %>
        <% navigation_select 'Foo', :in => :main %>
      EOS
    end
  end

end
