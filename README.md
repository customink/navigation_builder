Navigation Builder
==================

While at [RailsConf](http://www.railsconf.com) in the Spring/Summer of 2011, [Bruce Williams](http://github.com/bruce) mentioned a gem he wrote called ["Goose"](http://github.com/bruce/goose) that made generating navigation really easy. After looking through the code, I immediately thought of some tweaks that I wanted to make.

Rather than dealing with forks and pull requests, I just decided to spin off my own implementation from scratch, modeling the API after ActionView's FormBuilder.

#### That's great, let me see some code. ####

    <% navigation_for :main do |nav| %>
      <%= nav.link_to 'Home', '#' %>
    <% end %>

Generates:

    <ul>
      <li>
        <a href="#">Home</a>
      </li>
    </ul>

#### How do you mark a link as selected? ####

    <% navigation_select 'Home' %>

Make sure that is called *before* the navigation is rendered in the view.

That will generate:

    <ul>
      <li class="selected">
        <a href="#">Home</a>
      </li>
    </ul>

#### I don't want to use the class "selected". I'd rather use "current-page" ####

    <% navigation_for :main, :selected_class => "current-page" do |nav| %>
      <%= nav.link_to 'Home', '#' %>
    <% end %>

#### But my links need additional HTML! ####

NavigationBuilder supports the same options that the `link_to` helper does:

    <% navigation_for :sub_nav do |nav| %>
      <% nav.link_to '#' do %>
        <em>Home</em>
        <span>Go to your home! Are you too good for your home?!</span>
      <% end %>
    <% end %>

#### Doesn't that mean that I need to repeat the entire `link_to` block when marking a link as selected? ####

Not at all, just use a regular expression:

    <% navigation_select /Home/ %>

#### But what if I have multiple blocks of navigation on the page? ####

    <% navigation_select 'Home', :in => :sub_nav %>

And in your layout:

    <% navigation_for :sub_nav do |nav| %>
      <%= nav.link_to 'Home', '#' %>
    <% end %>

#### I need to do something special after the third link! ####

    <% navigation_for :main, do |nav| %>
      <%= nav.link_to 'Home', '#' %>
      <%- if nav.item_count = 3 -%>
        Something Special
      <%- end -%>
    <% end %>

That's probably a poor example. The usefulness of the `item_count` attribute is more apparent when you create a custom NavigationBuilder.

For instance, you can use it to automatically add the class `"first"`:

    module NavigationBuilders
      class FancyPantsNavigation < ActionView::Helpers::NavigationBuilder
      
        def link_to_in_html( name, options, html_options )
          if item_count == 0
            html_options[:item_html] ||= { :class => '' }
            html_options[:item_html][:class] = " #{html_options[:item_html][:class]} first".strip
          end
          
          super
        end
        
      end
    end

##### You can do that with CSS you know... #####

If you don't have to support IE6, then yes, you can.

#### Well... what if I need an Ordered List! ####

    <% navigation_for :main, :wrapper_tag => :ol do |nav| %>
      <%= nav.link_to 'Home', '#' %>
    <% end %>

Generates:

    <ol>
      <li class="selected">
        <a href="#">Home</a>
      </li>
    </ol>

#### Nevermind, I hate lists. I just want DIVs. ####

    <% navigation_for :main, :nav_item_tag => :div do |nav| %>
      <%= nav.link_to 'Home', '#' %>
    <% end %>

Generates:

    <div class="selected">
      <a href="#">Home</a>
    </div>

#### My designer just said that's DIV-soup. ####

    <% navigation_for :main, :nav_item_tag => false do |nav| %>
      <%= nav.link_to 'Home', '#' %>
    <% end %>

Generates:

    <a href="#" class="selected">Home</a>

#### Why didn't you name this Gem "Wolfman" ####

Originally I was going to. But if you came across a method named "wolfman" in your view code, it would not be entirely clear as to what it was going to do.
So I just went with something boring and generic.

#### Well, you've thought of everything, haven't you! ####

Probably not, let me know if you have any feature requests!

TODOs
=====

* Rails 3 support
* Add test for "selected" class when there is no item tag
* Add test for thrown exception when setting a selected link after a nav block has already been rendered.
