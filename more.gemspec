# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{more}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alexis Sellier"]
  s.date = %q{2010-09-07}
  s.description = %q{In details, More does the following:
    * Recursively looks for LESS (`.less`) files in `app/stylesheets`
    * Ignores partials (prefixed with underscore: `_partial.less`) - these can be included with `@import` in your LESS files
    * Saves the resulting CSS files to `public/stylesheets` using the same directory structure as `app/stylesheets`}
  s.extra_rdoc_files = [
    "README.markdown"
  ]
  s.files = [
    "lib/less/controller_extension.rb",
     "lib/less/more.rb",
     "lib/tasks/more_tasks.rake",
     "rails/init.rb"
  ]
  s.homepage = %q{http://github.com/cloudhead/more}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{More is a plugin for Ruby on Rails applications. It automatically parses your applications `.less` files through LESS and outputs CSS files.}
  s.test_files = [
    "test/controller_test.rb",
     "test/more_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<less>, [">= 0"])
    else
      s.add_dependency(%q<less>, [">= 0"])
    end
  else
    s.add_dependency(%q<less>, [">= 0"])
  end
end

