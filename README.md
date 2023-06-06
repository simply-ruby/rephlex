# Introduction

Welcome to Rephlex, a fun and fast Ruby web framework designed to empower developers with simplicity and flexibility. An amalgamation of the best open-source Ruby tooling available, Rephlex streamlines the development process, allowing you to focus on building robust and efficient web applications.

At the heart of Rephlex lies its emphasis on [simplicity](https://www.youtube.com/watch?v=SxdOUGdseq4&themeRefresh=1). By minimizing abstraction layers and avoiding magic, the framework enables developers to gain a comprehensive understanding of the entire request/response cycle. With Rephlex, you have full control over your code, ensuring a transparent and manageable development experience. After all, It's _Simply Ruby™️_ at its core.

One of the key strengths of Rephlex is its utilization of Phlex for component architecture and speed. By leveraging Phlex, developers can effortlessly incorporate powerful component-based design patterns into their applications. This approach not only enhances code reusability but also promotes modular and maintainable codebases.

With Rephlex, you'll experience a delightful development journey that combines simplicity, flexibility, and the best tools Ruby has to offer. So, join us as we embark on a journey of building amazing web applications with ease and confidence.

# About Rephlex

Rephlex is the modern Ruby framework. Leveraging the best tooling built and supported by the community it can come as packed or as light as you want, because Rephlex is built on Roda, The Routing Tree Web Toolkit. This provides a **Fast**, **Modular**, and **Scalable** backbone that makes Rephlex so powerful.

One of the core tenet of Rephlex is _Locality of Behavior_.
You can find this as soon as you start a new project and you see the directory structure.

```
project
│   README.md
│   app.rb
|   config.ru
│   ...
└───allocs
│   │
│   └─── users
│   │    │   data_model.rb
│   │    │   routes.rb
│   │    │   user_decorator.rb (if you need)
│   │    │   other_user_model.rb (perhaps)
│   │    │
│   │    └─── components
│   │    │   │ user_card.rb
│   │    │   │ user_sidebar.rb
│   │    │
│   │    └─── pages
│   │    │   │ show.rb
│   │    │   │ index.rb
│   │    │   │ dashboard.rb
│   │    │
│   │    └─── services(whatever you want)
│   │        │ some_user_service.rb
│   │        │ another_user_service.rb
│   │        │ important_user_service.rb
│   │
│   └─── posts
│       │   data_model.rb
│       │   routes.rb
│       │   publisher.rb
│       │   ... etc.
|
└───system
...
```

## Database

To complement Roda, Rephlex uses Sequel; Ruby's most flexible, and feature rich database library.

```ruby
module Users
    class DataModel < Sequel::Model(DB[:users])
      # Comprehensive ORM layer for mapping records to Ruby objects and handling associated records.
    end
end
```

## Frontend

Rephlex provides first-class support for two exceptional libraries: [htmx](https://htmx.org/) and [Stimulus.js](https://stimulus.hotwired.dev/). These libraries offer progressive enhancement capabilities, empowering developers to leverage the full potential of HTML as a powerful tool for building modern web applications, plus they're just plain fun to use.

With htmx, you can enhance the user experience by enabling smooth server interactions, you can really take advantage of this using Phlex components!

```ruby
# Phlex user form
class UserForm < Phlex::HTML
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def 

end



# User routes
module Users
  class Routes < Users::Routes
    r.on "edit" do

    end
  end
end
```

With Stimulus.js provides a lightweight and intuitive way to add interactivity to your frontend components.

Rephlex integrates seamlessly with modern frontend tooling. By embracing [ViteRuby](https://vite-ruby.netlify.app/guide/introduction.html). Vite provides support for TypeScript, PostCSS, CSS Modules, NPM Dependency Resolving and Pre-Bundling and other [features](https://vitejs.dev/guide/features.html) that help a developers focus more on doing rather than configuring.

While a core tenet of Rephlex is simplicity, developers have the freedom to attach any reactive frontend tools that best suit their specific needs. Whether it's Vue.js, React, or any other popular frontend framework, Rephlex allows you to work with the tools you love, enabling you to create dynamic and engaging user interfaces. Sometimes you just need it.

## File Attachments

Rephlex relies on [Shrine](https://shrinerb.com/docs/advantages). One of the best in class file attachment gems in our ecosystem.

```ruby
# a code example showing a file-attachment in a Rephlex route

```

## Authentication

Being built on Roda, Rephlex has the advantage of using Rodauth: Ruby's Most Advanced Authentication Framework as its authentication solution. [Learn more](http://rodauth.jeremyevans.net/why.html)

```ruby
# a code example showing Rodauth working in Rephlex route
```

## Background Jobs

## Extendable Core

## Deployment

# License

Rephlex is open-sourced software licensed under [the MIT license](https://opensource.org/license/mit/).
