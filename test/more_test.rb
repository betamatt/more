require 'test_helper'

class MoreTest < ActiveSupport::TestCase
  setup do
    [:compression, :header, :destination_path, :source_path].each do |variable|
      Less::More.send("#{variable}=", nil)
    end
  end

  context :header do
    should "be true by default" do
      assert_equal Less::More.header, true
    end

    should "be overwriteable" do
      Less::More.header = false
      assert_equal false, Less::More.header
    end
  end

  context :source_path do
    should "be app/stylesheets by default" do
      assert_equal 'app/stylesheets', Less::More.source_path
    end

    should "be overwritteable" do
      Less::More.source_path = 'xxx'
      assert_equal 'xxx', Less::More.source_path
    end
  end

  context :destination_path do
    should "be public/stylesheets by default" do
      assert_equal 'stylesheets', Less::More.destination_path
    end

    should "be overwritteable" do
      Less::More.destination_path = 'xxx'
      assert_equal 'xxx', Less::More.destination_path
    end
  end

  context :compression do
    should "be off by default" do
      assert_equal nil, Less::More.compression
    end

    should "be overwritteable" do
      Less::More.compression = true
      assert_equal true, Less::More.compression
    end
  end

  def css_path
    "#{Rails.root}/public/css"
  end

  def less_path
    "#{Rails.root}/less_files"
  end

  def write_less file, content
    write_content File.join(less_path, file), content
  end

  def write_css file, content
    write_content File.join(css_path, file), content
  end

  def write_content file, content
    `mkdir -p #{File.dirname(file)}`
    File.open(file,'w'){|f| f.print content }
  end

  def read_css(file)
    File.read(File.join(css_path, file)) rescue nil
  end

  def assert_include(item, obj)
    assert_block("#{obj.inspect}\ndoes not include\n#{item.inspect}."){ obj.include? item }
  end

  def assert_not_include(item, obj)
    assert_block("#{obj.inspect}\ndoes include\n#{item.inspect}."){ !obj.include? item }
  end

  context :generate do
    setup do
      Less::More.source_path = 'less_files'
      Less::More.destination_path = 'css'
      Less::More.header = false
      `mkdir -p #{css_path}`
    end

    teardown do
      `rm -rf #{css_path}`
      `rm -rf #{less_path}`
    end

    should 'generate css from .less files' do
      write_less 'test.less', "a{color:red}"
      Less::More.generate_all
      assert_include 'a { color: red; }', read_css('test.css')
    end

    should 'generate css from .lss files' do
      write_less 'test.lss', "a{color:red}"
      Less::More.generate_all
      assert_include 'a { color: red; }', read_css('test.css')
    end

    should 'generate for files in subfolders' do
      write_less 'xxx/test.less', "a{color:red}"
      Less::More.generate_all
      assert_include 'a { color: red; }', read_css('xxx/test.css')
    end

    should "include imported partials" do
      write_less 'test.less', "@import '_partial';\nb{color:blue}"
      write_less '_partial.less', 'a{color:red}'
      Less::More.generate_all
      assert_include 'a { color: red; }', read_css('test.css')
    end

    should "not generate css from partials" do
      write_less '_partial.less', 'a{color:red}'
      Less::More.generate_all
      assert_equal '', `ls #{css_path}`.strip
    end

    should "not parse css" do
      write_less 'test.css', 'a{color:red}'
      Less::More.generate_all
      assert_equal 'a{color:red}', read_css('test.css')
    end

    should "add disclaimer-header when active" do
      write_less 'test.less', 'a{color:red}'
      Less::More.header = true
      Less::More.generate_all
      assert_match /^\/\*/, read_css('test.css')
    end

    should "not include header when not set" do
      write_less 'test.less', 'a{color:red}'
      Less::More.header = false
      Less::More.generate_all
      assert_not_include '/*', read_css('test.css')
    end

    should "fail with current file when encountering an error" do
      write_less 'test.less', 'import xxxx;;;;;'
      content = begin
        Less::More.generate_all
        '!no exception!'
      rescue Exception => e
        e.message
      end
      assert_include '/test.less', content
    end

    context 'mtime' do
      should "generate for outdated less files" do
        write_less 'test.less', "a{color:red}"
        Less::More.generate_all
        write_css 'test.css', 'im updated!'
        sleep 1 # or mtime will be still the same ...
        write_less 'test.less', "a{color:blue}"
        Less::More.generate_all
        assert_equal 'a { color: blue; }', read_css('test.css').strip
      end

      should "not generate for up-to-date less files" do
        write_less 'test.less', "a{color:red}"
        Less::More.generate_all
        write_css 'test.css', 'im updated!'
        Less::More.generate_all
        assert_equal 'im updated!', read_css('test.css')
      end
    end
  end

  context :remove_all_generated do
    setup do
      Less::More.source_path = 'less_files'
      Less::More.destination_path = 'css'
      `mkdir -p #{css_path}`
    end

    teardown do
      `rm -rf #{css_path}`
      `rm -rf #{less_path}`
    end

    should "remove all generated css" do
      write_less 'xxx.less', 'a{color:red}'
      write_less 'yyy.css', 'a{color:red}'
      write_less 'xxx/yyy.css', 'a{color:red}'
      Less::More.generate_all
      Less::More.remove_all_generated
      # should be '' ideally, but an empty folder is no thread :)
      assert_equal 'xxx', `ls #{css_path}`.strip
    end

    should "not remove other files" do
      write_css 'xxx.css', 'a{color:red}'
      Less::More.generate_all
      Less::More.remove_all_generated
      assert_equal 'xxx.css', `ls #{css_path}`.strip
    end
  end
end