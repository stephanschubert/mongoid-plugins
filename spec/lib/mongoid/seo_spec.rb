require "spec_helper"

describe Mongoid::SEO do

  let(:klass) { Class.new }
  subject     { klass }

  before(:all) do
    klass.send :include, Mongoid::Document
    klass.send :include, Mongoid::SEO
  end

#  it { should have_field(:page_title) }
#  it { should have_field(:meta_description) }

  describe ".seo_fields" do

    it "should return all fields added by the plugin" do
      klass.seo_fields.should == [ :page_title, :meta_description ]
    end

  end
end
