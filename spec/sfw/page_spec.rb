require File.dirname(__FILE__) + '/../spec_helper'
require File.expand_path("../../../server/sfw/page", __FILE__)

describe "Sfw::Page" do
  before(:all) do
    Sfw::Page.directory = nil
    Sfw::Page.default_directory = nil
  end

  context "when Sfw::Page.directory has not been set" do
    it "raises Sfw::PageError" do
      expect {
        Sfw::Page.get('anything')
      }.to raise_error(Sfw::PageError, /Sfw::Page\.directory/)
    end
  end

  context "when Sfw::Page.default_directory has not been set" do
    it "raises Sfw::PageError" do
      Sfw::Page.directory = 'tmp'
      expect {
        Sfw::Page.get('anything')
      }.to raise_error(Sfw::PageError, /Sfw::Page\.default_directory/)
    end
  end

  context "when Sfw::Page directories have been set" do
    before(:all) do
      @root = File.expand_path(File.join(File.dirname(__FILE__), "../.."))
      @test_data_dir = File.join(@root, 'spec/data')
      Sfw::Page.directory = @test_data_dir
      Sfw::Page.default_directory = File.join(@test_data_dir, 'defaults')
    end

    before(:each) do
      FileUtils.rm_rf Sfw::Page.directory
      FileUtils.mkdir Sfw::Page.directory
      FileUtils.mkdir Sfw::Page.default_directory
      @page_data = {'foo' => 'bar'}
    end

    describe "put" do
      context "when page doesn't exist yet" do
        it "creates new page" do
          File.exist?(File.join(@test_data_dir, 'foo')).should be_false
          Sfw::Page.put('foo', @page_data)
          File.exist?(File.join(@test_data_dir, 'foo')).should be_true
        end

        it "returns the page" do
          Sfw::Page.put('foo', @page_data).should == @page_data
        end
      end

      context "when page already exists" do
        it "updates the page" do
          Sfw::Page.put('foo', @page_data).should == @page_data
          new_data = {'buzz' => 'fuzz'}
          Sfw::Page.put('foo', new_data)
          Sfw::Page.get('foo').should == new_data
        end
      end
    end

    describe "get" do
      context "when page exists" do
        it "returns the page" do
          Sfw::Page.put('foo', @page_data).should == @page_data
          Sfw::Page.get('foo').should == @page_data
        end
      end

      context "when page does not exist" do
        it "creates a factory page" do
          Sfw::RandomId.stub(:generate).and_return('fake-id')
          foo_data = Sfw::Page.get('foo')
          foo_data['title'].should == 'foo'
          foo_data['story'].first['id'].should == 'fake-id'
          foo_data['story'].first['type'].should == 'factory'
        end
      end

      context "when page does not exist, but default with same name exists" do
        it "copies default page to new page path and returns it" do
          default_data = {'default' => 'data'}
          Sfw::Page.put('defaults/foo', default_data)
          Sfw::Page.get('foo').should == default_data
        end
      end
    end
  end
end
