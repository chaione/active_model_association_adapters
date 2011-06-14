ActiveModel Association Adapters
================================
Simple association adapters for polyglot applications.

Summary
-------
Simple association adapters for ActiveModel-compliant models used in polyglot applications. 
Use Mongoid and ActiveRecord together with simple macros.

Examples
--------

    class Monkey < ActiveRecord::Base
      include ActiveRecord::Adapters::Mongoid::Associations
      has_one_document :banana
    end

    class Banana
      include Mongoid::Document
      field :monkey_id, :type => Integer
    end

    monkey.banana = Banana.create
    #=> #<Banana id: 1, monkey_id: 2, created_at: "2011-06-13 21:24:39", updated_at: "2011-06-13 21:24:42"> 

Caveats
-------
No magic, no fancy stuff. Not built for performance. Terrible craftsmanship. Currently only supports ActiveRecord and Mongoid, and only a few macros. Will likely cause segfaults, server crashes, public unrest, and giant lizard attacks.

See RDoc for details (if there ever is one), and use at your own risk, if at all.