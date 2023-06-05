# Rephlex

A slightly opinionated, this framework centers around resource allocations and locality of behavior. For example a resource like "post" and all the logic centered around decorators/routes/data-model/view components will all like in the same directory.

This framework provides some small code generation tooling, code reloading, and modern a frontend solution in vite-ruby. This framework is purposefully small, and fast. Leaning on Roda's routing tree and Sequel as the ORM you can use the plugin systems to only load in the code you truly need.

With Roda and Sequel clocking in as the fastest ruby routing system and ORM respectively, they are complimented on the view layer with Phlex components, the fastest ruby rendering library. Leaning on evoliving tooling in the realm of hypermedia as the engine of application state, we are all-in on systems like Turbo with TurboBoost, or HTMX.


We do not provide a large system of dsls or 'magic' for Rephlex. We strongly suggest using pure ruby and object oriented programming to solve you needs and to take care of managing your dependencies.
