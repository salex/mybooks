<!DOCTYPE html>
<html>
  <head>
    <title><%= content_for(:title) || "Mybooks" %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="mobile-web-app-capable" content="yes">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>

    <%= yield :head %>

    <%# Enable PWA manifest for installable apps (make sure to enable in config/routes.rb too!) %>
    <%#= tag.link rel: "manifest", href: pwa_manifest_path(format: :json) %>

    <link rel="icon" href="/icon.png" type="image/png">
    <link rel="icon" href="/icon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="/icon.png">

    <%# Includes all stylesheet files in app/assets/stylesheets %>
    <%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
    <script crossorigin="anonymous" src="https://kit.fontawesome.com/69f9b59efd.js"></script>

  </head>

  <body>
    <div class="bg-blue-200 flex">
      <% if Current.session.present? %>
        <%= button_to "Sign out", session_path, method: :delete, class: "inline-flex items-center px-4 py-1 border m-2 border-transparent text-md font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" %>
      <% else %>
        <%= link_to "Sign in", new_session_path, class: "inline-flex items-center px-4 py-1 border m-2 border-transparent text-md font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500" %>
      <% end %>
  </div>
    <main class=" mx-4 mt-5 px-2 ">
      <%= yield %>
    </main>
  </body>
</html>
